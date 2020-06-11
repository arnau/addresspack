// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

use anyhow::Result;
use rusqlite::{Connection, Error as SqlError, NO_PARAMS};
use std::include_str;
use std::path::Path;

pub mod error;
pub mod meta;
pub mod pragma;
pub mod record;

pub use crate::error::PackError;
pub use crate::meta::Cache;
pub use crate::record::Record;

#[derive(Debug, Clone)]
pub struct Options {
    pub synchronous: pragma::Synchronous,
    pub journal: pragma::Journal,
}

/// Opens a SQLite database at the given path.
pub fn connect(path: &Path, opts: Options) -> Result<Connection> {
    let conn = Connection::open(path)?;
    conn.set_prepared_statement_cache_capacity(20);
    conn.pragma_update(None, "foreign_keys", &"off")?;
    conn.pragma_update(None, "synchronous", &opts.synchronous.to_string())?;
    conn.pragma_update(None, "journal_mode", &opts.journal.to_string())?;

    Ok(conn)
}

/// Runs all operations that set up the schema and the documentation. Effectively noop if
/// everything is in place.
pub fn bootstrap(conn: &Connection) -> Result<()> {
    let bootstrap = include_str!("./sql/bootstrap.sql");

    conn.execute_batch(&bootstrap)?;

    Ok(())
}

/// The next volume name is the index of the next file expected to be processed.
///
/// Files are named with with the pattern `{product}_{bundle_type}_{issue_date}_{index}.csv`.
/// For example, `AddressBasePremium_FULL_2020-06-06_001.csv`.
pub fn next_index(conn: &Connection) -> Result<Option<u32>, PackError> {
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
        Err(e) => Err(PackError::from(e)),
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
