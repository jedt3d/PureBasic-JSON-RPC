# Building And Using The SQLite Admin MCP Server

This tutorial is a practical guide to the `sqlite-admin` MCP example. It is
written for developers who want to learn what an MCP server can do, how this
PureBasic JSON-RPC library fits the job, and how to build a useful local tool
server without first becoming an MCP specialist.

The short version: this example lets an MCP host ask a PureBasic console
program to administer an approved SQLite database. The server speaks MCP over
stdio, uses JSON-RPC messages, and exposes tools for bootstrap, schema
inspection, queries, writes, backups, maintenance, and saved SQL recipes.

The longer version is the rest of this guide.

## Path Convention

All repository paths in this tutorial are relative to the project root unless a
paragraph explicitly says a host requires an expanded local path. The examples
use `.local/...`, `.build/...`, and `MCP/examples/...` so the guide can be read
and copied without carrying a developer-specific workstation path.

## 1. What This Server Is For

SQLite is often the quiet workhorse inside desktop tools, local prototypes,
small automation systems, and test fixtures. The database is a single file, so
it is easy to move, copy, reset, and inspect. That same convenience creates a
common problem: a developer or AI assistant needs to answer simple questions
about the file, but a full database administration UI would be too much.

The SQLite Admin MCP server fills that space. It gives an MCP-capable AI host a
small, explicit set of tools:

- create a known demo/admin database from scratch;
- inspect tables, indexes, triggers, and raw schema SQL;
- run bounded row-returning SQL;
- run intentional write SQL;
- copy a database file to a backup path;
- run quick health checks and vacuum;
- store and reuse frequent SQL commands as named recipes.

This is not a hosted database service. It is a local developer-facing MCP
server. It runs as a macOS console executable and reads/writes protocol messages
through stdin/stdout.

## 2. What "SQLite Administration" Means Here

Administration in this example means safe local file administration plus SQL
execution. The server can create, open, query, update, back up, and check SQLite
files inside its allowed root. It does not delete database files in v1.

The default allowed root is this project-root-relative directory:

```text
.local/sqlite-admin/
```

The default database is this project-root-relative file:

```text
.local/sqlite-admin/demo.sqlite
```

The server rejects paths that try to escape that root. This keeps the example
useful while avoiding a tool that can wander across the filesystem.

## 3. How MCP, JSON-RPC, stdio, PureBasic, And SQLite Fit Together

MCP gives AI applications a common way to discover and call external tools.
JSON-RPC gives those calls a compact request/response envelope. The stdio
transport lets a host launch a local executable and exchange newline-delimited
UTF-8 JSON messages with it.

PureBasic is a good fit for this example because it can compile a small native
console executable and includes built-in database support for SQLite. The server
does not need a Node.js runtime, Python environment, or local web server.

The flow looks like this:

```text
MCP host
  |
  | newline-delimited JSON-RPC over stdin/stdout
  v
sqlite_admin_server
  |
  | JSON-RPC dispatcher
  v
MCP lifecycle and tools layer
  |
  | sqlite/bootstrap, sqlite/query, sqlite/recipe/run, ...
  v
PureBasic SQLite database API
  |
  v
.local/sqlite-admin/demo.sqlite
```

The important stdio rule is simple:

```text
stdout = protocol messages only
stderr = diagnostics and logs
```

If normal logs leak onto stdout, the MCP host may try to parse them as JSON-RPC
messages. That is why the server is built as an explicit Console target and why
the examples avoid ordinary status output from the stdio server.

## 4. Build On macOS

This v1 example targets macOS. The repository expects PureBasic 6.40 and the
project harness already knows where to find the local compiler installation.

From the repository root, build every configured project target:

```sh
./tools/build.sh
```

The SQLite example project file is:

```text
MCP/examples/sqlite-admin/sqlite_admin.pbp
```

It contains three Console targets:

```text
sqlite-admin stdio server -> .build/MCP/examples/sqlite-admin/sqlite_admin_server
sqlite-admin bootstrap    -> .build/MCP/examples/sqlite-admin/sqlite_admin_bootstrap
sqlite-admin probe        -> .build/MCP/examples/sqlite-admin/sqlite_admin_probe
```

The `.pbp` file is part of the source contract. It records that these are
console programs, so both the PureBasic IDE and the command-line harness build
the correct kind of binary.

## 5. Create The Demo Database From Scratch

Use the helper script:

