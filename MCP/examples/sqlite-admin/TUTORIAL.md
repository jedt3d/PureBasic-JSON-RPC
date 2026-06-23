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

The default allowed root is:

```text
.local/sqlite-admin/
```

The default database is:

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

Use an absolute path to the compiled executable:

```json
{
  "mcpServers": {
    "sqlite-admin": {
      "command": "/absolute/path/to/PureBasic-JSON-RPC/.build/MCP/examples/sqlite-admin/sqlite_admin_server"
    }
  }
}
```

Run the host from the repository root when you want the default allowed root to
be `.local/sqlite-admin/` in this project. A future hardened server could accept
an explicit configuration file or environment variable for the allowed root, but
this example keeps configuration deliberately small.

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
absolute paths outside the allowed root.

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
