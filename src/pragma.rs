// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

use anyhow::Result;
use std::fmt;
use std::str::FromStr;

use super::PackError;

/// Represents the SQLite pragma `synchronous`.
///
/// See: https://www.sqlite.org/pragma.html#pragma_synchronous
#[derive(Clone, Debug)]
pub enum Synchronous {
    Off,
    Normal,
    Full,
    Extra,
}

impl fmt::Display for Synchronous {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Synchronous::Off => write!(f, "off"),
            Synchronous::Normal => write!(f, "normal"),
            Synchronous::Full => write!(f, "full"),
            Synchronous::Extra => write!(f, "extra"),
        }
    }
}

impl FromStr for Synchronous {
    type Err = PackError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "off" => Ok(Synchronous::Off),
            "normal" => Ok(Synchronous::Normal),
            "full" => Ok(Synchronous::Full),
            "extra" => Ok(Synchronous::Extra),
            _ => Err(PackError::Pragma(s.into())),
        }
    }
}

/// Represents the SQLite pragma `journal_mode`.
///
/// See: https://www.sqlite.org/pragma.html#pragma_journal_mode
#[derive(Clone, Debug)]
pub enum Journal {
    Off,
    Delete,
    Truncate,
    Persist,
    Memory,
    Wal,
}

impl fmt::Display for Journal {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Journal::Off => write!(f, "off"),
            Journal::Delete => write!(f, "delete"),
            Journal::Truncate => write!(f, "truncate"),
            Journal::Persist => write!(f, "persist"),
            Journal::Memory => write!(f, "memory"),
            Journal::Wal => write!(f, "wal"),
        }
    }
}

impl FromStr for Journal {
    type Err = PackError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "off" => Ok(Journal::Off),
            "delete" => Ok(Journal::Delete),
            "truncate" => Ok(Journal::Truncate),
            "persist" => Ok(Journal::Persist),
            "memory" => Ok(Journal::Memory),
            "wal" => Ok(Journal::Wal),
            _ => Err(PackError::Pragma(s.into())),
        }
    }
}