```sh
MCP/examples/sqlite-admin/scripts/create_demo_db.sh
```

The script builds the project and runs the bootstrap target. It creates:

- `admin_notes`, a small multilingual sample table;
- `sql_recipes`, the catalog of saved SQL commands;
- sample rows in English, Thai, Japanese, and accented Latin text;
- two starter recipes, `list-notes` and `notes-by-locale`.

You can also run the compiled bootstrap program directly after building:

```sh
./.build/MCP/examples/sqlite-admin/sqlite_admin_bootstrap
```

To write a database with a different approved path:

```sh
./.build/MCP/examples/sqlite-admin/sqlite_admin_bootstrap demo-copy.sqlite
```

Relative paths are resolved inside `.local/sqlite-admin/`.

## 6. Run Probe Inputs Without An External MCP Client

The probe files are newline-delimited JSON messages. They let you test the
stdio server without configuring a full MCP host.

Smoke probe:

```sh
./.build/MCP/examples/sqlite-admin/sqlite_admin_server \
  < MCP/examples/sqlite-admin/probe_smoke_input.ndjson
```

Full probe:

```sh
./.build/MCP/examples/sqlite-admin/sqlite_admin_server \
  < MCP/examples/sqlite-admin/probe_input.ndjson
```

Compiled scenario:

```sh
./.build/MCP/examples/sqlite-admin/sqlite_admin_probe
```

The compiled scenario calls the same dispatcher path as the stdio server. It is
useful when you want test-style pass/fail output without reading raw JSON-RPC.

## 7. Register With An MCP Host

Every MCP host has its own configuration format, but the shape is usually the
same: register a command that launches the stdio server.

Many MCP hosts want the command expanded to a real local executable path. In
project documentation, write it with the project-root placeholder:

```json
{
  "mcpServers": {
    "sqlite-admin": {
      "command": "<project-root>/.build/MCP/examples/sqlite-admin/sqlite_admin_server"
    }
  }
}
```

Expand `<project-root>` for the local host configuration if that host cannot
resolve relative commands. Run the host from the repository root when you want
the default allowed root to be `.local/sqlite-admin/` in this project. A future
hardened server could accept an explicit configuration file or environment
variable for the allowed root, but this example keeps configuration deliberately
small.

## 8. The MCP Messages

The stdio transport uses one JSON-RPC message per line. The examples below are
shown across multiple lines for readability. In the probe files, each request is
one physical line.

### initialize

The host starts by asking the server to initialize:

```json
{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"manual-probe","version":"0.1.0"}},"id":1}
```

The response includes the protocol version, server information, and tool
capabilities.

Then the host sends the initialized notification:

```json
{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}
```

### tools/list

Tool discovery asks the server what it can do:

```json
{"jsonrpc":"2.0","method":"tools/list","params":{},"id":2}
```

The result contains names such as `sqlite/bootstrap`, `sqlite/query`, and
`sqlite/recipe/run`, each with a JSON input schema.

## 9. Bootstrap The Database

Call `sqlite/bootstrap` through `tools/call`:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/bootstrap","arguments":{"dbPath":"demo.sqlite","overwrite":true}},"id":3}
```

The tool creates or recreates the database inside the allowed root. If
`overwrite` is false and the file already exists, the tool returns an MCP tool
result with `isError: true`.

The bootstrap tool is intentionally separate from the stdio server startup. A
host can inspect tools without changing local data, and a user can choose when
to create or reset the demo database.

## 10. Inspect Schema And Table Metadata

Use `sqlite/inspect`:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/inspect","arguments":{"dbPath":"demo.sqlite","includeSystem":false}},"id":4}
```

The tool reads from `sqlite_schema` and returns a bounded JSON text payload. It
shows schema object type, name, table name, and raw SQL.

This is often the first safe step before running a query. Ask the model to
inspect the schema, then have it explain what it found before it writes SQL.

## 11. Run SELECT Queries Safely

Use `sqlite/query` for row-returning SQL:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/query","arguments":{"dbPath":"demo.sqlite","sql":"SELECT id, locale, title FROM admin_notes ORDER BY id","maxRows":10}},"id":5}
```

The result text contains:

- `columns`, the returned column names;
- `rows`, an array of arrays;
- `rowCount`, the total rows read;
- `returnedRows`, the number included in the response;
- `truncated`, whether the result was larger than `maxRows`.

Prefer `sqlite/query` for exploration. It keeps output bounded and makes it
clear when a result was truncated.

## 11A. Export Query Results To CSV, ODS, Or XLSX

Use `sqlite/export` when a query result should become a file that another tool
can open:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/export","arguments":{"dbPath":"demo.sqlite","sql":"SELECT id, locale, title FROM admin_notes ORDER BY id","outputPath":"exports/admin-notes.csv","format":"csv","maxRows":5000,"overwrite":true}},"id":50}
```

