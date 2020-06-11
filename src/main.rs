// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

// use chrono::prelude::*;

use anyhow::Result;
use csv;
use indicatif::{ProgressBar, ProgressStyle};
use itertools::Itertools;
use rusqlite::{Connection, Transaction};
use std::fs;
use std::io;
use std::path::{Path, PathBuf};

use addresspack::{
    bootstrap, connect, meta, next_index, pragma, Cache, Options, PackError, Record,
};

fn process_record(
    tx: &Transaction,
    cache: &Cache,
    bar: &ProgressBar,
    record: Record,
) -> Result<(), PackError> {
    let table_id: u32 = record.table_id().parse()?;
    let cached_sql = cache.get(&table_id).ok_or_else(|| {
        PackError::CacheError(format!("Expected a cached sql statement for {}", &table_id))
    })?;
    let mut stmt = tx.prepare_cached(cached_sql)?;

    stmt.execute(record.as_slice())?;

    bar.inc(1);

    Ok(())
}

fn process_csv(
    tx: &Transaction,
    cache: &Cache,
    bar: &ProgressBar,
    path: &Path,
) -> std::result::Result<(), PackError> {
    let mut rdr = csv::ReaderBuilder::new()
        .has_headers(false)
        .flexible(true)
        .from_path(&path)?;
    let mut raw_record = csv::ByteRecord::new();

    while rdr.read_byte_record(&mut raw_record)? {
        let record: Record = raw_record.deserialize(None)?;

        process_record(&tx, &cache, &bar, record)?;
    }

    Ok(())
}

fn process_input(
    conn: &mut Connection,
    cache: Cache,
    dir: &Path,
) -> std::result::Result<(), PackError> {
    if !dir.is_dir() {
        return Err(PackError::BadInput(format!(
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
            let record_amount = 1_000_000;

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
                .chunks(10)
            {
                let tx = conn.transaction()?;

                for entry in chunk {
                    process_csv(&tx, &cache, &bar, &entry)?;
                }

                tx.commit()?;
            }

            bar.finish();
        }
        None => println!("Nothing left to process"),
    };

    Ok(())
}

fn is_csv<'a>(entry: &'a &PathBuf) -> bool {
    match entry.extension() {
        Some(ext) => ext == "csv",
        None => false,
    }
}

fn main() -> Result<()> {
    let input_dir = Path::new("data");
    let db_path = Path::new("addresspack.sqlite");
    let opts = Options {
        synchronous: pragma::Synchronous::Normal,
        journal: pragma::Journal::Wal,
    };
    let mut conn = connect(db_path, opts)?;

    bootstrap(&conn)?;

    let cache = meta::prepare_inserts(&conn)?;

    process_input(&mut conn, cache, &input_dir)?;

    // Switch WAL off.
    conn.pragma_update(None, "wal_checkpoint", &"restart")?;
    conn.pragma_update(None, "journal_mode", &"delete")?;

    Ok(())
}
