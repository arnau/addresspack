// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

use anyhow::Result;
use rusqlite::{Connection, NO_PARAMS};
use std::collections::HashMap;

pub type Cache = HashMap<u32, String>;

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

/// Caches an insert statement for each table.
pub fn prepare_inserts(conn: &Connection) -> Result<Cache> {
    let mut stmt = conn.prepare(SELECT_TABLE_INFO)?;

    let cache: Cache = stmt
        .query_map(NO_PARAMS, |row| {
            let id: u32 = row.get(0)?;
            let name: String = row.get(1)?;
            let len: u32 = row.get(2)?;
            let vals = ["?"].repeat(len as usize);

            Ok((
                id,
                format!("INSERT INTO {} VALUES ({});", &name, vals.join(", ")),
            ))
        })?
        .collect::<Result<_, _>>()?;

    Ok(cache)
}
