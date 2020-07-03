// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

// use chrono::prelude::*;

use clap::{AppSettings, Clap};

use addresspack::cli;

#[derive(Debug, Clap)]
enum Subcommand {
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
