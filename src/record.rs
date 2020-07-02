// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

//! A temporary record to work around csv -> sqlite.

use serde::Deserialize;

use crate::Error;

type Raw = Vec<Option<String>>;

#[derive(Debug, Clone, Deserialize, PartialEq)]
pub struct Record(Raw);
impl Record {
    pub fn new(raw: Raw) -> Self {
        Record(raw)
    }

    pub fn table_id(&self) -> Result<u32, Error> {
        let id: u32 = self.0[0].clone().expect("The record is empty.").parse()?;

        Ok(id)
    }

    pub fn as_slice(&self) -> &[Option<String>] {
        &self.0
    }
}
