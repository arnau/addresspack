// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

use csv;
use rusqlite::Error as SqlError;
use std::{io, num};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum PackError {
    #[error("file not found")]
    Io(#[from] io::Error),
    #[error("csv issue")]
    Csv(#[from] csv::Error),
    #[error("unexpected integer")]
    ParseInt(#[from] num::ParseIntError),
    #[error("unexpected input")]
    BadInput(String),
    #[error("cache error")]
    CacheError(String),
    #[error("missing table")]
    MissingTable(String),
    #[error("sql issue")]
    Sql(SqlError),
    #[error("unknown pragma value")]
    Pragma(String),
}

impl From<SqlError> for PackError {
    fn from(err: SqlError) -> Self {
        match &err {
            SqlError::SqliteFailure(_, value) => match value {
                None => PackError::Sql(err),
                Some(msg) => {
                    if msg.starts_with("no such table") {
                        PackError::MissingTable(msg.clone())
                    } else {
                        PackError::Sql(err)
                    }
                }
            },
            _ => PackError::Sql(err),
        }
    }
}
