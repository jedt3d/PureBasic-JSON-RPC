EnableExplicit

XIncludeFile "../../../src/jsonrpc/mcp_tools.pbi"

UseSQLiteDatabase()
UseZipPacker()

#MCP_SQLiteAdmin_DefaultMaxOutputChars = 24000
#MCP_SQLiteAdmin_DefaultMaxRows = 50
#MCP_SQLiteAdmin_DefaultExportMaxRows = 5000
#MCP_SQLiteAdmin_MaxExportRows = 10000
#MCP_SQLiteAdmin_Database = 0
#MCP_SQLiteAdmin_OdsMimeType$ = "application/vnd.oasis.opendocument.spreadsheet"
#MCP_SQLiteAdmin_XlsxMimeType$ = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

#MCP_SQLiteAdmin_BootstrapSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"},\"overwrite\":{\"type\":\"boolean\"}},\"additionalProperties\":false}"
#MCP_SQLiteAdmin_InspectSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"},\"includeSystem\":{\"type\":\"boolean\"}},\"additionalProperties\":false}"
#MCP_SQLiteAdmin_QuerySchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"},\"sql\":{\"type\":\"string\"},\"maxRows\":{\"type\":\"integer\"}},\"required\":[\"sql\"],\"additionalProperties\":false}"
#MCP_SQLiteAdmin_ExportSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"},\"sql\":{\"type\":\"string\"},\"outputPath\":{\"type\":\"string\"},\"format\":{\"type\":\"string\",\"enum\":[\"csv\",\"ods\",\"xlsx\"]},\"maxRows\":{\"type\":\"integer\"},\"overwrite\":{\"type\":\"boolean\"}},\"required\":[\"sql\",\"outputPath\"],\"additionalProperties\":false}"
#MCP_SQLiteAdmin_ExecuteSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"},\"sql\":{\"type\":\"string\"}},\"required\":[\"sql\"],\"additionalProperties\":false}"
#MCP_SQLiteAdmin_BackupSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"},\"backupPath\":{\"type\":\"string\"},\"overwrite\":{\"type\":\"boolean\"}},\"required\":[\"backupPath\"],\"additionalProperties\":false}"
#MCP_SQLiteAdmin_MaintenanceSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"},\"operation\":{\"type\":\"string\",\"enum\":[\"quick_check\",\"integrity_check\",\"vacuum\"]}},\"required\":[\"operation\"],\"additionalProperties\":false}"
#MCP_SQLiteAdmin_RecipeListSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_SQLiteAdmin_RecipeSaveSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"},\"name\":{\"type\":\"string\"},\"description\":{\"type\":\"string\"},\"category\":{\"type\":\"string\"},\"sql\":{\"type\":\"string\"},\"parameterNotes\":{\"type\":\"string\"}},\"required\":[\"name\",\"sql\"],\"additionalProperties\":false}"
#MCP_SQLiteAdmin_RecipeRunSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"},\"name\":{\"type\":\"string\"},\"parameters\":{\"type\":\"object\"},\"maxRows\":{\"type\":\"integer\"}},\"required\":[\"name\"],\"additionalProperties\":false}"
#MCP_SQLiteAdmin_RecipeDeleteSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dbPath\":{\"type\":\"string\"},\"name\":{\"type\":\"string\"}},\"required\":[\"name\"],\"additionalProperties\":false}"

Structure MCP_SQLiteAdmin_Config
  allowedRoot.s
  defaultDbPath.s
  maxOutputChars.i
EndStructure

Structure MCP_SQLiteAdmin_Result
  ok.i
  isError.i
  text.s
EndStructure

Structure MCP_SQLiteAdmin_ArgState
  ok.i
  message.s
EndStructure

Global MCP_SQLiteAdmin_Config.MCP_SQLiteAdmin_Config

