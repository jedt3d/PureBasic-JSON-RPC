EnableExplicit

XIncludeFile "../../MCP/examples/sqlite-admin/sqlite_admin_tool.pbi"

PureUnitOptions(Thread)

Procedure.s SQLiteAdmin_TestRoot()
  Protected path.s

  path = GetPathPart(#PB_Compiler_FilePath)
  path = GetPathPart(Left(path, Len(path) - 1))
  path = GetPathPart(Left(path, Len(path) - 1))
  ProcedureReturn path + ".local/sqlite-admin-tests/"
EndProcedure

Procedure SQLiteAdmin_Prepare(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)
  JSONRPC_Dispatcher_Init(*dispatcher)
  MCP_ToolRegistry_Init(*registry)
  MCP_SQLiteAdmin_SetConfig(SQLiteAdmin_TestRoot())
  Assert(MCP_SQLiteAdmin_Register(*dispatcher, *registry), "SQLite admin tools should register.")
EndProcedure

Procedure.s SQLiteAdmin_Call(*dispatcher.JSONRPC_Dispatcher, name.s, argumentsJson.s, id.i)
  ProcedureReturn JSONRPC_Dispatcher_Dispatch(*dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"" + name + ~"\",\"arguments\":" + argumentsJson + ~"},\"id\":" + Str(id) + "}")
EndProcedure

Procedure.s SQLiteAdmin_QueryArgs(dbName.s, sql.s, maxRows.i)
  ProcedureReturn ~"{\"dbPath\":\"" + dbName + ~"\",\"sql\":\"" + JSONRPC_Protocol_EscapeString(sql) + ~"\",\"maxRows\":" + Str(maxRows) + "}"
EndProcedure

Procedure.s SQLiteAdmin_ExecuteArgs(dbName.s, sql.s)
  ProcedureReturn ~"{\"dbPath\":\"" + dbName + ~"\",\"sql\":\"" + JSONRPC_Protocol_EscapeString(sql) + ~"\"}"
EndProcedure

Procedure.s SQLiteAdmin_ExportArgs(dbName.s, sql.s, outputPath.s, maxRows.i, overwrite.i)
  Protected overwriteText.s

  If overwrite
    overwriteText = "true"
  Else
    overwriteText = "false"
  EndIf

  ProcedureReturn ~"{\"dbPath\":\"" + dbName + ~"\",\"sql\":\"" + JSONRPC_Protocol_EscapeString(sql) + ~"\",\"outputPath\":\"" + JSONRPC_Protocol_EscapeString(outputPath) + ~"\",\"format\":\"csv\",\"maxRows\":" + Str(maxRows) + ~",\"overwrite\":" + overwriteText + "}"
EndProcedure

Procedure.s SQLiteAdmin_ReadUtf8File(path.s)
  Protected file.i
  Protected content.s
  Protected b1.i
  Protected b2.i
  Protected b3.i
  Protected format.i

  file = ReadFile(#PB_Any, path)
  Assert(file <> 0, "Expected readable file: " + path)
  b1 = ReadAsciiCharacter(file)
  b2 = ReadAsciiCharacter(file)
  b3 = ReadAsciiCharacter(file)
  Assert(b1 = $EF And b2 = $BB And b3 = $BF, "CSV file should start with a UTF-8 BOM.")
  FileSeek(file, 0)
  format = ReadStringFormat(file)
  Assert(format = #PB_UTF8, "ReadStringFormat should detect UTF-8.")
  content = ReadString(file, #PB_UTF8 | #PB_File_IgnoreEOL, Lof(file))
  CloseFile(file)

  ProcedureReturn content
EndProcedure

Procedure.s SQLiteAdmin_TestDb(name.s)
  ProcedureReturn name + "-" + Str(Date()) + ".sqlite"
EndProcedure

Procedure SQLiteAdmin_Bootstrap(*dispatcher.JSONRPC_Dispatcher, dbName.s)
  Protected response.s

  response = SQLiteAdmin_Call(*dispatcher, "sqlite/bootstrap", ~"{\"dbPath\":\"" + dbName + ~"\",\"overwrite\":true}", 100)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "sqlite/bootstrap should succeed: " + response)
EndProcedure

ProcedureUnit SQLiteAdminDirectSqliteOpenWorks()
  Protected dbPath.s
  Protected file.i

  MCP_SQLiteAdmin_SetConfig(SQLiteAdmin_TestRoot())
  Assert(MCP_SQLiteAdmin_EnsureAllowedRoot(), "Test SQLite root should be created.")
  dbPath = SQLiteAdmin_TestRoot() + "direct-open.sqlite"
  If FileSize(dbPath) >= 0
    DeleteFile(dbPath)
  EndIf

  file = CreateFile(#PB_Any, dbPath)
  Assert(file <> 0, "PureBasic should create an empty SQLite file.")
  CloseFile(file)
  Assert(OpenDatabase(0, dbPath, "", "", #PB_Database_SQLite), "PureBasic SQLite should open a new file: " + DatabaseError())
  CloseDatabase(0)
  Assert(FileSize(dbPath) >= 0, "Direct OpenDatabase should create the file.")
EndProcedureUnit

ProcedureUnit SQLiteAdminToolsListShape()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  SQLiteAdmin_Prepare(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"params\":{},\"id\":1}")

  Assert(FindString(response, ~"\"name\":\"sqlite/bootstrap\"", 1) > 0, "tools/list should expose sqlite/bootstrap.")
  Assert(FindString(response, ~"\"name\":\"sqlite/query\"", 1) > 0, "tools/list should expose sqlite/query.")
  Assert(FindString(response, ~"\"name\":\"sqlite/export\"", 1) > 0, "tools/list should expose sqlite/export.")
  Assert(FindString(response, ~"\"name\":\"sqlite/recipe/run\"", 1) > 0, "tools/list should expose sqlite/recipe/run.")
EndProcedureUnit

ProcedureUnit SQLiteAdminBootstrapCreatesDatabaseAndCatalog()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected dbName.s
  Protected response.s

  SQLiteAdmin_Prepare(@dispatcher, @registry)
  dbName = SQLiteAdmin_TestDb("bootstrap")
  SQLiteAdmin_Bootstrap(@dispatcher, dbName)

  Assert(FileSize(SQLiteAdmin_TestRoot() + dbName) >= 0, "Bootstrap should create the SQLite file.")
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/inspect", ~"{\"dbPath\":\"" + dbName + ~"\",\"includeSystem\":false}", 101)
  Assert(FindString(response, "admin_notes", 1) > 0, "Inspect should include admin_notes.")
  Assert(FindString(response, "sql_recipes", 1) > 0, "Inspect should include sql_recipes.")
EndProcedureUnit

ProcedureUnit SQLiteAdminUtf8RoundTripExactMatch()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected dbName.s
  Protected response.s

  SQLiteAdmin_Prepare(@dispatcher, @registry)
  dbName = SQLiteAdmin_TestDb("utf8")
  SQLiteAdmin_Bootstrap(@dispatcher, dbName)

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/query", SQLiteAdmin_QueryArgs(dbName, "SELECT title, body FROM admin_notes WHERE title = " + MCP_SQLiteAdmin_SqlQuote(MCP_SQLiteAdmin_ThaiHello()), 5), 102)
  Assert(FindString(response, MCP_SQLiteAdmin_ThaiHello(), 1) > 0, "Thai text should round-trip exactly.")
  Assert(FindString(response, MCP_SQLiteAdmin_ThaiBody(), 1) > 0, "Thai body should round-trip exactly.")

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/query", SQLiteAdmin_QueryArgs(dbName, "SELECT title, body FROM admin_notes WHERE title = " + MCP_SQLiteAdmin_SqlQuote(MCP_SQLiteAdmin_FrenchResume()), 5), 103)
  Assert(FindString(response, MCP_SQLiteAdmin_FrenchResume(), 1) > 0, "Accented Latin text should round-trip exactly.")
  Assert(FindString(response, MCP_SQLiteAdmin_FrenchBody(), 1) > 0, "Accented Latin body should round-trip exactly.")
EndProcedureUnit

ProcedureUnit SQLiteAdminQueryBoundsRows()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected dbName.s
  Protected response.s

  SQLiteAdmin_Prepare(@dispatcher, @registry)
  dbName = SQLiteAdmin_TestDb("bounded")
  SQLiteAdmin_Bootstrap(@dispatcher, dbName)

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/query", ~"{\"dbPath\":\"" + dbName + ~"\",\"sql\":\"SELECT id, locale, title FROM admin_notes ORDER BY id\",\"maxRows\":2}", 104)
  Assert(FindString(response, "returnedRows", 1) > 0, "Query response should include returnedRows metadata.")
  Assert(FindString(response, "truncated", 1) > 0, "Query response should include truncation metadata.")
  Assert(FindString(response, ~"\\\"returnedRows\\\":2", 1) > 0, "Query should return only the requested row count.")
  Assert(FindString(response, ~"\\\"truncated\\\":true", 1) > 0, "Query should mark truncation.")
EndProcedureUnit

ProcedureUnit SQLiteAdminCsvExportWritesCanonicalCsv()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected dbName.s
  Protected outputName.s
  Protected outputPath.s
  Protected response.s
  Protected sql.s
  Protected content.s

  SQLiteAdmin_Prepare(@dispatcher, @registry)
  dbName = SQLiteAdmin_TestDb("csv")
  outputName = "exports/" + dbName + ".csv"
  outputPath = SQLiteAdmin_TestRoot() + outputName
  SQLiteAdmin_Bootstrap(@dispatcher, dbName)

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/execute", SQLiteAdmin_ExecuteArgs(dbName, "CREATE TABLE csv_items (id INTEGER PRIMARY KEY, name TEXT, note TEXT, optional TEXT)"), 117)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "CSV setup table should be created.")
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/execute", SQLiteAdmin_ExecuteArgs(dbName, "INSERT INTO csv_items(id,name,note,optional) VALUES (1,'plain','comma, inside','')"), 118)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "CSV comma row should insert.")
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/execute", SQLiteAdmin_ExecuteArgs(dbName, "INSERT INTO csv_items(id,name,note,optional) VALUES (2,'quote " + #DQUOTE$ + " inside','line one' || char(10) || 'line two',NULL)"), 119)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "CSV quote/newline row should insert.")
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/execute", SQLiteAdmin_ExecuteArgs(dbName, "INSERT INTO csv_items(id,name,note,optional) VALUES (3," + MCP_SQLiteAdmin_SqlQuote(MCP_SQLiteAdmin_ThaiHello()) + "," + MCP_SQLiteAdmin_SqlQuote(MCP_SQLiteAdmin_FrenchBody()) + ",'utf8')"), 120)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "CSV UTF-8 row should insert.")

  sql = "SELECT id, name, note, optional FROM csv_items ORDER BY id"
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/export", SQLiteAdmin_ExportArgs(dbName, sql, outputName, 10, #True), 121)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "CSV export should succeed: " + response)
  Assert(FindString(response, "UTF-8 with BOM", 1) > 0, "CSV export response should document UTF-8 BOM.")
  Assert(FindString(response, "quotedFields", 1) > 0, "CSV export response should document quoted fields.")
  Assert(FileSize(outputPath) > 0, "CSV export file should exist.")

  content = SQLiteAdmin_ReadUtf8File(outputPath)
  Assert(FindString(content, ~"\"id\",\"name\",\"note\",\"optional\"" + #CRLF$, 1) > 0, "CSV header should quote every field and use CRLF.")
  Assert(FindString(content, ~"\"1\",\"plain\",\"comma, inside\",\"\"" + #CRLF$, 1) > 0, "CSV comma row should quote every field.")
  Assert(FindString(content, ~"\"2\",\"quote \"\" inside\",\"line one" + #LF$ + ~"line two\",\"\"" + #CRLF$, 1) > 0, "CSV should double quotes and preserve embedded line breaks inside quotes.")
  Assert(FindString(content, MCP_SQLiteAdmin_ThaiHello(), 1) > 0, "CSV should preserve Thai UTF-8 text.")
  Assert(FindString(content, MCP_SQLiteAdmin_FrenchBody(), 1) > 0, "CSV should preserve accented UTF-8 text.")
EndProcedureUnit

ProcedureUnit SQLiteAdminCsvExportRespectsOverwriteAndRowLimit()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected dbName.s
  Protected outputName.s
  Protected outputPath.s
  Protected response.s
  Protected sql.s
  Protected content.s

  SQLiteAdmin_Prepare(@dispatcher, @registry)
  dbName = SQLiteAdmin_TestDb("csv-limit")
  outputName = "exports/" + dbName + ".csv"
  outputPath = SQLiteAdmin_TestRoot() + outputName
  SQLiteAdmin_Bootstrap(@dispatcher, dbName)

  sql = "SELECT id, locale, title FROM admin_notes ORDER BY id"
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/export", SQLiteAdmin_ExportArgs(dbName, sql, outputName, 1, #True), 122)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "Limited CSV export should succeed.")
  Assert(FindString(response, ~"\\\"exportedRows\\\":1", 1) > 0, "CSV export should report exported row count.")
  Assert(FindString(response, ~"\\\"truncated\\\":true", 1) > 0, "CSV export should report truncation.")

  content = SQLiteAdmin_ReadUtf8File(outputPath)
  Assert(FindString(content, ~"\"id\",\"locale\",\"title\"" + #CRLF$ + ~"\"1\",\"en\",\"Welcome\"" + #CRLF$, 1) > 0, "Limited CSV should contain header and one row.")
  Assert(FindString(content, MCP_SQLiteAdmin_ThaiHello(), 1) = 0, "Limited CSV should omit rows beyond maxRows.")

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/export", SQLiteAdmin_ExportArgs(dbName, sql, outputName, 1, #False), 123)
  Assert(FindString(response, ~"\"isError\":true", 1) > 0, "CSV export should not overwrite without overwrite=true.")

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/export", SQLiteAdmin_ExportArgs(dbName, sql, "exports/not-csv.txt", 1, #True), 124)
  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "CSV export should require a .csv outputPath.")
EndProcedureUnit

ProcedureUnit SQLiteAdminExecuteCanWriteData()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected dbName.s
  Protected response.s

  SQLiteAdmin_Prepare(@dispatcher, @registry)
  dbName = SQLiteAdmin_TestDb("execute")
  SQLiteAdmin_Bootstrap(@dispatcher, dbName)

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/execute", ~"{\"dbPath\":\"" + dbName + ~"\",\"sql\":\"CREATE TABLE unit_items (id INTEGER PRIMARY KEY, name TEXT)\"}", 105)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "CREATE TABLE should succeed.")
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/execute", ~"{\"dbPath\":\"" + dbName + ~"\",\"sql\":\"INSERT INTO unit_items(name) VALUES ('before')\"}", 106)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "INSERT should succeed.")
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/execute", ~"{\"dbPath\":\"" + dbName + ~"\",\"sql\":\"UPDATE unit_items SET name = 'after' WHERE name = 'before'\"}", 107)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "UPDATE should succeed.")
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/query", ~"{\"dbPath\":\"" + dbName + ~"\",\"sql\":\"SELECT name FROM unit_items\",\"maxRows\":5}", 108)
  Assert(FindString(response, "after", 1) > 0, "Query should show updated data.")
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/execute", ~"{\"dbPath\":\"" + dbName + ~"\",\"sql\":\"DELETE FROM unit_items WHERE name = 'after'\"}", 109)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "DELETE should succeed.")
EndProcedureUnit

ProcedureUnit SQLiteAdminRecipeLifecycleWorks()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected dbName.s
  Protected response.s

  SQLiteAdmin_Prepare(@dispatcher, @registry)
  dbName = SQLiteAdmin_TestDb("recipe")
  SQLiteAdmin_Bootstrap(@dispatcher, dbName)

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/recipe/save", ~"{\"dbPath\":\"" + dbName + ~"\",\"name\":\"unit-locale\",\"description\":\"Find notes by locale\",\"category\":\"unit\",\"sql\":\"SELECT title FROM admin_notes WHERE locale = :locale ORDER BY id\",\"parameterNotes\":\"locale: exact locale\"}", 110)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "Recipe save should succeed.")

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/recipe/list", ~"{\"dbPath\":\"" + dbName + ~"\"}", 111)
  Assert(FindString(response, "unit-locale", 1) > 0, "Recipe list should include saved recipe.")

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/recipe/run", ~"{\"dbPath\":\"" + dbName + ~"\",\"name\":\"unit-locale\",\"parameters\":{\"locale\":\"ja\"},\"maxRows\":5}", 112)
  Assert(FindString(response, MCP_SQLiteAdmin_JapaneseHello(), 1) > 0, "Recipe run should apply scalar parameters.")

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/recipe/delete", ~"{\"dbPath\":\"" + dbName + ~"\",\"name\":\"unit-locale\"}", 113)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "Recipe delete should succeed.")
EndProcedureUnit

ProcedureUnit SQLiteAdminInvalidPathEscapesRejected()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  SQLiteAdmin_Prepare(@dispatcher, @registry)
  response = SQLiteAdmin_Call(@dispatcher, "sqlite/bootstrap", ~"{\"dbPath\":\"../escaped.sqlite\",\"overwrite\":true}", 114)

  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "Escaping the allowed root should return invalid params.")
EndProcedureUnit

ProcedureUnit SQLiteAdminBackupAndMaintenanceWork()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected dbName.s
  Protected backupName.s
  Protected response.s

  SQLiteAdmin_Prepare(@dispatcher, @registry)
  dbName = SQLiteAdmin_TestDb("backup")
  backupName = SQLiteAdmin_TestDb("backup-copy")
  SQLiteAdmin_Bootstrap(@dispatcher, dbName)

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/backup", ~"{\"dbPath\":\"" + dbName + ~"\",\"backupPath\":\"" + backupName + ~"\",\"overwrite\":true}", 115)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "Backup should succeed.")
  Assert(FileSize(SQLiteAdmin_TestRoot() + backupName) >= 0, "Backup file should exist.")

  response = SQLiteAdmin_Call(@dispatcher, "sqlite/maintenance", ~"{\"dbPath\":\"" + dbName + ~"\",\"operation\":\"quick_check\"}", 116)
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "quick_check should succeed.")
  Assert(FindString(response, "ok", 1) > 0, "quick_check should report ok.")
EndProcedureUnit
