EnableExplicit

XIncludeFile "sqlite_admin_tool.pbi"

Define result.MCP_SQLiteAdmin_Result
Define dbPath.s

OpenConsole()

MCP_SQLiteAdmin_SetConfig(GetCurrentDirectory() + ".local/sqlite-admin/")

If CountProgramParameters() > 0
  dbPath = ProgramParameter(0)
EndIf

If MCP_SQLiteAdmin_BootstrapDatabase(dbPath, #True, @result)
  PrintN(result\text)
  End 0
EndIf

PrintN(result\text)
End 1
