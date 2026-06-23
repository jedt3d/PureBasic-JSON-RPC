# SQLite Admin MCP Server

This example is a macOS-focused stdio MCP server for administering approved
SQLite files from PureBasic. It is a real MCP server, not only a probe: it
responds to `initialize`, exposes tools through `tools/list`, and executes
tool calls through newline-delimited JSON-RPC on stdin/stdout.

The server intentionally keeps file access narrow. By default it manages files
under:

```text
.local/sqlite-admin/
```

It can create a demo database, inspect schema metadata, run bounded SELECT-like
queries, execute intentional write SQL, copy backups, run maintenance checks,
and save frequently used SQL recipes inside the database.

## Build

From the repository root:

```sh
./tools/build.sh
```

Open the PureBasic project file in the IDE:

```text
MCP/examples/sqlite-admin/sqlite_admin.pbp
```

The project contains three explicit Console targets:

- `sqlite-admin stdio server`
- `sqlite-admin bootstrap`
- `sqlite-admin probe`

Console targets are required for stdio MCP servers because protocol messages
must use stdin/stdout. Diagnostics belong on stderr.

## Create The Demo Database

```sh
MCP/examples/sqlite-admin/scripts/create_demo_db.sh
```

The default demo database is created at:

```text
.local/sqlite-admin/demo.sqlite
```

You can pass a custom database path inside the allowed root:

```sh
MCP/examples/sqlite-admin/scripts/create_demo_db.sh demo-copy.sqlite
```

## Run The Server

```sh
./.build/MCP/examples/sqlite-admin/sqlite_admin_server
```

Smoke-test initialization and `tools/list`:

```sh
./.build/MCP/examples/sqlite-admin/sqlite_admin_server \
  < MCP/examples/sqlite-admin/probe_smoke_input.ndjson
```

Run a longer local probe:

```sh
./.build/MCP/examples/sqlite-admin/sqlite_admin_server \
  < MCP/examples/sqlite-admin/probe_input.ndjson
```

Run the compiled dispatcher scenario:

```sh
./.build/MCP/examples/sqlite-admin/sqlite_admin_probe
```

## Tools

- `sqlite/bootstrap`: create or recreate the demo/admin database.
- `sqlite/inspect`: list schema metadata from `sqlite_schema`.
- `sqlite/query`: run row-returning SQL such as `SELECT` or `PRAGMA`.
- `sqlite/export`: export a row-returning query to canonical CSV, ODS, or XLSX.
- `sqlite/execute`: run intentional non-row SQL such as DDL, writes, `VACUUM`,
  and PRAGMA updates.
- `sqlite/backup`: copy a SQLite file to another approved path.
- `sqlite/maintenance`: run `quick_check`, `integrity_check`, or `vacuum`.
- `sqlite/recipe/list`: list saved SQL recipes.
- `sqlite/recipe/save`: save or update a named SQL recipe.
- `sqlite/recipe/run`: run a saved row-returning recipe with scalar parameters.
- `sqlite/recipe/delete`: remove a recipe from the catalog table.

## i18n Scope

The v1 i18n scope is data-only. The demo database stores UTF-8 text and includes
English, Thai, Japanese, and accented Latin sample rows. Exact multilingual
matching is supported and tested.

SQLite's built-in `NOCASE`, `LIKE`, `upper()`, and `lower()` are not complete
Unicode case-folding systems without ICU or a custom collation. This example
does not add ICU or localized UI text.

## CSV, ODS, And XLSX Export

`sqlite/export` supports three implemented formats:

- `csv`: UTF-8 CSV with a BOM, a header row, CRLF row endings, every field
  double-quoted, embedded quote characters doubled, and embedded commas,
  newlines, and multilingual text preserved inside quoted fields. Null values
  are exported as empty quoted fields.
- `ods`: OpenDocument Spreadsheet. The server writes a ZIP-based ODS package
  with `mimetype`, `META-INF/manifest.xml`, `content.xml`, `styles.xml`, and
  `meta.xml`. The exported sheet is named `QueryResult`, uses UTF-8 XML, and
  writes every result value as a string cell in v1.
- `xlsx`: macro-free Excel workbook. The server writes a ZIP-based Office Open
  XML package with workbook, worksheet, relationship, style, and document
  property parts. The exported sheet is named `QueryResult`, uses inline string
  cells, and writes every result value as text in v1.

Current effort from easiest to hardest in PureBasic is:

1. CSV: plain UTF-8 text, implemented.
2. ODS/OpenDocument Spreadsheet: ZIP plus XML files, implemented as a minimal
   table writer and importable by LibreOffice/OpenOffice and many spreadsheet
   tools.
3. XLSX: ZIP plus the larger OOXML workbook relationship model, useful but more
   code to create correctly, implemented as a macro-free text-cell workbook.

## Tutorial

Read the guide-book tutorial before wiring this server into an AI client:

```text
MCP/examples/sqlite-admin/TUTORIAL.md
```

It explains the first session, safe administration workflow, SQL recipes,
multilingual data behavior, multi-format CSV/ODS/XLSX export workflow, and the
responsible admin checklist.
