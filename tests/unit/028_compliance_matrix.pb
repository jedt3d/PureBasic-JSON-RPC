EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "compliance.pbi"

PureUnitOptions(Thread)

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

Procedure.s ReadProjectTextFile(path.s)
  Protected text.s

  text = ReadTextFile(path)
  If text <> ""
    ProcedureReturn text
  EndIf

  text = ReadTextFile("../" + path)
  If text <> ""
    ProcedureReturn text
  EndIf

  text = ReadTextFile("../../" + path)
  If text <> ""
    ProcedureReturn text
  EndIf

  ProcedureReturn ""
EndProcedure

ProcedureUnit ExpandedComplianceRunnerPassesMatrixCases()
  Protected report.JSONRPC_ComplianceReport

  Assert(JSONRPC_Compliance_RunCore(@report), "Expanded compliance runner should pass.")
  Assert(report\failed = 0, "Expanded compliance runner should have no failures.")
  Assert(report\passed >= 17, "Expanded compliance runner should execute matrix cases.")
EndProcedureUnit

ProcedureUnit ComplianceMatrixDocumentsCoreBehavior()
  Protected matrix.s

  matrix = ReadProjectTextFile("docs/jsonrpc-compliance-matrix.md")

  Assert(Len(matrix) > 0, "Compliance matrix should be readable.")
  Assert(FindString(matrix, "Parse error", 1) > 0, "Matrix should document parse errors.")
  Assert(FindString(matrix, "Notification", 1) > 0, "Matrix should document notifications.")
  Assert(FindString(matrix, "Batch mixed", 1) > 0, "Matrix should document mixed batches.")
  Assert(FindString(matrix, "Orphan response", 1) > 0, "Matrix should document orphan responses.")
EndProcedureUnit
