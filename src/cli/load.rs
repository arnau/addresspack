// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

use clap::Clap;
use std::path::Path;

use crate::{bootstrap, connect, pragma, process_dir, Achievement, Error, Options};

/// Loads AddressBase CSV into SQLite.
///
/// The following commands are equivalent:
///
/// $    addresspack load
///
/// $    addresspack load --db-path ./addresspack.sqlite --data-path ./data/ --sync normal --journal wal --fpt 10
#[derive(Debug, Clap)]
pub struct Cmd {
    /// Path to the SQLite database.
    #[clap(long, value_name = "db_path", default_value = "./addresspack.sqlite")]
    db_path: String,

    /// Path to the directory with the decompressed CSV files.
    #[clap(long, value_name = "dir_path", default_value = "./data/")]
    data_path: String,

    /// Sets the synchronous pragma.
    ///
    /// See: https://www.sqlite.org/pragma.html#pragma_synchronous
    #[clap(long,
           value_name = "synchronous",
           default_value = "normal",
           possible_values = &["off", "normal", "full", "extra"])]
    sync: pragma::Synchronous,

    /// Sets the journal mode pragma.
    ///
    /// See: https://www.sqlite.org/pragma.html#journal_mode
    #[clap(long,
           value_name = "journal_mode",
           default_value = "wal",
           possible_values = &["off", "delete", "truncate", "persist", "memory", "wal"])]
    journal: pragma::Journal,

    /// Sets the amount of files to process before commiting a SQL transaction.
    ///
    /// Depending on how SQLite synchronises and the journal mode, you might want to tweak the
    /// `fpt` value.
    #[clap(long = "fpt", value_name = "amount", default_value = "10")]
    files_per_transaction: usize,
}

impl Cmd {
    pub fn run(&mut self) -> Result<Achievement, Error> {
        let db_path = Path::new(&self.db_path);
        let data_path = Path::new(&self.data_path);
        let fpt = self.files_per_transaction;
        let opts = Options {
            synchronous: self.sync.clone(),
            journal: self.journal.clone(),
        };
        let mut conn = connect(db_path, opts)?;

        bootstrap(&conn)?;

        let msg = process_dir(&data_path, &mut conn, fpt)?;

        // WAL persists across connections, this ensures it is switched off.
        if self.journal == pragma::Journal::Wal {
            conn.pragma_update(None, "wal_checkpoint", &"restart")?;
            conn.pragma_update(None, "journal_mode", &"delete")?;
        }

        Ok(msg)
    }
}
