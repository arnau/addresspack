// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

// use chrono::prelude::*;

use anyhow::Result;
use csv;
use indicatif::{ProgressBar, ProgressStyle};
use itertools::Itertools;
use rusqlite::{Connection, Error as SqlError, Transaction, NO_PARAMS};
use std::fs;
use std::include_str;
use std::io;
use std::path::{Path, PathBuf};

pub mod cli;
pub mod error;
pub mod meta;
pub mod pragma;
pub mod record;

pub use crate::error::PackError as Error;
pub use crate::meta::Cache;
pub use crate::record::Record;

#[derive(Debug, Clone)]
pub struct Options {
    pub synchronous: pragma::Synchronous,
    pub journal: pragma::Journal,
}

/// Inserts the given record to the database.
fn insert_record(record: Record, tx: &Transaction, cache: &Cache) -> Result<(), Error> {
    let table_id: u32 = record.table_id()?;
    let cached_sql = cache.get(table_id)?;
    let mut stmt = tx.prepare_cached(cached_sql)?;

    stmt.execute(record.as_slice())?;

    Ok(())
}

fn process_csv(
    path: &Path,
    tx: &Transaction,
    cache: &Cache,
    bar: &ProgressBar,
) -> Result<(), Error> {
    let mut rdr = csv::ReaderBuilder::new()
        .has_headers(false)
        .flexible(true)
        .from_path(&path)?;
    let mut raw_record = csv::ByteRecord::new();

    while rdr.read_byte_record(&mut raw_record)? {
        let record: Record = raw_record.deserialize(None)?;

        insert_record(record, &tx, &cache)?;

        bar.inc(1);
    }

    Ok(())
}

// TODO:
// Expect an iterator of readers. This should decouple the process from the file system.
// pub fn process_entries(conn: &mut Connection, &[BufReader]) -> Result<(), PackError> {

/// Processes all CSV files in the given directory.
pub fn process_dir<'a>(conn: &mut Connection, dir: &'a Path, fpt: usize) -> Result<&'a str, Error> {
    if !dir.is_dir() {
        return Err(Error::BadInput(format!(
            "{} must be a directory.",
            dir.display()
        )));
    };

    match next_index(&conn)? {
        Some(index) => {
            let mut entries = fs::read_dir(dir)?
                .map(|res| res.map(|e| e.path()))
                .collect::<Result<Vec<_>, io::Error>>()?;

            entries.sort();

            let processed_amount = (index - 1) as usize;
            let pending_amount = entries.len() - processed_amount;
            let record_amount = 1_000_000; // Roughly the amount of records per file.

            if pending_amount == 0 {
                return Ok("There are no pending records to process.");
            }

            let cache = Cache::prepare(&conn)?;
            let bar = ProgressBar::new((pending_amount * record_amount) as u64);
            bar.set_style(
                ProgressStyle::default_bar()
                    .template("[{elapsed_precise}] {bar:40.yellow/white} {pos:>7}/{len:7} {msg}")
                    .progress_chars("··."),
            );

            for chunk in &entries
                .iter()
                .filter(is_csv)
                .skip(processed_amount)
                .chunks(fpt)
            {
                let tx = conn.transaction()?;

                for entry in chunk {
                    process_csv(&entry, &tx, &cache, &bar)?;
                }

                tx.commit()?;
            }

            bar.finish();

            Ok("Finished processing all given records.")
        }
        None => Ok("There are no pending records to process."),
    }
}

fn is_csv<'a>(entry: &'a &PathBuf) -> bool {
    match entry.extension() {
        Some(ext) => ext == "csv",
        None => false,
    }
}

/// Opens a SQLite database at the given path.
pub fn connect(path: &Path, opts: Options) -> Result<Connection, Error> {
    let conn = Connection::open(path)?;
    conn.set_prepared_statement_cache_capacity(20);
    conn.pragma_update(None, "cache_size", &"100000")?;
    conn.pragma_update(None, "foreign_keys", &"off")?;
    conn.pragma_update(None, "synchronous", &opts.synchronous.to_string())?;
    conn.pragma_update(None, "journal_mode", &opts.journal.to_string())?;

    Ok(conn)
}

/// Runs all operations that set up the schema and the documentation. Effectively noop if
/// everything is in place.
pub fn bootstrap(conn: &Connection) -> Result<(), Error> {
    let bootstrap = include_str!("./sql/bootstrap.sql");

    conn.execute_batch(&bootstrap)?;

    Ok(())
}

/// The next volume name is the index of the next file expected to be processed.
///
/// Files are named with with the pattern `{product}_{bundle_type}_{issue_date}_{index}.csv`.
/// For example, `AddressBasePremium_FULL_2020-06-06_001.csv`.
pub fn next_index(conn: &Connection) -> Result<Option<u32>, Error> {
    let query_result: Result<u32, _> = conn.query_row(
        r#"
        SELECT next_volume_name
        FROM trailer
        ORDER BY next_volume_name DESC
        LIMIT 1;
        "#,
        NO_PARAMS,
        |row| row.get(0),
    );

    match query_result {
        Ok(value) => {
            // The last trailer uses `0` to indicate there is no next value.
            if value == 0 {
                Ok(None)
            } else {
                Ok(Some(value))
            }
        }
        Err(SqlError::QueryReturnedNoRows) => Ok(Some(1)),
        Err(e) => Err(Error::from(e)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use anyhow::Result;
    use rusqlite::{Connection, Error as SqlError, NO_PARAMS};

    #[test]
    fn trailer_no_table() {
        let conn = Connection::open_in_memory().expect("Testing in-memory database.");
        let actual = next_index(&conn);

        assert!(actual.is_err(), "expected an error");

        match actual.unwrap_err() {
            PackError::MissingTable(_) => assert!(true),
            _ => assert!(false, "expected a MissingTable"),
        };
    }

    #[test]
    fn trailer_empty() -> Result<()> {
        let conn = Connection::open_in_memory().expect("Testing in-memory database.");
        bootstrap(&conn)?;
        let actual = next_index(&conn)?;

        assert_eq!(actual, Some(1));

        Ok(())
    }

    #[test]
    fn trailer_next() -> Result<()> {
        let conn = Connection::open_in_memory().expect("Testing in-memory database.");
        bootstrap(&conn)?;
        conn.execute(
            "INSERT INTO trailer VALUES (?, ?, ?, ?, ?)",
            &["99", "2", "1000000", "2020-06-06", "05:20:14"],
        )?;

        let actual = next_index(&conn)?;

        assert_eq!(actual, Some(2));

        Ok(())
    }

    #[test]
    fn trailer_end() -> Result<()> {
        let conn = Connection::open_in_memory().expect("Testing in-memory database.");
        bootstrap(&conn)?;
        conn.execute(
            "INSERT INTO trailer VALUES (?, ?, ?, ?, ?)",
            &["99", "0", "1000000", "2020-06-06", "05:20:14"],
        )?;

        let actual = next_index(&conn)?;

        assert_eq!(actual, None);

        Ok(())
    }
}