The export path is resolved inside the same allowed root as database files. The
example above writes:

```text
.local/sqlite-admin/exports/admin-notes.csv
```

CSV is deliberately opinionated in v1. There is no prompt or option to weaken
the format:

- the file is UTF-8 with a BOM;
- the first row is a header row;
- row endings are CRLF;
- every field is wrapped in double quotes;
- embedded double quotes are escaped by doubling them;
- embedded commas and line breaks remain inside quoted fields;
- SQLite `NULL` values are exported as empty quoted fields;
- `maxRows` bounds the file size and the result reports `truncated`.

That strictness prevents the most common CSV export bugs: mojibake in
spreadsheet tools, commas splitting a value into extra columns, quotes breaking
the row, and line breaks corrupting the next record.

ODS is the OpenDocument spreadsheet export. Use `format: "ods"` and an `.ods`
output path:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/export","arguments":{"dbPath":"demo.sqlite","sql":"SELECT id, locale, title FROM admin_notes ORDER BY id","outputPath":"exports/admin-notes.ods","format":"ods","maxRows":5000,"overwrite":true}},"id":51}
```

The ODS writer creates a minimal OpenDocument Spreadsheet package:

```text
admin-notes.ods
  mimetype
  META-INF/manifest.xml
  content.xml
  styles.xml
  meta.xml
```

The package declares the OpenDocument spreadsheet media type, stores spreadsheet
rows in `content.xml`, and creates one sheet named `QueryResult`. In this first
version, every exported value is written as a string cell. That keeps the writer
predictable for administration output: IDs, dates, multilingual text, and SQL
results arrive exactly as SQLite returned them, without formula evaluation or
spreadsheet type guessing. Embedded XML-sensitive characters are escaped, and
line breaks inside text values are represented as OpenDocument text line breaks.

ODS is useful when the receiver wants an actual spreadsheet file rather than a
text interchange format. LibreOffice and OpenOffice use ODS natively, and many
spreadsheet applications can import it.

XLSX is the Excel workbook export. Use `format: "xlsx"` and an `.xlsx` output
path:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/export","arguments":{"dbPath":"demo.sqlite","sql":"SELECT id, locale, title FROM admin_notes ORDER BY id","outputPath":"exports/admin-notes.xlsx","format":"xlsx","maxRows":5000,"overwrite":true}},"id":52}
```

The XLSX writer creates a minimal macro-free Office Open XML workbook package:

```text
admin-notes.xlsx
  [Content_Types].xml
  _rels/.rels
  docProps/app.xml
  docProps/core.xml
  xl/workbook.xml
  xl/_rels/workbook.xml.rels
  xl/worksheets/sheet1.xml
  xl/styles.xml
```

The workbook contains one sheet named `QueryResult`. In this first version,
every exported value is written as an inline string cell. The package does not
include macros, formulas, pivot tables, charts, shared strings, or typed number
conversion. That is intentional for the first Excel export: the file should be a
clear table-shaped handoff of exactly what SQLite returned.

The practical format ranking for PureBasic is now:

```text
CSV  -> easiest: plain UTF-8 text, implemented
ODS  -> medium: ZIP package plus simpler OpenDocument XML tables, implemented
XLSX -> harder: ZIP package plus OOXML workbook relationships, implemented
```

XLSX is useful when the receiver expects an Excel workbook and you do not want
them to go through a CSV import dialog. The v1 writer is a table export, not an
Excel automation layer. If you need formulas, styled workbooks, multiple sheets,
typed numeric/date cells, or charts, treat those as later enhancements.

## 11B. Export The Same Query To Multiple Formats

In real administration work, export is rarely a single-file decision. You may
want a strict CSV for another script, an ODS spreadsheet for a LibreOffice user,
an XLSX workbook for an Excel user, and a saved SQL recipe so the export can be
repeated next week. The important habit is to keep the SQL stable and change
only the export format and output path.

Think about the export as three layers:

