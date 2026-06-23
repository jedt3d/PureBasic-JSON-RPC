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
