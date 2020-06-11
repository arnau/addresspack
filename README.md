# Addresspack

This project processes a standard AddressBase Premium (full) download in CSV
into a SQLite database.


## Context

AddressBase Premium CSV is a particular beast. The download is a ~8GB zip
file that contains around 352 files with a `.csv` extension.

Although these files are labelled as "csv" they are not structured as a table.
They have to be treated as a single list of comma-separated lines where each
one of them starts with the numeric identifier for the table they belong to.

So, to recompose the original relational model, you need to read the
[technical specification] and create the expected schema.

Perhaps you only want construct tabular CSV files and the [header files] are
sufficient.

At this point, you need to read the given files line by line, parse each line
as CSV, promote empty values as `NULL` perhaps, and load all ~352 million
records into their table.


## Why SQLite

I wouldn't qualify as good experience the journey you have to go through to
get from what Ordnance Survey gives you as CSV to the point where you are able
to run your first query against the AddressBase database.

SQLite is a single-file relational database with a good SQL engine. What would
be the experience if instead of downloading the CSV zip you could instead
download a SQLite database ready to be used? Perhaps the database could
include some metadata and documentation sufficient to let you get an
understanding of what is each table for and what are the relationships between
them. Similar to what you get in the technical specification but co-located
with the data.

Well, Addresspack is an exercise to explore this idea.

The bare schema before loading the full dataset provides `table_info` and
`column_info` which lets you explore the basic documentation for each table
and columns.

For example, to know why the first record of each file starts with a `10`, you
can:

```
sqlite3 addresspack.sqlite "select name, definition from table_info where id = 10;"
```

There is a knowledge gap here, you need to know that the first field of each
CSV record is the table identifier. Why it is labelled as "RECORD_IDENTIFIER"
in the [header files] escapes me.


## Getting the data

The [Ordnance Survey] website has an order's section where you can buy access
to the AddressBase Premium database. The one this repository expects is the
CSV with Download as a delivery method.


## Limitations

SQLite only allows a single writer so Addresspack can't use multiple threads
to parallelise. Although I tried to make the ingestion process fast, it is
extremely slow. In the order of hours.

At the moment, a transaction is commited every 10 files (i.e. every 10,000,000
inserts) using the [SQLite WAL] journaling. If the process stops (e.g. you
kill the process), you can run it again and it will resume where it stopped
with a potential data loss of 10 million rows.

If you have ideas or want to contribute to make it faster, you are more than
welcome to reach to me!

Another limitation is that Addresspack is only able to process the full
version of AddressBase Premium. I haven't looked at what would it mean to load
an data update.

## Impracticalities

The `application_cross_reference` table can be impractical to use due to its
size:

```
$ time sqlite3 addresspack.sqlite "select count(*) from application_cross_reference;"
191207473
2.26s user 29.48s system 21% cpu 2:29.76 total
```

So, if there is a need for a query that requires a full scan, expect it to be
slow.

Out of curiosity, this is the same count using [xsv] after exporting the
table to CSV:

```
$ time xsv count xref.csv
191207473
30.49s user 8.93s system 96% cpu 40.764 total
```

In any case, for more realistic queries like finding records for a particular
`xref_key`, SQLite is lightning fast whilst other means like [xsv] or [rg] are
slower.

And of course, SQLite is a single file for the whole database which was the
whole point of this exercise.


## Measurements

|file|size|
|----|----|
|AB76GB_CSV.zip|8.13 GB|
|AB76GB_CSV (unzipped, 352 files)|44 GB|
|addresspack.sqlite.zip|13.97 GB|
|addresspack.sqlite|46.6 GB|

|id|table|count|
|--|-----|-----|
|10|`header`|352|
|11|`street`|1439574|
|15|`street_descriptor`|1555308|
|21|`basic_land_property_unit`|39207495|
|23|`application_cross_reference`|191207473|
|24|`local_property_identifier`|43831026|
|28|`delivery_point_address`|29501884|
|29|`metadata`|352|
|30|`successor`|0|
|31|`organisation`|1268612|
|32|`classification`|43022571|
|99|`trailer`|352|


## Licence

The Addresspack codebase is licensed under the MIT licence (See
[LICENCE](./LICENCE)) unless explicitly stated at the top of the file.

Files that contain information taken from the AddressBase Premium [technical
specification] have an Ordnance Survey licence and are under © Ordnance Survey
Limited 2015.


[Ordnance Survey]: https://orders.ordnancesurvey.co.uk/orders/index.html
[technical specification]: https://www.ordnancesurvey.co.uk/documents/product-support/tech-spec/addressbase-premium-technical-specification.pdf
[header files]: http://www.os.uk/docs/product-schemas/addressbase-premium-header-files.zip
[SQLite WAL]: https://www.sqlite.org/wal.html
[xsv]: https://github.com/BurntSushi/xsv
[rg]: https://github.com/BurntSushi/ripgrep