```text
SQL query
  -> one reviewed SELECT statement
  -> bounded by maxRows
  -> exported into one or more file formats
```

The `sqlite/export` tool intentionally uses the same input shape for CSV, ODS,
and XLSX:

```json
{
  "dbPath": "demo.sqlite",
  "sql": "SELECT id, locale, title FROM admin_notes ORDER BY id",
  "outputPath": "exports/admin-notes.csv",
  "format": "csv",
  "maxRows": 5000,
  "overwrite": true
}
```

Only two fields usually change between formats:

- `format`, such as `csv`, `ods`, or `xlsx`;
- `outputPath`, whose extension must match the selected format.

That design matters when an AI model is helping you. You can ask the model to
prepare one query, review that query, and then ask it to export the exact same
query to every format you need. If the CSV, ODS, and XLSX files were produced
from different SQL strings, later comparison becomes noisy and trust goes down.

### Step 1: Preview The Query

Before exporting, run the query through `sqlite/query` with a small `maxRows`.
This is the moment to catch missing filters, surprising sort order, or columns
that should not leave the database.

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/query","arguments":{"dbPath":"demo.sqlite","sql":"SELECT id, locale, title FROM admin_notes ORDER BY id","maxRows":5}},"id":60}
```

Read the returned columns and the first few rows. For sensitive data, this is
also where you remove private columns before generating files.

### Step 2: Export CSV For Interchange

CSV is the right first export when another program, shell script, database
loader, or spreadsheet import flow needs plain text.

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/export","arguments":{"dbPath":"demo.sqlite","sql":"SELECT id, locale, title FROM admin_notes ORDER BY id","outputPath":"exports/admin-notes.csv","format":"csv","maxRows":5000,"overwrite":true}},"id":61}
```

The response text should include:

```json
{
  "format": "csv",
  "encoding": "UTF-8 with BOM",
  "quotedFields": true,
  "lineEnding": "CRLF",
  "exportedRows": 4,
  "truncated": false
}
```

Those fields are not decoration. They are the contract. Every field is quoted,
embedded quotes are doubled, multilingual text remains UTF-8, and row endings
are predictable for spreadsheet tools.

To inspect the result on macOS:

```sh
sed -n '1,5p' .local/sqlite-admin/exports/admin-notes.csv
```

You should see a header row followed by data rows. The fields will be wrapped in
double quotes even when quoting was not strictly necessary.

### Step 3: Export ODS For Spreadsheet Users

ODS is better when the receiver expects a spreadsheet document rather than a
text file. It is also easier to hand to someone using LibreOffice or OpenOffice,
because the file already has a spreadsheet package structure.

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/export","arguments":{"dbPath":"demo.sqlite","sql":"SELECT id, locale, title FROM admin_notes ORDER BY id","outputPath":"exports/admin-notes.ods","format":"ods","maxRows":5000,"overwrite":true}},"id":62}
```

The response text should include:

```json
{
  "format": "ods",
  "mediaType": "application/vnd.oasis.opendocument.spreadsheet",
  "encoding": "UTF-8 XML",
  "sheet": "QueryResult",
  "stringCells": true,
  "exportedRows": 4,
  "truncated": false
}
```

The first ODS implementation writes every value as a string cell. That is
intentional. Administration exports should preserve what SQLite returned rather
than guessing which values are dates, numbers, identifiers, formulas, or text.
Later versions can add typed cells, but the safe v1 behavior is exact text.

To inspect the ODS package without opening a spreadsheet app:

```sh
unzip -l .local/sqlite-admin/exports/admin-notes.ods
unzip -p .local/sqlite-admin/exports/admin-notes.ods mimetype
unzip -p .local/sqlite-admin/exports/admin-notes.ods content.xml | sed -n '1,8p'
```

The package should contain:

```text
mimetype
META-INF/manifest.xml
content.xml
styles.xml
meta.xml
```

The `mimetype` content should be exactly:

```text
application/vnd.oasis.opendocument.spreadsheet
```

### Step 4: Export XLSX For Excel Users

XLSX is better when the receiver expects a native Excel workbook. It avoids the
CSV import dialog and gives the file a workbook/sheet structure immediately.

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/export","arguments":{"dbPath":"demo.sqlite","sql":"SELECT id, locale, title FROM admin_notes ORDER BY id","outputPath":"exports/admin-notes.xlsx","format":"xlsx","maxRows":5000,"overwrite":true}},"id":63}
```

