// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

//! A temporary record to work around csv -> sqlite.

use serde::Deserialize;

type Raw = Vec<Option<String>>;

#[derive(Debug, Clone, Deserialize, PartialEq)]
pub struct Record(Raw);
impl Record {
    pub fn new(raw: Raw) -> Self {
        Record(raw)
    }

    pub fn table_id(&self) -> String {
        self.0[0].clone().unwrap()
    }

    pub fn as_slice(&self) -> &[Option<String>] {
        &self.0
    }
}
