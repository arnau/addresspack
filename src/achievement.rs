// Copyright 2020 Arnau Siches

// Licensed under the MIT license <LICENCE or http://opensource.org/licenses/MIT>.
// This file may not be copied, modified, or distributed except
// according to those terms.

use std::fmt;

#[derive(Clone, Debug)]
pub enum Achievement {
    Noop,
    Done,
}

impl fmt::Display for Achievement {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        use Achievement as A;

        match self {
            A::Noop => write!(f, "There are no pending records to process."),
            A::Done => write!(f, "Finished processing all given records."),
        }
    }
}