The response text should include:

```json
{
  "format": "xlsx",
  "mediaType": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  "encoding": "UTF-8 XML in OOXML ZIP",
  "sheet": "QueryResult",
  "stringCells": true,
  "inlineStrings": true,
  "macroFree": true,
  "exportedRows": 4,
  "truncated": false
}
```

The XLSX export is macro-free and uses inline string cells. That means the
workbook is meant to be opened, reviewed, and possibly reformatted by a person,
not used as an Excel programming model. IDs, dates, and numbers are preserved as
text in v1 so the export does not silently change account codes, leading zeros,
locale-specific dates, or multilingual text.

To inspect the XLSX package without opening Excel:

```sh
unzip -l .local/sqlite-admin/exports/admin-notes.xlsx
unzip -p .local/sqlite-admin/exports/admin-notes.xlsx '\[Content_Types\].xml' | sed -n '1,12p'
unzip -p .local/sqlite-admin/exports/admin-notes.xlsx xl/workbook.xml
unzip -p .local/sqlite-admin/exports/admin-notes.xlsx xl/worksheets/sheet1.xml | sed -n '1,8p'
```

The package should contain the workbook and worksheet parts:

```text
[Content_Types].xml
_rels/.rels
docProps/app.xml
docProps/core.xml
xl/workbook.xml
xl/_rels/workbook.xml.rels
xl/worksheets/sheet1.xml
xl/styles.xml
```

`xl/workbook.xml` should name the sheet `QueryResult`, and
`xl/worksheets/sheet1.xml` should contain rows and cells with `inlineStr`
values.

### Step 5: Compare The Exports

CSV, ODS, and XLSX are different containers, so you do not compare the files
byte for byte. Compare their intent:

```text
same SQL
same maxRows
same exportedRows
same truncated flag
same visible columns
same row order
```

If `exportedRows` differs, check that both calls used the same SQL and the same
`maxRows`. If one response says `truncated: true`, treat the export as a sample,
not a complete extract.

A useful naming convention is:

```text
exports/<topic>-<date>.csv
exports/<topic>-<date>.ods
exports/<topic>-<date>.xlsx
```

For example:

```text
exports/admin-notes-2026-06-23.csv
exports/admin-notes-2026-06-23.ods
exports/admin-notes-2026-06-23.xlsx
```

The server does not create dates in filenames for you. Ask the MCP client or
your own workflow to choose names that make sense for audit and handoff.

### Step 6: Save The Export Query As A Recipe

Once an export query is useful, save it. Recipes keep the SQL close to the
database and make repeated exports less error-prone.

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/recipe/save","arguments":{"dbPath":"demo.sqlite","name":"export-admin-notes","description":"Export admin note summary columns in stable order","category":"exports","sql":"SELECT id, locale, title FROM admin_notes ORDER BY id","parameterNotes":"No parameters"}},"id":64}
```

Later, you can run the recipe to preview the rows:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/recipe/run","arguments":{"dbPath":"demo.sqlite","name":"export-admin-notes","maxRows":5}},"id":65}
```

The current `sqlite/export` tool accepts raw SQL, not a recipe name. The
practical pattern is:

```text
save recipe -> run recipe for preview -> copy reviewed SQL into sqlite/export
```

That keeps export mechanics simple while still giving you a catalog of reviewed
queries.

### Choosing The Format

Use this quick decision table:

| Need | Prefer | Why |
| --- | --- | --- |
| Import into another program | CSV | Plain text, easy to parse, stable quoting |
| Open in LibreOffice or OpenOffice | ODS | Native spreadsheet package |
| Send a human-readable spreadsheet to Excel users | XLSX | Opens as a workbook without CSV import choices |
| Send a human-readable spreadsheet to open-format users | ODS | Native OpenDocument package |
| Inspect in a terminal | CSV | Works with `sed`, `head`, `awk`, and scripts |
| Preserve exact returned text | CSV, ODS, or XLSX | All current formats write SQLite values as text |
| Spreadsheet formulas, charts, styling, or typed cells | Later XLSX work | The current XLSX writer is a simple table export |

When you are unsure, export CSV plus one spreadsheet package from the same
reviewed SQL. CSV is the audit-friendly interchange artifact; ODS is the
open-format spreadsheet artifact; XLSX is the Excel-friendly artifact.

### Common Mistakes

The export tool rejects several mistakes before writing files:

