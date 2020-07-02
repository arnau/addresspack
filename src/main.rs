// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

// use chrono::prelude::*;

use clap::{AppSettings, Clap};

use addresspack::cli;

#[derive(Debug, Clap)]
enum Subcommand {
    /// Loads AddressBase CSV into SQLite.
    ///
    /// By default the database will be created in the current directory with the filename
    /// `addresbase.sqlite` and will expect the decompressed CSVs to be in the `data` directory.
    ///
    /// By default, every 10 files (roughly 10 million records) works reasonably well with WAL
    /// journaling as it keeps the journal file from growing too much.
    ///
    /// Depending on how SQLite synchronises and the journal mode, you might want to tweak the
    /// `fpt` value.
    Load(cli::load::Cmd),
    // /// Queries AddressBase.
    // Query(cli::query::Cmd),
}

#[derive(Debug, Clap)]
#[clap(
    name = "addresspack",
    version,
    global_setting(AppSettings::ColoredHelp)
)]
struct Pack {
    #[clap(subcommand)]
    subcommand: Subcommand,
}

fn main() {
    let opts: Pack = Pack::parse();

    match opts.subcommand {
        Subcommand::Load(mut cmd) => match cmd.run() {
            Ok(msg) => {
                println!("{}", msg);
            }
            Err(err) => {
                eprintln!("{:?}", err);
            }
        },
    }
}