Declare MCP_SQLiteAdmin_SetConfig(allowedRoot.s = "", defaultDbPath.s = "", maxOutputChars.i = #MCP_SQLiteAdmin_DefaultMaxOutputChars)
Declare MCP_SQLiteAdmin_ResetConfig()
Declare.s MCP_SQLiteAdmin_DefaultAllowedRoot()
Declare.s MCP_SQLiteAdmin_DefaultDbPath()
Declare.i MCP_SQLiteAdmin_EnsureDirectory(directory.s)
Declare.i MCP_SQLiteAdmin_BootstrapDatabase(dbPath.s, overwrite.i, *result.MCP_SQLiteAdmin_Result)
Declare.i MCP_SQLiteAdmin_Register(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)

Procedure.s MCP_SQLiteAdmin_EnsureTrailingSlash(path.s)
  If path <> "" And Right(path, 1) <> "/"
    path + "/"
  EndIf

  ProcedureReturn path
EndProcedure

Procedure.s MCP_SQLiteAdmin_DefaultAllowedRoot()
  ProcedureReturn MCP_SQLiteAdmin_EnsureTrailingSlash(GetCurrentDirectory() + ".local/sqlite-admin")
EndProcedure

Procedure.s MCP_SQLiteAdmin_DefaultDbPath()
  ProcedureReturn MCP_SQLiteAdmin_DefaultAllowedRoot() + "demo.sqlite"
EndProcedure

Procedure MCP_SQLiteAdmin_SetConfig(allowedRoot.s = "", defaultDbPath.s = "", maxOutputChars.i = #MCP_SQLiteAdmin_DefaultMaxOutputChars)
  UseSQLiteDatabase()
  UseZipPacker()

  If allowedRoot = ""
    allowedRoot = MCP_SQLiteAdmin_DefaultAllowedRoot()
  EndIf

  MCP_SQLiteAdmin_Config\allowedRoot = MCP_SQLiteAdmin_EnsureTrailingSlash(allowedRoot)

  If defaultDbPath = ""
    defaultDbPath = MCP_SQLiteAdmin_Config\allowedRoot + "demo.sqlite"
  EndIf

  MCP_SQLiteAdmin_Config\defaultDbPath = defaultDbPath
  MCP_SQLiteAdmin_Config\maxOutputChars = maxOutputChars

  If MCP_SQLiteAdmin_Config\maxOutputChars <= 0
    MCP_SQLiteAdmin_Config\maxOutputChars = #MCP_SQLiteAdmin_DefaultMaxOutputChars
  EndIf
EndProcedure

Procedure MCP_SQLiteAdmin_ResetConfig()
  MCP_SQLiteAdmin_SetConfig()
EndProcedure

Procedure MCP_SQLiteAdmin_ResetResult(*result.MCP_SQLiteAdmin_Result)
  *result\ok = #False
  *result\isError = #True
  *result\text = ""
EndProcedure

Procedure.s MCP_SQLiteAdmin_JsonString(text.s)
  ProcedureReturn #DQUOTE$ + JSONRPC_Protocol_EscapeString(text) + #DQUOTE$
EndProcedure

Procedure.s MCP_SQLiteAdmin_SqlQuote(text.s)
  ProcedureReturn "'" + ReplaceString(text, "'", "''") + "'"
EndProcedure

Procedure.s MCP_SQLiteAdmin_BoolJson(value.i)
  If value
    ProcedureReturn "true"
  EndIf

  ProcedureReturn "false"
EndProcedure

Procedure.s MCP_SQLiteAdmin_BoundText(text.s)
  If Len(text) <= MCP_SQLiteAdmin_Config\maxOutputChars
    ProcedureReturn text
  EndIf

  ProcedureReturn Left(text, MCP_SQLiteAdmin_Config\maxOutputChars) + #LF$ + "[output truncated]"
EndProcedure

Procedure MCP_SQLiteAdmin_SetMCPResult(*result.JSONRPC_HandlerResult, text.s, isError.i = #False)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_SQLiteAdmin_BoundText(text), isError)
EndProcedure

Procedure MCP_SQLiteAdmin_SetInvalidParams(*result.JSONRPC_HandlerResult, message.s)
  *result\ok = #False
  *result\errorCode = #JSONRPC_Error_InvalidParams
  *result\errorMessage = message
EndProcedure

Procedure.i MCP_SQLiteAdmin_IsUnsafePath(path.s)
  If path = "" Or FindString(path, "..", 1) > 0 Or FindString(path, "~", 1) > 0 Or FindString(path, "\", 1) > 0
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.s MCP_SQLiteAdmin_ResolvePath(inputPath.s, *errorMessage.String)
  Protected resolved.s
  Protected allowedRoot.s

  allowedRoot = MCP_SQLiteAdmin_Config\allowedRoot
  If inputPath = ""
    inputPath = MCP_SQLiteAdmin_Config\defaultDbPath
  EndIf

  If MCP_SQLiteAdmin_IsUnsafePath(inputPath)
    *errorMessage\s = "Path is empty or contains an unsafe segment."
    ProcedureReturn ""
  EndIf

  If Left(inputPath, 1) = "/"
    resolved = inputPath
  Else
    resolved = allowedRoot + inputPath
  EndIf

  If Left(resolved, Len(allowedRoot)) <> allowedRoot
    *errorMessage\s = "Path must stay inside allowed SQLite root: " + allowedRoot
    ProcedureReturn ""
  EndIf

  ProcedureReturn resolved
EndProcedure

Procedure.i MCP_SQLiteAdmin_EnsureAllowedRoot()
  ProcedureReturn MCP_SQLiteAdmin_EnsureDirectory(MCP_SQLiteAdmin_Config\allowedRoot)
EndProcedure

Procedure.i MCP_SQLiteAdmin_EnsureDirectory(directory.s)
  Protected normalized.s
  Protected current.s
  Protected part.s
  Protected index.i
  Protected count.i

  If directory = ""
    ProcedureReturn #False
  EndIf

  normalized = MCP_SQLiteAdmin_EnsureTrailingSlash(directory)
  If Left(normalized, 1) <> "/"
    ProcedureReturn #False
  EndIf

  current = "/"
  count = CountString(normalized, "/")
  For index = 2 To count
    part = StringField(normalized, index, "/")
    If part <> ""
      current + part + "/"
      If FileSize(current) <> -2
        If CreateDirectory(current) = #False
          ProcedureReturn #False
        EndIf
      EndIf
    EndIf
  Next

  If FileSize(normalized) <> -2
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_OpenDatabase(dbPath.s, createIfMissing.i, *result.MCP_SQLiteAdmin_Result)
  Protected file.i

  If createIfMissing And FileSize(dbPath) = -1
    file = CreateFile(#PB_Any, dbPath)
    If file
      CloseFile(file)
    Else
      *result\text = "Unable to create SQLite file: " + dbPath
      ProcedureReturn #False
    EndIf
  EndIf

  If createIfMissing = #False And FileSize(dbPath) < 0
    *result\text = "SQLite file does not exist: " + dbPath
    ProcedureReturn #False
  EndIf

  If OpenDatabase(#MCP_SQLiteAdmin_Database, dbPath, "", "", #PB_Database_SQLite) = 0
    *result\text = "Unable to open SQLite database " + dbPath + ": " + DatabaseError()
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_Update(sql.s, *result.MCP_SQLiteAdmin_Result)
  If DatabaseUpdate(#MCP_SQLiteAdmin_Database, sql) = 0
    *result\text = DatabaseError()
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_CreateSchema(*result.MCP_SQLiteAdmin_Result)
  If MCP_SQLiteAdmin_Update("CREATE TABLE IF NOT EXISTS admin_notes (id INTEGER PRIMARY KEY AUTOINCREMENT, locale TEXT NOT NULL, title TEXT NOT NULL, body TEXT NOT NULL, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)", *result) = #False
    ProcedureReturn #False
  EndIf

  If MCP_SQLiteAdmin_Update("CREATE TABLE IF NOT EXISTS sql_recipes (name TEXT PRIMARY KEY, description TEXT NOT NULL DEFAULT '', category TEXT NOT NULL DEFAULT '', sql_text TEXT NOT NULL, parameter_notes TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)", *result) = #False
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.s MCP_SQLiteAdmin_ThaiHello()
  ProcedureReturn Chr($0E2A) + Chr($0E27) + Chr($0E31) + Chr($0E2A) + Chr($0E14) + Chr($0E35)
EndProcedure

Procedure.s MCP_SQLiteAdmin_ThaiBody()
  ProcedureReturn Chr($0E20) + Chr($0E32) + Chr($0E29) + Chr($0E32) + Chr($0E44) + Chr($0E17) + Chr($0E22) + " UTF-8"
EndProcedure

Procedure.s MCP_SQLiteAdmin_JapaneseHello()
  ProcedureReturn Chr($3053) + Chr($3093) + Chr($306B) + Chr($3061) + Chr($306F)
EndProcedure

Procedure.s MCP_SQLiteAdmin_JapaneseBody()
  ProcedureReturn Chr($65E5) + Chr($672C) + Chr($8A9E) + " UTF-8"
EndProcedure

Procedure.s MCP_SQLiteAdmin_FrenchResume()
  ProcedureReturn "R" + Chr($00E9) + "sum" + Chr($00E9)
EndProcedure

Procedure.s MCP_SQLiteAdmin_FrenchBody()
  ProcedureReturn "Caf" + Chr($00E9) + " na" + Chr($00EF) + "ve fa" + Chr($00E7) + "ade d" + Chr($00E9) + "j" + Chr($00E0) + " vu"
EndProcedure

Procedure.i MCP_SQLiteAdmin_InsertSampleData(*result.MCP_SQLiteAdmin_Result)
  If MCP_SQLiteAdmin_Update("DELETE FROM admin_notes", *result) = #False
    ProcedureReturn #False
  EndIf

  If MCP_SQLiteAdmin_Update("DELETE FROM sql_recipes", *result) = #False
    ProcedureReturn #False
  EndIf

  If MCP_SQLiteAdmin_Update("INSERT INTO admin_notes(locale,title,body) VALUES ('en','Welcome','Hello from the SQLite admin MCP server')", *result) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_Update("INSERT INTO admin_notes(locale,title,body) VALUES ('th'," + MCP_SQLiteAdmin_SqlQuote(MCP_SQLiteAdmin_ThaiHello()) + "," + MCP_SQLiteAdmin_SqlQuote(MCP_SQLiteAdmin_ThaiBody()) + ")", *result) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_Update("INSERT INTO admin_notes(locale,title,body) VALUES ('ja'," + MCP_SQLiteAdmin_SqlQuote(MCP_SQLiteAdmin_JapaneseHello()) + "," + MCP_SQLiteAdmin_SqlQuote(MCP_SQLiteAdmin_JapaneseBody()) + ")", *result) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_Update("INSERT INTO admin_notes(locale,title,body) VALUES ('fr'," + MCP_SQLiteAdmin_SqlQuote(MCP_SQLiteAdmin_FrenchResume()) + "," + MCP_SQLiteAdmin_SqlQuote(MCP_SQLiteAdmin_FrenchBody()) + ")", *result) = #False
    ProcedureReturn #False
  EndIf

  If MCP_SQLiteAdmin_Update("INSERT INTO sql_recipes(name,description,category,sql_text,parameter_notes) VALUES ('list-notes','List all multilingual demo notes','demo','SELECT id, locale, title, body FROM admin_notes ORDER BY id','No parameters')", *result) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_Update("INSERT INTO sql_recipes(name,description,category,sql_text,parameter_notes) VALUES ('notes-by-locale','Find notes by exact locale','i18n','SELECT id, locale, title, body FROM admin_notes WHERE locale = :locale ORDER BY id','locale: exact locale code such as en, th, ja, fr')", *result) = #False
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_BootstrapDatabase(dbPath.s, overwrite.i, *result.MCP_SQLiteAdmin_Result)
  Protected errorMessage.String
  Protected resolved.s

  MCP_SQLiteAdmin_ResetResult(*result)
  If MCP_SQLiteAdmin_EnsureAllowedRoot() = #False
    *result\text = "Unable to create allowed SQLite root: " + MCP_SQLiteAdmin_Config\allowedRoot
    ProcedureReturn #False
  EndIf

  resolved = MCP_SQLiteAdmin_ResolvePath(dbPath, @errorMessage)
  If resolved = ""
    *result\text = errorMessage\s
    ProcedureReturn #False
  EndIf

  If FileSize(resolved) >= 0
    If overwrite = #False
      *result\text = "SQLite file already exists. Set overwrite=true to recreate it."
      ProcedureReturn #False
    EndIf

    If DeleteFile(resolved) = #False
      *result\text = "Unable to remove existing SQLite file: " + resolved
      ProcedureReturn #False
    EndIf
  EndIf

  If MCP_SQLiteAdmin_OpenDatabase(resolved, #True, *result) = #False
    ProcedureReturn #False
  EndIf

  If MCP_SQLiteAdmin_CreateSchema(*result) And MCP_SQLiteAdmin_InsertSampleData(*result)
    *result\ok = #True
    *result\isError = #False
    *result\text = "SQLite admin database bootstrapped at " + resolved + "." + #LF$ + "Created admin_notes, sql_recipes, multilingual sample rows, and starter SQL recipes."
  EndIf

  CloseDatabase(#MCP_SQLiteAdmin_Database)
  ProcedureReturn *result\ok
EndProcedure

Procedure.s MCP_SQLiteAdmin_CellJson(column.i)
  If CheckDatabaseNull(#MCP_SQLiteAdmin_Database, column)
    ProcedureReturn "null"
  EndIf

  ProcedureReturn MCP_SQLiteAdmin_JsonString(GetDatabaseString(#MCP_SQLiteAdmin_Database, column))
EndProcedure

Procedure.s MCP_SQLiteAdmin_CsvField(text.s)
  ProcedureReturn #DQUOTE$ + ReplaceString(text, #DQUOTE$, #DQUOTE$ + #DQUOTE$) + #DQUOTE$
EndProcedure

Procedure.s MCP_SQLiteAdmin_XmlEscape(text.s)
  text = ReplaceString(text, "&", "&amp;")
  text = ReplaceString(text, "<", "&lt;")
  text = ReplaceString(text, ">", "&gt;")
  text = ReplaceString(text, #DQUOTE$, "&quot;")
  text = ReplaceString(text, "'", "&apos;")

  ProcedureReturn text
EndProcedure

Procedure.s MCP_SQLiteAdmin_OdsText(text.s)
  Protected normalized.s
  Protected result.s
  Protected index.i
  Protected parts.i

  normalized = ReplaceString(ReplaceString(text, #CRLF$, #LF$), #CR$, #LF$)
  parts = CountString(normalized, #LF$) + 1

  For index = 1 To parts
    If index > 1
      result + "<text:line-break/>"
    EndIf
    result + MCP_SQLiteAdmin_XmlEscape(StringField(normalized, index, #LF$))
  Next

  ProcedureReturn result
EndProcedure

Procedure.s MCP_SQLiteAdmin_OdsTextCell(text.s)
  ProcedureReturn "<table:table-cell office:value-type=" + #DQUOTE$ + "string" + #DQUOTE$ + "><text:p>" + MCP_SQLiteAdmin_OdsText(text) + "</text:p></table:table-cell>"
EndProcedure

Procedure.s MCP_SQLiteAdmin_OdsCell(column.i)
  If CheckDatabaseNull(#MCP_SQLiteAdmin_Database, column)
    ProcedureReturn MCP_SQLiteAdmin_OdsTextCell("")
  EndIf

  ProcedureReturn MCP_SQLiteAdmin_OdsTextCell(GetDatabaseString(#MCP_SQLiteAdmin_Database, column))
EndProcedure

Procedure.s MCP_SQLiteAdmin_OdsContentStart(columns.i)
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + "?>" + #LF$
  xml + "<office:document-content xmlns:office=" + #DQUOTE$ + "urn:oasis:names:tc:opendocument:xmlns:office:1.0" + #DQUOTE$
  xml + " xmlns:table=" + #DQUOTE$ + "urn:oasis:names:tc:opendocument:xmlns:table:1.0" + #DQUOTE$
  xml + " xmlns:text=" + #DQUOTE$ + "urn:oasis:names:tc:opendocument:xmlns:text:1.0" + #DQUOTE$
  xml + " office:version=" + #DQUOTE$ + "1.2" + #DQUOTE$ + ">" + #LF$
  xml + "<office:body><office:spreadsheet><table:table table:name=" + #DQUOTE$ + "QueryResult" + #DQUOTE$ + ">" + #LF$
  If columns > 0
    xml + "<table:table-column table:number-columns-repeated=" + #DQUOTE$ + Str(columns) + #DQUOTE$ + "/>" + #LF$
  EndIf

  ProcedureReturn xml
EndProcedure

Procedure.s MCP_SQLiteAdmin_OdsContentEnd()
  ProcedureReturn "</table:table></office:spreadsheet></office:body></office:document-content>" + #LF$
EndProcedure

Procedure.s MCP_SQLiteAdmin_OdsStyles()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + "?>" + #LF$
  xml + "<office:document-styles xmlns:office=" + #DQUOTE$ + "urn:oasis:names:tc:opendocument:xmlns:office:1.0" + #DQUOTE$
  xml + " xmlns:style=" + #DQUOTE$ + "urn:oasis:names:tc:opendocument:xmlns:style:1.0" + #DQUOTE$
  xml + " xmlns:text=" + #DQUOTE$ + "urn:oasis:names:tc:opendocument:xmlns:text:1.0" + #DQUOTE$
  xml + " xmlns:table=" + #DQUOTE$ + "urn:oasis:names:tc:opendocument:xmlns:table:1.0" + #DQUOTE$
  xml + " office:version=" + #DQUOTE$ + "1.2" + #DQUOTE$ + "><office:styles/></office:document-styles>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.s MCP_SQLiteAdmin_OdsMeta()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + "?>" + #LF$
  xml + "<office:document-meta xmlns:office=" + #DQUOTE$ + "urn:oasis:names:tc:opendocument:xmlns:office:1.0" + #DQUOTE$
  xml + " xmlns:meta=" + #DQUOTE$ + "urn:oasis:names:tc:opendocument:xmlns:meta:1.0" + #DQUOTE$
  xml + " office:version=" + #DQUOTE$ + "1.2" + #DQUOTE$ + "><office:meta><meta:generator>PureBasic JSON-RPC SQLite Admin MCP</meta:generator></office:meta></office:document-meta>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.s MCP_SQLiteAdmin_OdsManifest()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + "?>" + #LF$
  xml + "<manifest:manifest xmlns:manifest=" + #DQUOTE$ + "urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" + #DQUOTE$
  xml + " manifest:version=" + #DQUOTE$ + "1.2" + #DQUOTE$ + ">" + #LF$
  xml + "<manifest:file-entry manifest:full-path=" + #DQUOTE$ + "/" + #DQUOTE$ + " manifest:media-type=" + #DQUOTE$ + #MCP_SQLiteAdmin_OdsMimeType$ + #DQUOTE$ + "/>" + #LF$
  xml + "<manifest:file-entry manifest:full-path=" + #DQUOTE$ + "content.xml" + #DQUOTE$ + " manifest:media-type=" + #DQUOTE$ + "text/xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<manifest:file-entry manifest:full-path=" + #DQUOTE$ + "styles.xml" + #DQUOTE$ + " manifest:media-type=" + #DQUOTE$ + "text/xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<manifest:file-entry manifest:full-path=" + #DQUOTE$ + "meta.xml" + #DQUOTE$ + " manifest:media-type=" + #DQUOTE$ + "text/xml" + #DQUOTE$ + "/>" + #LF$
  xml + "</manifest:manifest>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.i MCP_SQLiteAdmin_AddPackUtf8String(pack.i, packedName.s, text.s)
  Protected byteLength.i
  Protected ok.i
  Protected *buffer

  byteLength = StringByteLength(text, #PB_UTF8)
  *buffer = AllocateMemory(byteLength + 1)
  If *buffer = 0
    ProcedureReturn #False
  EndIf

  If byteLength > 0
    PokeS(*buffer, text, -1, #PB_UTF8 | #PB_String_NoZero)
  EndIf

  ok = AddPackMemory(pack, *buffer, byteLength, packedName)
  FreeMemory(*buffer)

  ProcedureReturn Bool(ok <> 0)
EndProcedure

Procedure.i MCP_SQLiteAdmin_WriteOdsPackage(outputPath.s, contentXml.s)
  Protected pack.i
  Protected ok.i

  pack = CreatePack(#PB_Any, outputPath, #PB_PackerPlugin_Zip, 0)
  If pack = 0
    ProcedureReturn #False
  EndIf

  ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "mimetype", #MCP_SQLiteAdmin_OdsMimeType$)
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "META-INF/manifest.xml", MCP_SQLiteAdmin_OdsManifest())
  EndIf
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "content.xml", contentXml)
  EndIf
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "styles.xml", MCP_SQLiteAdmin_OdsStyles())
  EndIf
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "meta.xml", MCP_SQLiteAdmin_OdsMeta())
  EndIf

  ClosePack(pack)

  If ok = #False
    DeleteFile(outputPath)
  EndIf

  ProcedureReturn ok
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxColumnName(column.i)
  Protected value.i
  Protected remainder.i
  Protected name.s

  value = column + 1
  While value > 0
    value - 1
    remainder = value % 26
    name = Chr(65 + remainder) + name
    value = value / 26
  Wend

  ProcedureReturn name
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxCellRef(row.i, column.i)
  ProcedureReturn MCP_SQLiteAdmin_XlsxColumnName(column) + Str(row)
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxText(text.s)
  text = ReplaceString(ReplaceString(text, #CRLF$, #LF$), #CR$, #LF$)
  ProcedureReturn MCP_SQLiteAdmin_XmlEscape(text)
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxTextCell(row.i, column.i, text.s)
  Protected cellRef.s

  cellRef = MCP_SQLiteAdmin_XlsxCellRef(row, column)
  ProcedureReturn "<c r=" + #DQUOTE$ + cellRef + #DQUOTE$ + " t=" + #DQUOTE$ + "inlineStr" + #DQUOTE$ + "><is><t xml:space=" + #DQUOTE$ + "preserve" + #DQUOTE$ + ">" + MCP_SQLiteAdmin_XlsxText(text) + "</t></is></c>"
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxCell(row.i, column.i)
  If CheckDatabaseNull(#MCP_SQLiteAdmin_Database, column)
    ProcedureReturn MCP_SQLiteAdmin_XlsxTextCell(row, column, "")
  EndIf

  ProcedureReturn MCP_SQLiteAdmin_XlsxTextCell(row, column, GetDatabaseString(#MCP_SQLiteAdmin_Database, column))
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxWorksheetStart()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + " standalone=" + #DQUOTE$ + "yes" + #DQUOTE$ + "?>" + #LF$
  xml + "<worksheet xmlns=" + #DQUOTE$ + "http://schemas.openxmlformats.org/spreadsheetml/2006/main" + #DQUOTE$ + ">" + #LF$
  xml + "<sheetData>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxWorksheetEnd()
  ProcedureReturn "</sheetData></worksheet>" + #LF$
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxContentTypes()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + " standalone=" + #DQUOTE$ + "yes" + #DQUOTE$ + "?>" + #LF$
  xml + "<Types xmlns=" + #DQUOTE$ + "http://schemas.openxmlformats.org/package/2006/content-types" + #DQUOTE$ + ">" + #LF$
  xml + "<Default Extension=" + #DQUOTE$ + "rels" + #DQUOTE$ + " ContentType=" + #DQUOTE$ + "application/vnd.openxmlformats-package.relationships+xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<Default Extension=" + #DQUOTE$ + "xml" + #DQUOTE$ + " ContentType=" + #DQUOTE$ + "application/xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<Override PartName=" + #DQUOTE$ + "/xl/workbook.xml" + #DQUOTE$ + " ContentType=" + #DQUOTE$ + "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<Override PartName=" + #DQUOTE$ + "/xl/worksheets/sheet1.xml" + #DQUOTE$ + " ContentType=" + #DQUOTE$ + "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<Override PartName=" + #DQUOTE$ + "/xl/styles.xml" + #DQUOTE$ + " ContentType=" + #DQUOTE$ + "application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<Override PartName=" + #DQUOTE$ + "/docProps/core.xml" + #DQUOTE$ + " ContentType=" + #DQUOTE$ + "application/vnd.openxmlformats-package.core-properties+xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<Override PartName=" + #DQUOTE$ + "/docProps/app.xml" + #DQUOTE$ + " ContentType=" + #DQUOTE$ + "application/vnd.openxmlformats-officedocument.extended-properties+xml" + #DQUOTE$ + "/>" + #LF$
  xml + "</Types>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxRootRels()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + " standalone=" + #DQUOTE$ + "yes" + #DQUOTE$ + "?>" + #LF$
  xml + "<Relationships xmlns=" + #DQUOTE$ + "http://schemas.openxmlformats.org/package/2006/relationships" + #DQUOTE$ + ">" + #LF$
  xml + "<Relationship Id=" + #DQUOTE$ + "rId1" + #DQUOTE$ + " Type=" + #DQUOTE$ + "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" + #DQUOTE$ + " Target=" + #DQUOTE$ + "xl/workbook.xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<Relationship Id=" + #DQUOTE$ + "rId2" + #DQUOTE$ + " Type=" + #DQUOTE$ + "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" + #DQUOTE$ + " Target=" + #DQUOTE$ + "docProps/core.xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<Relationship Id=" + #DQUOTE$ + "rId3" + #DQUOTE$ + " Type=" + #DQUOTE$ + "http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" + #DQUOTE$ + " Target=" + #DQUOTE$ + "docProps/app.xml" + #DQUOTE$ + "/>" + #LF$
  xml + "</Relationships>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxWorkbook()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + " standalone=" + #DQUOTE$ + "yes" + #DQUOTE$ + "?>" + #LF$
  xml + "<workbook xmlns=" + #DQUOTE$ + "http://schemas.openxmlformats.org/spreadsheetml/2006/main" + #DQUOTE$ + " xmlns:r=" + #DQUOTE$ + "http://schemas.openxmlformats.org/officeDocument/2006/relationships" + #DQUOTE$ + ">" + #LF$
  xml + "<sheets><sheet name=" + #DQUOTE$ + "QueryResult" + #DQUOTE$ + " sheetId=" + #DQUOTE$ + "1" + #DQUOTE$ + " r:id=" + #DQUOTE$ + "rId1" + #DQUOTE$ + "/></sheets>" + #LF$
  xml + "</workbook>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxWorkbookRels()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + " standalone=" + #DQUOTE$ + "yes" + #DQUOTE$ + "?>" + #LF$
  xml + "<Relationships xmlns=" + #DQUOTE$ + "http://schemas.openxmlformats.org/package/2006/relationships" + #DQUOTE$ + ">" + #LF$
  xml + "<Relationship Id=" + #DQUOTE$ + "rId1" + #DQUOTE$ + " Type=" + #DQUOTE$ + "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" + #DQUOTE$ + " Target=" + #DQUOTE$ + "worksheets/sheet1.xml" + #DQUOTE$ + "/>" + #LF$
  xml + "<Relationship Id=" + #DQUOTE$ + "rId2" + #DQUOTE$ + " Type=" + #DQUOTE$ + "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" + #DQUOTE$ + " Target=" + #DQUOTE$ + "styles.xml" + #DQUOTE$ + "/>" + #LF$
  xml + "</Relationships>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxStyles()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + " standalone=" + #DQUOTE$ + "yes" + #DQUOTE$ + "?>" + #LF$
  xml + "<styleSheet xmlns=" + #DQUOTE$ + "http://schemas.openxmlformats.org/spreadsheetml/2006/main" + #DQUOTE$ + ">" + #LF$
  xml + "<fonts count=" + #DQUOTE$ + "1" + #DQUOTE$ + "><font><sz val=" + #DQUOTE$ + "11" + #DQUOTE$ + "/><name val=" + #DQUOTE$ + "Calibri" + #DQUOTE$ + "/></font></fonts>" + #LF$
  xml + "<fills count=" + #DQUOTE$ + "1" + #DQUOTE$ + "><fill><patternFill patternType=" + #DQUOTE$ + "none" + #DQUOTE$ + "/></fill></fills>" + #LF$
  xml + "<borders count=" + #DQUOTE$ + "1" + #DQUOTE$ + "><border><left/><right/><top/><bottom/><diagonal/></border></borders>" + #LF$
  xml + "<cellStyleXfs count=" + #DQUOTE$ + "1" + #DQUOTE$ + "><xf numFmtId=" + #DQUOTE$ + "0" + #DQUOTE$ + " fontId=" + #DQUOTE$ + "0" + #DQUOTE$ + " fillId=" + #DQUOTE$ + "0" + #DQUOTE$ + " borderId=" + #DQUOTE$ + "0" + #DQUOTE$ + "/></cellStyleXfs>" + #LF$
  xml + "<cellXfs count=" + #DQUOTE$ + "1" + #DQUOTE$ + "><xf numFmtId=" + #DQUOTE$ + "0" + #DQUOTE$ + " fontId=" + #DQUOTE$ + "0" + #DQUOTE$ + " fillId=" + #DQUOTE$ + "0" + #DQUOTE$ + " borderId=" + #DQUOTE$ + "0" + #DQUOTE$ + " xfId=" + #DQUOTE$ + "0" + #DQUOTE$ + "/></cellXfs>" + #LF$
  xml + "<cellStyles count=" + #DQUOTE$ + "1" + #DQUOTE$ + "><cellStyle name=" + #DQUOTE$ + "Normal" + #DQUOTE$ + " xfId=" + #DQUOTE$ + "0" + #DQUOTE$ + " builtinId=" + #DQUOTE$ + "0" + #DQUOTE$ + "/></cellStyles>" + #LF$
  xml + "</styleSheet>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxCoreProperties()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + " standalone=" + #DQUOTE$ + "yes" + #DQUOTE$ + "?>" + #LF$
  xml + "<cp:coreProperties xmlns:cp=" + #DQUOTE$ + "http://schemas.openxmlformats.org/package/2006/metadata/core-properties" + #DQUOTE$
  xml + " xmlns:dc=" + #DQUOTE$ + "http://purl.org/dc/elements/1.1/" + #DQUOTE$
  xml + " xmlns:dcterms=" + #DQUOTE$ + "http://purl.org/dc/terms/" + #DQUOTE$
  xml + " xmlns:dcmitype=" + #DQUOTE$ + "http://purl.org/dc/dcmitype/" + #DQUOTE$
  xml + " xmlns:xsi=" + #DQUOTE$ + "http://www.w3.org/2001/XMLSchema-instance" + #DQUOTE$ + ">" + #LF$
  xml + "<dc:creator>PureBasic JSON-RPC SQLite Admin MCP</dc:creator><cp:lastModifiedBy>PureBasic JSON-RPC SQLite Admin MCP</cp:lastModifiedBy>" + #LF$
  xml + "</cp:coreProperties>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.s MCP_SQLiteAdmin_XlsxAppProperties()
  Protected xml.s

  xml = "<?xml version=" + #DQUOTE$ + "1.0" + #DQUOTE$ + " encoding=" + #DQUOTE$ + "UTF-8" + #DQUOTE$ + " standalone=" + #DQUOTE$ + "yes" + #DQUOTE$ + "?>" + #LF$
  xml + "<Properties xmlns=" + #DQUOTE$ + "http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" + #DQUOTE$
  xml + " xmlns:vt=" + #DQUOTE$ + "http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes" + #DQUOTE$ + ">" + #LF$
  xml + "<Application>PureBasic JSON-RPC SQLite Admin MCP</Application>" + #LF$
  xml + "</Properties>" + #LF$

  ProcedureReturn xml
EndProcedure

Procedure.i MCP_SQLiteAdmin_WriteXlsxPackage(outputPath.s, worksheetXml.s)
  Protected pack.i
  Protected ok.i

  pack = CreatePack(#PB_Any, outputPath, #PB_PackerPlugin_Zip, 0)
  If pack = 0
    ProcedureReturn #False
  EndIf

  ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "[Content_Types].xml", MCP_SQLiteAdmin_XlsxContentTypes())
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "_rels/.rels", MCP_SQLiteAdmin_XlsxRootRels())
  EndIf
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "xl/workbook.xml", MCP_SQLiteAdmin_XlsxWorkbook())
  EndIf
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "xl/_rels/workbook.xml.rels", MCP_SQLiteAdmin_XlsxWorkbookRels())
  EndIf
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "xl/worksheets/sheet1.xml", worksheetXml)
  EndIf
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "xl/styles.xml", MCP_SQLiteAdmin_XlsxStyles())
  EndIf
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "docProps/core.xml", MCP_SQLiteAdmin_XlsxCoreProperties())
  EndIf
  If ok
    ok = MCP_SQLiteAdmin_AddPackUtf8String(pack, "docProps/app.xml", MCP_SQLiteAdmin_XlsxAppProperties())
  EndIf

  ClosePack(pack)

  If ok = #False
    DeleteFile(outputPath)
  EndIf

  ProcedureReturn ok
EndProcedure

Procedure.s MCP_SQLiteAdmin_CsvCell(column.i)
  If CheckDatabaseNull(#MCP_SQLiteAdmin_Database, column)
    ProcedureReturn MCP_SQLiteAdmin_CsvField("")
  EndIf

  ProcedureReturn MCP_SQLiteAdmin_CsvField(GetDatabaseString(#MCP_SQLiteAdmin_Database, column))
EndProcedure

Procedure.i MCP_SQLiteAdmin_WriteCsvHeader(file.i, columns.i)
  Protected column.i
  Protected line.s

  For column = 0 To columns - 1
    If column > 0
      line + ","
    EndIf
    line + MCP_SQLiteAdmin_CsvField(DatabaseColumnName(#MCP_SQLiteAdmin_Database, column))
  Next

  ProcedureReturn WriteString(file, line + #CRLF$, #PB_UTF8)
EndProcedure

Procedure.i MCP_SQLiteAdmin_WriteCsvRow(file.i, columns.i)
  Protected column.i
  Protected line.s

  For column = 0 To columns - 1
    If column > 0
      line + ","
    EndIf
    line + MCP_SQLiteAdmin_CsvCell(column)
  Next

  ProcedureReturn WriteString(file, line + #CRLF$, #PB_UTF8)
EndProcedure

Procedure.s MCP_SQLiteAdmin_RunQuery(dbPath.s, sql.s, maxRows.i, *result.MCP_SQLiteAdmin_Result)
  Protected columns.i
  Protected column.i
  Protected rowCount.i
  Protected emittedRows.i
  Protected truncated.i
  Protected json.s
  Protected dbResult.MCP_SQLiteAdmin_Result

  MCP_SQLiteAdmin_ResetResult(*result)
  If maxRows <= 0
    maxRows = #MCP_SQLiteAdmin_DefaultMaxRows
  EndIf

  If maxRows > 500
    maxRows = 500
  EndIf

  If MCP_SQLiteAdmin_OpenDatabase(dbPath, #False, @dbResult) = #False
    *result\text = dbResult\text
    ProcedureReturn ""
  EndIf

  If DatabaseQuery(#MCP_SQLiteAdmin_Database, sql) = 0
    *result\text = DatabaseError()
    CloseDatabase(#MCP_SQLiteAdmin_Database)
    ProcedureReturn ""
  EndIf

  columns = DatabaseColumns(#MCP_SQLiteAdmin_Database)
  json = ~"{\"columns\":["
  For column = 0 To columns - 1
    If column > 0
      json + ","
    EndIf
    json + MCP_SQLiteAdmin_JsonString(DatabaseColumnName(#MCP_SQLiteAdmin_Database, column))
  Next
  json + ~"],\"rows\":["

  While NextDatabaseRow(#MCP_SQLiteAdmin_Database)
    If emittedRows < maxRows
      If emittedRows > 0
        json + ","
      EndIf
      json + "["
      For column = 0 To columns - 1
        If column > 0
          json + ","
        EndIf
        json + MCP_SQLiteAdmin_CellJson(column)
      Next
      json + "]"
      emittedRows + 1
    Else
      truncated = #True
    EndIf
    rowCount + 1
  Wend

  FinishDatabaseQuery(#MCP_SQLiteAdmin_Database)
  CloseDatabase(#MCP_SQLiteAdmin_Database)

  json + ~"],\"rowCount\":" + Str(rowCount) + ~",\"returnedRows\":" + Str(emittedRows) + ~",\"truncated\":" + MCP_SQLiteAdmin_BoolJson(truncated) + "}"
  *result\ok = #True
  *result\isError = #False
  *result\text = MCP_SQLiteAdmin_BoundText(json)
  ProcedureReturn *result\text
EndProcedure

Procedure.i MCP_SQLiteAdmin_RunExecute(dbPath.s, sql.s, *result.MCP_SQLiteAdmin_Result)
  Protected dbResult.MCP_SQLiteAdmin_Result
  Protected affected.i

  MCP_SQLiteAdmin_ResetResult(*result)
  If MCP_SQLiteAdmin_OpenDatabase(dbPath, #False, @dbResult) = #False
    *result\text = dbResult\text
    ProcedureReturn #False
  EndIf

  If DatabaseUpdate(#MCP_SQLiteAdmin_Database, sql) = 0
    *result\text = DatabaseError()
    CloseDatabase(#MCP_SQLiteAdmin_Database)
    ProcedureReturn #False
  EndIf

  affected = AffectedDatabaseRows(#MCP_SQLiteAdmin_Database)
  CloseDatabase(#MCP_SQLiteAdmin_Database)
  *result\ok = #True
  *result\isError = #False
  *result\text = ~"{\"ok\":true,\"affectedRows\":" + Str(affected) + "}"
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_RunCsvExport(dbPath.s, sql.s, outputPath.s, maxRows.i, overwrite.i, *result.MCP_SQLiteAdmin_Result)
  Protected dbResult.MCP_SQLiteAdmin_Result
  Protected columns.i
  Protected exportedRows.i
  Protected truncated.i
  Protected file.i
  Protected outputDirectory.s

  MCP_SQLiteAdmin_ResetResult(*result)
  If maxRows <= 0
    maxRows = #MCP_SQLiteAdmin_DefaultExportMaxRows
  EndIf

  If maxRows > #MCP_SQLiteAdmin_MaxExportRows
    maxRows = #MCP_SQLiteAdmin_MaxExportRows
  EndIf

  outputDirectory = GetPathPart(outputPath)
  If MCP_SQLiteAdmin_EnsureDirectory(outputDirectory) = #False
    *result\text = "Unable to create CSV export directory: " + outputDirectory
    ProcedureReturn #False
  EndIf

  If FileSize(outputPath) >= 0 And overwrite = #False
    *result\text = "CSV export file already exists. Set overwrite=true to replace it."
    ProcedureReturn #False
  EndIf

  If MCP_SQLiteAdmin_OpenDatabase(dbPath, #False, @dbResult) = #False
    *result\text = dbResult\text
    ProcedureReturn #False
  EndIf

  If DatabaseQuery(#MCP_SQLiteAdmin_Database, sql) = 0
    *result\text = DatabaseError()
    CloseDatabase(#MCP_SQLiteAdmin_Database)
    ProcedureReturn #False
  EndIf

  file = CreateFile(#PB_Any, outputPath)
  If file = 0
    *result\text = "Unable to create CSV export file: " + outputPath
    FinishDatabaseQuery(#MCP_SQLiteAdmin_Database)
    CloseDatabase(#MCP_SQLiteAdmin_Database)
    ProcedureReturn #False
  EndIf

  WriteStringFormat(file, #PB_UTF8)
  columns = DatabaseColumns(#MCP_SQLiteAdmin_Database)
  If MCP_SQLiteAdmin_WriteCsvHeader(file, columns) = #False
    *result\text = "Unable to write CSV header: " + outputPath
    CloseFile(file)
    FinishDatabaseQuery(#MCP_SQLiteAdmin_Database)
    CloseDatabase(#MCP_SQLiteAdmin_Database)
    ProcedureReturn #False
  EndIf

  While NextDatabaseRow(#MCP_SQLiteAdmin_Database)
    If exportedRows >= maxRows
      truncated = #True
      Break
    EndIf

    If MCP_SQLiteAdmin_WriteCsvRow(file, columns) = #False
      *result\text = "Unable to write CSV row: " + outputPath
      CloseFile(file)
      FinishDatabaseQuery(#MCP_SQLiteAdmin_Database)
      CloseDatabase(#MCP_SQLiteAdmin_Database)
      ProcedureReturn #False
    EndIf

    exportedRows + 1
  Wend

  CloseFile(file)
  FinishDatabaseQuery(#MCP_SQLiteAdmin_Database)
  CloseDatabase(#MCP_SQLiteAdmin_Database)

  *result\ok = #True
  *result\isError = #False
  *result\text = ~"{\"path\":\"" + JSONRPC_Protocol_EscapeString(outputPath) + ~"\",\"format\":\"csv\",\"encoding\":\"UTF-8 with BOM\",\"quotedFields\":true,\"lineEnding\":\"CRLF\",\"exportedRows\":" + Str(exportedRows) + ~",\"truncated\":" + MCP_SQLiteAdmin_BoolJson(truncated) + "}"
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_RunOdsExport(dbPath.s, sql.s, outputPath.s, maxRows.i, overwrite.i, *result.MCP_SQLiteAdmin_Result)
  Protected dbResult.MCP_SQLiteAdmin_Result
  Protected columns.i
  Protected column.i
  Protected exportedRows.i
  Protected truncated.i
  Protected outputDirectory.s
  Protected contentXml.s

  MCP_SQLiteAdmin_ResetResult(*result)
  If maxRows <= 0
    maxRows = #MCP_SQLiteAdmin_DefaultExportMaxRows
  EndIf

  If maxRows > #MCP_SQLiteAdmin_MaxExportRows
    maxRows = #MCP_SQLiteAdmin_MaxExportRows
  EndIf

  outputDirectory = GetPathPart(outputPath)
  If MCP_SQLiteAdmin_EnsureDirectory(outputDirectory) = #False
    *result\text = "Unable to create ODS export directory: " + outputDirectory
    ProcedureReturn #False
  EndIf

  If FileSize(outputPath) >= 0 And overwrite = #False
    *result\text = "ODS export file already exists. Set overwrite=true to replace it."
    ProcedureReturn #False
  EndIf

  If MCP_SQLiteAdmin_OpenDatabase(dbPath, #False, @dbResult) = #False
    *result\text = dbResult\text
    ProcedureReturn #False
  EndIf

  If DatabaseQuery(#MCP_SQLiteAdmin_Database, sql) = 0
    *result\text = DatabaseError()
    CloseDatabase(#MCP_SQLiteAdmin_Database)
    ProcedureReturn #False
  EndIf

  columns = DatabaseColumns(#MCP_SQLiteAdmin_Database)
  contentXml = MCP_SQLiteAdmin_OdsContentStart(columns)
  contentXml + "<table:table-row>"
  For column = 0 To columns - 1
    contentXml + MCP_SQLiteAdmin_OdsTextCell(DatabaseColumnName(#MCP_SQLiteAdmin_Database, column))
  Next
  contentXml + "</table:table-row>" + #LF$

  While NextDatabaseRow(#MCP_SQLiteAdmin_Database)
    If exportedRows >= maxRows
      truncated = #True
      Break
    EndIf

    contentXml + "<table:table-row>"
    For column = 0 To columns - 1
      contentXml + MCP_SQLiteAdmin_OdsCell(column)
    Next
    contentXml + "</table:table-row>" + #LF$
    exportedRows + 1
  Wend

  contentXml + MCP_SQLiteAdmin_OdsContentEnd()

  FinishDatabaseQuery(#MCP_SQLiteAdmin_Database)
  CloseDatabase(#MCP_SQLiteAdmin_Database)

  If MCP_SQLiteAdmin_WriteOdsPackage(outputPath, contentXml) = #False
    *result\text = "Unable to create ODS export package: " + outputPath
    ProcedureReturn #False
  EndIf

  *result\ok = #True
  *result\isError = #False
  *result\text = ~"{\"path\":\"" + JSONRPC_Protocol_EscapeString(outputPath) + ~"\",\"format\":\"ods\",\"mediaType\":\"" + #MCP_SQLiteAdmin_OdsMimeType$ + ~"\",\"encoding\":\"UTF-8 XML\",\"sheet\":\"QueryResult\",\"stringCells\":true,\"exportedRows\":" + Str(exportedRows) + ~",\"truncated\":" + MCP_SQLiteAdmin_BoolJson(truncated) + "}"
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_RunXlsxExport(dbPath.s, sql.s, outputPath.s, maxRows.i, overwrite.i, *result.MCP_SQLiteAdmin_Result)
  Protected dbResult.MCP_SQLiteAdmin_Result
  Protected columns.i
  Protected column.i
  Protected exportedRows.i
  Protected truncated.i
  Protected outputDirectory.s
  Protected worksheetXml.s
  Protected rowNumber.i

  MCP_SQLiteAdmin_ResetResult(*result)
  If maxRows <= 0
    maxRows = #MCP_SQLiteAdmin_DefaultExportMaxRows
  EndIf

  If maxRows > #MCP_SQLiteAdmin_MaxExportRows
    maxRows = #MCP_SQLiteAdmin_MaxExportRows
  EndIf

  outputDirectory = GetPathPart(outputPath)
  If MCP_SQLiteAdmin_EnsureDirectory(outputDirectory) = #False
    *result\text = "Unable to create XLSX export directory: " + outputDirectory
    ProcedureReturn #False
  EndIf

  If FileSize(outputPath) >= 0 And overwrite = #False
    *result\text = "XLSX export file already exists. Set overwrite=true to replace it."
    ProcedureReturn #False
  EndIf

  If MCP_SQLiteAdmin_OpenDatabase(dbPath, #False, @dbResult) = #False
    *result\text = dbResult\text
    ProcedureReturn #False
  EndIf

  If DatabaseQuery(#MCP_SQLiteAdmin_Database, sql) = 0
    *result\text = DatabaseError()
    CloseDatabase(#MCP_SQLiteAdmin_Database)
    ProcedureReturn #False
  EndIf

  columns = DatabaseColumns(#MCP_SQLiteAdmin_Database)
  worksheetXml = MCP_SQLiteAdmin_XlsxWorksheetStart()
  rowNumber = 1
  worksheetXml + "<row r=" + #DQUOTE$ + Str(rowNumber) + #DQUOTE$ + ">"
  For column = 0 To columns - 1
    worksheetXml + MCP_SQLiteAdmin_XlsxTextCell(rowNumber, column, DatabaseColumnName(#MCP_SQLiteAdmin_Database, column))
  Next
  worksheetXml + "</row>" + #LF$

  While NextDatabaseRow(#MCP_SQLiteAdmin_Database)
    If exportedRows >= maxRows
      truncated = #True
      Break
    EndIf

    rowNumber + 1
    worksheetXml + "<row r=" + #DQUOTE$ + Str(rowNumber) + #DQUOTE$ + ">"
    For column = 0 To columns - 1
      worksheetXml + MCP_SQLiteAdmin_XlsxCell(rowNumber, column)
    Next
    worksheetXml + "</row>" + #LF$
    exportedRows + 1
  Wend

  worksheetXml + MCP_SQLiteAdmin_XlsxWorksheetEnd()

  FinishDatabaseQuery(#MCP_SQLiteAdmin_Database)
  CloseDatabase(#MCP_SQLiteAdmin_Database)

  If MCP_SQLiteAdmin_WriteXlsxPackage(outputPath, worksheetXml) = #False
    *result\text = "Unable to create XLSX export package: " + outputPath
    ProcedureReturn #False
  EndIf

  *result\ok = #True
  *result\isError = #False
  *result\text = ~"{\"path\":\"" + JSONRPC_Protocol_EscapeString(outputPath) + ~"\",\"format\":\"xlsx\",\"mediaType\":\"" + #MCP_SQLiteAdmin_XlsxMimeType$ + ~"\",\"encoding\":\"UTF-8 XML in OOXML ZIP\",\"sheet\":\"QueryResult\",\"stringCells\":true,\"inlineStrings\":true,\"macroFree\":true,\"exportedRows\":" + Str(exportedRows) + ~",\"truncated\":" + MCP_SQLiteAdmin_BoolJson(truncated) + "}"
  ProcedureReturn #True
EndProcedure

Procedure MCP_SQLiteAdmin_InitArgState(*state.MCP_SQLiteAdmin_ArgState)
  *state\ok = #True
  *state\message = ""
EndProcedure

Procedure.s MCP_SQLiteAdmin_StringArg(argumentsValue, name.s, defaultValue.s, *state.MCP_SQLiteAdmin_ArgState)
  Protected value

  If *state\ok = #False Or argumentsValue = 0
    ProcedureReturn defaultValue
  EndIf

  value = GetJSONMember(argumentsValue, name)
  If value = 0
    ProcedureReturn defaultValue
  EndIf

  If JSONType(value) <> #PB_JSON_String
    *state\ok = #False
    *state\message = name + " must be a string"
    ProcedureReturn defaultValue
  EndIf

  ProcedureReturn GetJSONString(value)
EndProcedure

Procedure.i MCP_SQLiteAdmin_BoolArg(argumentsValue, name.s, defaultValue.i, *state.MCP_SQLiteAdmin_ArgState)
  Protected value

  If *state\ok = #False Or argumentsValue = 0
    ProcedureReturn defaultValue
  EndIf

  value = GetJSONMember(argumentsValue, name)
  If value = 0
    ProcedureReturn defaultValue
  EndIf

  If JSONType(value) <> #PB_JSON_Boolean
    *state\ok = #False
    *state\message = name + " must be a boolean"
    ProcedureReturn defaultValue
  EndIf

  ProcedureReturn GetJSONBoolean(value)
EndProcedure

Procedure.i MCP_SQLiteAdmin_IntArg(argumentsValue, name.s, defaultValue.i, minimum.i, maximum.i, *state.MCP_SQLiteAdmin_ArgState)
  Protected value
  Protected result.i

  If *state\ok = #False Or argumentsValue = 0
    ProcedureReturn defaultValue
  EndIf

  value = GetJSONMember(argumentsValue, name)
  If value = 0
    ProcedureReturn defaultValue
  EndIf

  If JSONType(value) <> #PB_JSON_Number
    *state\ok = #False
    *state\message = name + " must be a number"
    ProcedureReturn defaultValue
  EndIf

  result = GetJSONInteger(value)
  If result < minimum Or result > maximum
    *state\ok = #False
    *state\message = name + " is outside the allowed range"
    ProcedureReturn defaultValue
  EndIf

  ProcedureReturn result
EndProcedure

Procedure.s MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, name.s, *state.MCP_SQLiteAdmin_ArgState)
  Protected value.s

  value = MCP_SQLiteAdmin_StringArg(argumentsValue, name, "", *state)
  If *state\ok And value = ""
    *state\ok = #False
    *state\message = name + " is required"
  EndIf

  ProcedureReturn value
EndProcedure

Procedure.s MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, *state.MCP_SQLiteAdmin_ArgState)
  Protected path.s
  Protected errorMessage.String

  path = MCP_SQLiteAdmin_StringArg(argumentsValue, "dbPath", "", *state)
  If *state\ok = #False
    ProcedureReturn ""
  EndIf

  path = MCP_SQLiteAdmin_ResolvePath(path, @errorMessage)
  If path = ""
    *state\ok = #False
    *state\message = errorMessage\s
  EndIf

  ProcedureReturn path
EndProcedure

Procedure.i MCP_SQLiteAdmin_RequireExistingDb(dbPath.s, *state.MCP_SQLiteAdmin_ArgState)
  If *state\ok = #False
    ProcedureReturn #False
  EndIf

  If FileSize(dbPath) < 0
    *state\ok = #False
    *state\message = "SQLite file does not exist: " + dbPath
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_BootstrapHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected overwrite.i
  Protected toolResult.MCP_SQLiteAdmin_Result
  Protected errorMessage.String

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_StringArg(argumentsValue, "dbPath", "", @args)
  overwrite = MCP_SQLiteAdmin_BoolArg(argumentsValue, "overwrite", #False, @args)
  If args\ok = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  If MCP_SQLiteAdmin_ResolvePath(dbPath, @errorMessage) = ""
    MCP_SQLiteAdmin_SetInvalidParams(*result, errorMessage\s)
    ProcedureReturn #True
  EndIf

  MCP_SQLiteAdmin_BootstrapDatabase(dbPath, overwrite, @toolResult)
  MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_InspectHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected includeSystem.i
  Protected sql.s
  Protected toolResult.MCP_SQLiteAdmin_Result

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, @args)
  includeSystem = MCP_SQLiteAdmin_BoolArg(argumentsValue, "includeSystem", #False, @args)
  If MCP_SQLiteAdmin_RequireExistingDb(dbPath, @args) = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  sql = "SELECT type, name, tbl_name, sql FROM sqlite_schema"
  If includeSystem = #False
    sql + " WHERE name NOT LIKE 'sqlite_%'"
  EndIf
  sql + " ORDER BY type, name"

  MCP_SQLiteAdmin_RunQuery(dbPath, sql, 200, @toolResult)
  MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_QueryHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected sql.s
  Protected maxRows.i
  Protected toolResult.MCP_SQLiteAdmin_Result

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, @args)
  sql = MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, "sql", @args)
  maxRows = MCP_SQLiteAdmin_IntArg(argumentsValue, "maxRows", #MCP_SQLiteAdmin_DefaultMaxRows, 1, 500, @args)
  If MCP_SQLiteAdmin_RequireExistingDb(dbPath, @args) = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  MCP_SQLiteAdmin_RunQuery(dbPath, sql, maxRows, @toolResult)
  MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_ExportHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected sql.s
  Protected outputInput.s
  Protected outputPath.s
  Protected format.s
  Protected maxRows.i
  Protected overwrite.i
  Protected errorMessage.String
  Protected toolResult.MCP_SQLiteAdmin_Result

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, @args)
  sql = MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, "sql", @args)
  outputInput = MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, "outputPath", @args)
  format = MCP_SQLiteAdmin_StringArg(argumentsValue, "format", "csv", @args)
  maxRows = MCP_SQLiteAdmin_IntArg(argumentsValue, "maxRows", #MCP_SQLiteAdmin_DefaultExportMaxRows, 1, #MCP_SQLiteAdmin_MaxExportRows, @args)
  overwrite = MCP_SQLiteAdmin_BoolArg(argumentsValue, "overwrite", #False, @args)
  If MCP_SQLiteAdmin_RequireExistingDb(dbPath, @args) = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  format = LCase(format)
  If format <> "csv" And format <> "ods" And format <> "xlsx"
    MCP_SQLiteAdmin_SetInvalidParams(*result, "sqlite/export supports csv, ods, and xlsx formats")
    ProcedureReturn #True
  EndIf

  If format = "csv" And LCase(Right(outputInput, 4)) <> ".csv"
    MCP_SQLiteAdmin_SetInvalidParams(*result, "outputPath must end with .csv")
    ProcedureReturn #True
  EndIf

  If format = "ods" And LCase(Right(outputInput, 4)) <> ".ods"
    MCP_SQLiteAdmin_SetInvalidParams(*result, "outputPath must end with .ods")
    ProcedureReturn #True
  EndIf

  If format = "xlsx" And LCase(Right(outputInput, 5)) <> ".xlsx"
    MCP_SQLiteAdmin_SetInvalidParams(*result, "outputPath must end with .xlsx")
    ProcedureReturn #True
  EndIf

  outputPath = MCP_SQLiteAdmin_ResolvePath(outputInput, @errorMessage)
  If outputPath = ""
    MCP_SQLiteAdmin_SetInvalidParams(*result, errorMessage\s)
    ProcedureReturn #True
  EndIf

  If format = "xlsx"
    MCP_SQLiteAdmin_RunXlsxExport(dbPath, sql, outputPath, maxRows, overwrite, @toolResult)
  ElseIf format = "ods"
    MCP_SQLiteAdmin_RunOdsExport(dbPath, sql, outputPath, maxRows, overwrite, @toolResult)
  Else
    MCP_SQLiteAdmin_RunCsvExport(dbPath, sql, outputPath, maxRows, overwrite, @toolResult)
  EndIf
  MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_ExecuteHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected sql.s
  Protected toolResult.MCP_SQLiteAdmin_Result

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, @args)
  sql = MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, "sql", @args)
  If MCP_SQLiteAdmin_RequireExistingDb(dbPath, @args) = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  MCP_SQLiteAdmin_RunExecute(dbPath, sql, @toolResult)
  MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_BackupHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected backupInput.s
  Protected backupPath.s
  Protected overwrite.i
  Protected errorMessage.String

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, @args)
  backupInput = MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, "backupPath", @args)
  overwrite = MCP_SQLiteAdmin_BoolArg(argumentsValue, "overwrite", #False, @args)
  If MCP_SQLiteAdmin_RequireExistingDb(dbPath, @args) = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  backupPath = MCP_SQLiteAdmin_ResolvePath(backupInput, @errorMessage)
  If backupPath = ""
    MCP_SQLiteAdmin_SetInvalidParams(*result, errorMessage\s)
    ProcedureReturn #True
  EndIf

  If FileSize(backupPath) >= 0 And overwrite = #False
    MCP_SQLiteAdmin_SetMCPResult(*result, "Backup file already exists. Set overwrite=true to replace it.", #True)
    ProcedureReturn #True
  EndIf

  If CopyFile(dbPath, backupPath)
    MCP_SQLiteAdmin_SetMCPResult(*result, "SQLite backup written to " + backupPath + ".")
  Else
    MCP_SQLiteAdmin_SetMCPResult(*result, "Unable to write backup to " + backupPath + ".", #True)
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_MaintenanceHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected operation.s
  Protected toolResult.MCP_SQLiteAdmin_Result

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, @args)
  operation = MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, "operation", @args)
  If MCP_SQLiteAdmin_RequireExistingDb(dbPath, @args) = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  Select operation
    Case "quick_check"
      MCP_SQLiteAdmin_RunQuery(dbPath, "PRAGMA quick_check", 20, @toolResult)
      MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
    Case "integrity_check"
      MCP_SQLiteAdmin_RunQuery(dbPath, "PRAGMA integrity_check", 50, @toolResult)
      MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
    Case "vacuum"
      MCP_SQLiteAdmin_RunExecute(dbPath, "VACUUM", @toolResult)
      MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
    Default
      MCP_SQLiteAdmin_SetInvalidParams(*result, "operation must be quick_check, integrity_check, or vacuum")
  EndSelect

  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_RecipeListHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected toolResult.MCP_SQLiteAdmin_Result

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, @args)
  If MCP_SQLiteAdmin_RequireExistingDb(dbPath, @args) = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  MCP_SQLiteAdmin_RunQuery(dbPath, "SELECT name, category, description, parameter_notes FROM sql_recipes ORDER BY category, name", 200, @toolResult)
  MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_RecipeSaveHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected name.s
  Protected description.s
  Protected category.s
  Protected sql.s
  Protected parameterNotes.s
  Protected statement.s
  Protected toolResult.MCP_SQLiteAdmin_Result

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, @args)
  name = MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, "name", @args)
  description = MCP_SQLiteAdmin_StringArg(argumentsValue, "description", "", @args)
  category = MCP_SQLiteAdmin_StringArg(argumentsValue, "category", "", @args)
  sql = MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, "sql", @args)
  parameterNotes = MCP_SQLiteAdmin_StringArg(argumentsValue, "parameterNotes", "", @args)
  If MCP_SQLiteAdmin_RequireExistingDb(dbPath, @args) = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  statement = "INSERT OR REPLACE INTO sql_recipes(name,description,category,sql_text,parameter_notes,updated_at) VALUES (" + MCP_SQLiteAdmin_SqlQuote(name) + "," + MCP_SQLiteAdmin_SqlQuote(description) + "," + MCP_SQLiteAdmin_SqlQuote(category) + "," + MCP_SQLiteAdmin_SqlQuote(sql) + "," + MCP_SQLiteAdmin_SqlQuote(parameterNotes) + ",CURRENT_TIMESTAMP)"
  MCP_SQLiteAdmin_RunExecute(dbPath, statement, @toolResult)
  If toolResult\ok
    toolResult\text = "Saved SQL recipe: " + name
  EndIf
  MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
  ProcedureReturn #True
EndProcedure

Procedure.s MCP_SQLiteAdmin_JsonScalarAsSql(value)
  Select JSONType(value)
    Case #PB_JSON_String
      ProcedureReturn MCP_SQLiteAdmin_SqlQuote(GetJSONString(value))
    Case #PB_JSON_Number
      ProcedureReturn MCP_SQLiteAdmin_SqlQuote(Str(GetJSONQuad(value)))
    Case #PB_JSON_Boolean
      ProcedureReturn MCP_SQLiteAdmin_SqlQuote(Str(GetJSONBoolean(value)))
  EndSelect

  ProcedureReturn "NULL"
EndProcedure

Procedure.s MCP_SQLiteAdmin_ApplyRecipeParameters(sql.s, parametersValue, *state.MCP_SQLiteAdmin_ArgState)
  Protected key.s
  Protected value

  If parametersValue = 0
    ProcedureReturn sql
  EndIf

  If JSONType(parametersValue) <> #PB_JSON_Object
    *state\ok = #False
    *state\message = "parameters must be an object"
    ProcedureReturn sql
  EndIf

  If ExamineJSONMembers(parametersValue)
    While NextJSONMember(parametersValue)
      key = JSONMemberKey(parametersValue)
      value = JSONMemberValue(parametersValue)
      Select JSONType(value)
        Case #PB_JSON_String, #PB_JSON_Number, #PB_JSON_Boolean, #PB_JSON_Null
          sql = ReplaceString(sql, ":" + key, MCP_SQLiteAdmin_JsonScalarAsSql(value))
        Default
          *state\ok = #False
          *state\message = "Recipe parameters must be scalar values"
          ProcedureReturn sql
      EndSelect
    Wend
  EndIf

  ProcedureReturn sql
EndProcedure

Procedure.s MCP_SQLiteAdmin_LoadRecipeSql(dbPath.s, name.s, *result.MCP_SQLiteAdmin_Result)
  Protected dbResult.MCP_SQLiteAdmin_Result
  Protected recipeSql.s

  If MCP_SQLiteAdmin_OpenDatabase(dbPath, #False, @dbResult) = #False
    *result\text = dbResult\text
    ProcedureReturn ""
  EndIf

  If DatabaseQuery(#MCP_SQLiteAdmin_Database, "SELECT sql_text FROM sql_recipes WHERE name = " + MCP_SQLiteAdmin_SqlQuote(name)) = 0
    *result\text = DatabaseError()
    CloseDatabase(#MCP_SQLiteAdmin_Database)
    ProcedureReturn ""
  EndIf

  If NextDatabaseRow(#MCP_SQLiteAdmin_Database)
    recipeSql = GetDatabaseString(#MCP_SQLiteAdmin_Database, 0)
  EndIf

  FinishDatabaseQuery(#MCP_SQLiteAdmin_Database)
  CloseDatabase(#MCP_SQLiteAdmin_Database)

  If recipeSql = ""
    *result\text = "Unknown SQL recipe: " + name
  EndIf

  ProcedureReturn recipeSql
EndProcedure

Procedure.i MCP_SQLiteAdmin_RecipeRunHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected name.s
  Protected sql.s
  Protected maxRows.i
  Protected parametersValue
  Protected toolResult.MCP_SQLiteAdmin_Result

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, @args)
  name = MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, "name", @args)
  maxRows = MCP_SQLiteAdmin_IntArg(argumentsValue, "maxRows", #MCP_SQLiteAdmin_DefaultMaxRows, 1, 500, @args)
  If MCP_SQLiteAdmin_RequireExistingDb(dbPath, @args) = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  sql = MCP_SQLiteAdmin_LoadRecipeSql(dbPath, name, @toolResult)
  If sql = ""
    MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, #True)
    ProcedureReturn #True
  EndIf

  parametersValue = GetJSONMember(argumentsValue, "parameters")
  sql = MCP_SQLiteAdmin_ApplyRecipeParameters(sql, parametersValue, @args)
  If args\ok = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  MCP_SQLiteAdmin_RunQuery(dbPath, sql, maxRows, @toolResult)
  MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_RecipeDeleteHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected args.MCP_SQLiteAdmin_ArgState
  Protected dbPath.s
  Protected name.s
  Protected toolResult.MCP_SQLiteAdmin_Result

  MCP_SQLiteAdmin_InitArgState(@args)
  dbPath = MCP_SQLiteAdmin_ResolvedDbPath(argumentsValue, @args)
  name = MCP_SQLiteAdmin_RequiredStringArg(argumentsValue, "name", @args)
  If MCP_SQLiteAdmin_RequireExistingDb(dbPath, @args) = #False
    MCP_SQLiteAdmin_SetInvalidParams(*result, args\message)
    ProcedureReturn #True
  EndIf

  MCP_SQLiteAdmin_RunExecute(dbPath, "DELETE FROM sql_recipes WHERE name = " + MCP_SQLiteAdmin_SqlQuote(name), @toolResult)
  If toolResult\ok
    toolResult\text = "Deleted SQL recipe: " + name
  EndIf
  MCP_SQLiteAdmin_SetMCPResult(*result, toolResult\text, Bool(toolResult\ok = #False))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_SQLiteAdmin_RegisterOne(*registry.MCP_ToolRegistry, name.s, title.s, description.s, schema.s, *handler)
  If MCP_RegisterTool(*registry, name, title, description, schema) = #False
    ProcedureReturn #False
  EndIf

  ProcedureReturn MCP_RegisterToolHandler(*registry, name, *handler)
EndProcedure

Procedure.i MCP_SQLiteAdmin_Register(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)
  If *dispatcher = 0 Or *registry = 0
    ProcedureReturn #False
  EndIf

  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/bootstrap", "SQLite Bootstrap", "Create or recreate the demo SQLite admin database.", #MCP_SQLiteAdmin_BootstrapSchema$, @MCP_SQLiteAdmin_BootstrapHandler()) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/inspect", "SQLite Inspect", "Inspect tables, indexes, triggers, and schema SQL.", #MCP_SQLiteAdmin_InspectSchema$, @MCP_SQLiteAdmin_InspectHandler()) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/query", "SQLite Query", "Run row-returning SQL with bounded JSON text output.", #MCP_SQLiteAdmin_QuerySchema$, @MCP_SQLiteAdmin_QueryHandler()) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/export", "SQLite Export", "Export a row-returning query to canonical CSV, ODS, or XLSX.", #MCP_SQLiteAdmin_ExportSchema$, @MCP_SQLiteAdmin_ExportHandler()) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/execute", "SQLite Execute", "Run non-row SQL statements intentionally.", #MCP_SQLiteAdmin_ExecuteSchema$, @MCP_SQLiteAdmin_ExecuteHandler()) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/backup", "SQLite Backup", "Copy a SQLite file to a safe backup path.", #MCP_SQLiteAdmin_BackupSchema$, @MCP_SQLiteAdmin_BackupHandler()) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/maintenance", "SQLite Maintenance", "Run quick_check, integrity_check, or vacuum.", #MCP_SQLiteAdmin_MaintenanceSchema$, @MCP_SQLiteAdmin_MaintenanceHandler()) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/recipe/list", "SQLite Recipe List", "List saved SQL recipes.", #MCP_SQLiteAdmin_RecipeListSchema$, @MCP_SQLiteAdmin_RecipeListHandler()) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/recipe/save", "SQLite Recipe Save", "Save or update a frequent SQL recipe.", #MCP_SQLiteAdmin_RecipeSaveSchema$, @MCP_SQLiteAdmin_RecipeSaveHandler()) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/recipe/run", "SQLite Recipe Run", "Run a saved SQL recipe with simple scalar parameters.", #MCP_SQLiteAdmin_RecipeRunSchema$, @MCP_SQLiteAdmin_RecipeRunHandler()) = #False
    ProcedureReturn #False
  EndIf
  If MCP_SQLiteAdmin_RegisterOne(*registry, "sqlite/recipe/delete", "SQLite Recipe Delete", "Delete a saved SQL recipe from the catalog.", #MCP_SQLiteAdmin_RecipeDeleteSchema$, @MCP_SQLiteAdmin_RecipeDeleteHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_RegisterToolsList(*dispatcher, *registry) = #False
    ProcedureReturn #False
  EndIf

  ProcedureReturn MCP_RegisterToolsCall(*dispatcher, *registry)
EndProcedure

MCP_SQLiteAdmin_ResetConfig()