- `format: "ods"` with an output path ending in `.csv`;
- `format: "csv"` with an output path ending in `.ods`;
- `format: "xlsx"` with an output path ending in `.ods` or `.csv`;
- paths that try to escape the allowed SQLite root;
- overwriting an existing file without `overwrite: true`;
- invalid JSON argument types, such as a string where `maxRows` should be an
  integer.

SQLite errors, such as a misspelled table name, are returned as MCP tool results
with `isError: true`. Argument errors, such as a mismatched extension, are
returned as JSON-RPC invalid params errors. That distinction is useful when you
are debugging an MCP client: invalid params means the tool call shape is wrong;
`isError: true` means the call shape was accepted but the database/export work
failed.

### A Good Client Prompt

When using an MCP host with this server, give the model a precise export task:

```text
Inspect demo.sqlite, prepare a SELECT query for admin note id, locale, and
title ordered by id, show me the query for review, then export the same reviewed
query to exports/admin-notes.csv, exports/admin-notes.ods, and
exports/admin-notes.xlsx with maxRows 5000. Do not run sqlite/execute.
```

That prompt asks for review before export, fixes the output formats, and blocks
write SQL. It is the kind of instruction that keeps an AI-assisted database
session calm and auditable.

## 12. Run Write SQL Intentionally

Use `sqlite/execute` for non-row SQL:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/execute","arguments":{"dbPath":"demo.sqlite","sql":"INSERT INTO admin_notes(locale,title,body) VALUES ('en','Checklist','Back up before risky writes')"}},"id":6}
```

The server does not try to understand whether a SQL statement is "safe." It is
an administration tool, so it allows DDL, writes, PRAGMA updates, and other
non-row commands through `sqlite/execute`. The safety boundary is the approved
database path, bounded output, and an explicit tool name that separates writes
from reads.

For AI-assisted work, a good pattern is:

```text
inspect schema -> propose SQL -> user reviews -> backup -> execute -> query to verify
```

## 13. Back Up Before Risky Operations

Use `sqlite/backup`:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/backup","arguments":{"dbPath":"demo.sqlite","backupPath":"demo-before-update.sqlite","overwrite":true}},"id":7}
```

Both paths must stay inside the allowed root. The server copies the SQLite file;
it does not delete old files in v1.

Backups are especially important before:

- schema migrations;
- bulk updates;
- deletes;
- vacuuming a database that you cannot easily recreate.

## 14. Run Maintenance

Use `sqlite/maintenance`:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/maintenance","arguments":{"dbPath":"demo.sqlite","operation":"quick_check"}},"id":8}
```

Supported operations:

- `quick_check`
- `integrity_check`
- `vacuum`

`quick_check` is usually the first health check. `integrity_check` is deeper.
`vacuum` rewrites the database file to rebuild storage and reclaim free pages.

## 15. Save And Reuse SQL Recipes

Recipes are saved SQL commands stored in the `sql_recipes` table. They are for
queries you run often enough that you want a stable name and description.

Save a recipe:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/recipe/save","arguments":{"dbPath":"demo.sqlite","name":"recent-notes","description":"Show recently inserted notes","category":"demo","sql":"SELECT id, locale, title, created_at FROM admin_notes ORDER BY id DESC LIMIT :limit","parameterNotes":"limit: maximum rows to return"}},"id":9}
```

List recipes:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/recipe/list","arguments":{"dbPath":"demo.sqlite"}},"id":10}
```

Run a recipe:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/recipe/run","arguments":{"dbPath":"demo.sqlite","name":"recent-notes","parameters":{"limit":"5"},"maxRows":10}},"id":11}
```

Delete a recipe:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/recipe/delete","arguments":{"dbPath":"demo.sqlite","name":"recent-notes"}},"id":12}
```

In v1, `sqlite/recipe/run` is intended for row-returning recipes. Use
`sqlite/execute` directly for write statements. Recipe parameters are simple
named scalar values that replace placeholders like `:locale` or `:limit`.

## 16. UTF-8 And Multilingual Data

The bootstrap database includes rows in:

- English;
- Thai;
- Japanese;
- accented Latin text.

Exact matching works:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/query","arguments":{"dbPath":"demo.sqlite","sql":"SELECT title FROM admin_notes WHERE title = 'สวัสดี'","maxRows":5}},"id":13}
```

The point of the test is round-trip correctness: the same text that goes into
SQLite comes back out unchanged.

