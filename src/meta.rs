// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

use rusqlite::{Connection, NO_PARAMS};
use std::collections::HashMap;

use crate::Error;

pub struct Cache(HashMap<u32, String>);

static SELECT_TABLE_INFO: &str = r#"
SELECT
    t.id,
    t.name,
    count(c.id) AS len
FROM column_info AS c
JOIN table_info AS t ON t.id = c.table_id
GROUP BY t.id
ORDER BY t.id;
"#;

impl Cache {
    /// Builds an insert statement for each table.
    pub fn prepare(conn: &Connection) -> Result<Cache, Error> {
        let mut stmt = conn.prepare(SELECT_TABLE_INFO)?;

        let cache: HashMap<u32, String> = stmt
            .query_map(NO_PARAMS, |row| {
                let id: u32 = row.get(0)?;
                let name: String = row.get(1)?;
                let len: u32 = row.get(2)?;
                let vals = ["?"].repeat(len as usize);
                let statement = format!("INSERT INTO {} VALUES ({});", &name, vals.join(", "));

                Ok((id, statement))
            })?
            .collect::<Result<_, _>>()?;

        Ok(Cache(cache))
    }

    pub fn get(&self, table_id: u32) -> Result<&str, Error> {
        let statement = self.0.get(&table_id).ok_or_else(|| {
            Error::CacheError(format!("Expected a cached sql statement for {}", &table_id))
        })?;

        Ok(statement)
    }
}
