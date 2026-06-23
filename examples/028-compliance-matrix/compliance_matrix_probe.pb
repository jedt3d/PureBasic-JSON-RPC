EnableExplicit

XIncludeFile "../../src/jsonrpc/compliance.pbi"

Procedure.s ReadTextFile(path.s)
  Protected file.i
  Protected text.s

  file = ReadFile(#PB_Any, path, #PB_UTF8)
  If file = 0
    ProcedureReturn ""
  EndIf

  While Eof(file) = 0
    text + ReadString(file, #PB_UTF8) + #LF$
  Wend

  CloseFile(file)
  ProcedureReturn text
EndProcedure

Define report.JSONRPC_ComplianceReport
Define matrix.s

If JSONRPC_Compliance_RunCore(@report) = #False
  PrintN("compliance matrix suite failed: " + JSONRPC_Compliance_Summary(@report))
  End 1
EndIf

If report\passed < 17
  PrintN("compliance matrix suite did not run enough checks: " + Str(report\passed))
  End 1
EndIf

matrix = ReadTextFile("docs/jsonrpc-compliance-matrix.md")
If FindString(matrix, "Parse error", 1) = 0 Or FindString(matrix, "Batch mixed", 1) = 0
  PrintN("compliance matrix document is missing expected coverage rows")
  End 1
EndIf

PrintN("compliance matrix scenario: OK")
End 0