What v1 does not promise is full Unicode case-insensitive search. SQLite's
built-in `NOCASE`, `LIKE`, `upper()`, and `lower()` are not complete Unicode
case-folding systems without ICU or a custom collation. For multilingual search
in this example, prefer exact values or explicit normalized fields that your
application controls.

## 17. Complete First Session Walkthrough

This is a good first learning session.

Build:

```sh
./tools/build.sh
```

Create the demo database:

```sh
MCP/examples/sqlite-admin/scripts/create_demo_db.sh
```

Inspect the schema:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/inspect","arguments":{"dbPath":"demo.sqlite","includeSystem":false}},"id":20}
```

Read sample rows:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/query","arguments":{"dbPath":"demo.sqlite","sql":"SELECT id, locale, title FROM admin_notes ORDER BY id","maxRows":20}},"id":21}
```

Back up before writing:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/backup","arguments":{"dbPath":"demo.sqlite","backupPath":"demo-first-session.sqlite","overwrite":true}},"id":22}
```

Insert one row:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/execute","arguments":{"dbPath":"demo.sqlite","sql":"INSERT INTO admin_notes(locale,title,body) VALUES ('en','First session','Inserted through sqlite/execute')"}},"id":23}
```

Verify it:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/query","arguments":{"dbPath":"demo.sqlite","sql":"SELECT id, title, body FROM admin_notes WHERE title = 'First session'","maxRows":5}},"id":24}
```

Save a recipe:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/recipe/save","arguments":{"dbPath":"demo.sqlite","name":"notes-by-title","description":"Find notes by exact title","category":"lookup","sql":"SELECT id, locale, title, body FROM admin_notes WHERE title = :title","parameterNotes":"title: exact title text"}},"id":25}
```

Run it:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/recipe/run","arguments":{"dbPath":"demo.sqlite","name":"notes-by-title","parameters":{"title":"First session"},"maxRows":5}},"id":26}
```

Run a health check:

```json
{"jsonrpc":"2.0","method":"tools/call","params":{"name":"sqlite/maintenance","arguments":{"dbPath":"demo.sqlite","operation":"quick_check"}},"id":27}
```

At this point you have built the server, created a database, inspected schema,
read data, backed up the file, executed a write, verified the write, saved a
recipe, run the recipe, and checked database health.

## 18. Common Failure Cases

### The server exits immediately

The stdio server reads until stdin closes. If you run it directly in a terminal
without typing messages, it may appear idle. Feed a probe file or register it
with an MCP host.

### The host cannot parse responses

Check that no diagnostic text is printed to stdout. MCP stdio stdout must carry
protocol messages only.

### A path is rejected

Paths must stay inside `.local/sqlite-admin/` by default. Avoid `..`, `~`, and
absolute paths outside the allowed root. Tool results report project-root-relative
paths whenever they point back into this repository.

### A SELECT returns too few rows

Check the `truncated` flag and raise `maxRows` up to the allowed maximum.

### A write failed

`sqlite/execute` returns an MCP tool result with `isError: true` when SQLite
rejects the SQL. Read the returned text for the SQLite error message, inspect
the schema, and try the smallest statement that reproduces the problem.

### Unicode matching surprises you

Exact UTF-8 storage and exact matching are supported. Unicode-aware
case-insensitive matching is not part of v1. Store normalized search fields if
your application needs them.

## 19. Responsible Admin Checklist

Before allowing a model to run SQL against a real database, walk through this
checklist:

- Confirm the database path is inside the intended allowed root.
- Inspect the schema first.
- Ask for the proposed SQL in plain text before executing writes.
- Prefer `sqlite/query` for exploration.
- Back up before `sqlite/execute` statements that change data or schema.
- Use small `maxRows` values during exploration.
- Treat recipes as reviewed commands, not arbitrary hidden instructions.
- Keep secrets and production credentials out of local demo databases.
- Remember that this example is not a sandbox.

## 20. Where To Go Next

This example proves the foundation: PureBasic can build a native stdio MCP
server that administers a local SQLite file through a generic JSON-RPC/MCP
library. Natural next steps include a configurable allowed root, richer recipe
parameter validation, a read-only mode, migration helpers, resource endpoints,
prompt templates, and deeper SQLite metadata formatting.

The current shape is intentionally small enough to read. That matters: an MCP
server that can run SQL should be understandable before it becomes powerful.
