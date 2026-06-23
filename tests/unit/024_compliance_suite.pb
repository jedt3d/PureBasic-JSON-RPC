EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "compliance.pbi"

PureUnitOptions(Thread)

ProcedureUnit CoreComplianceSuitePasses()
  Protected report.JSONRPC_ComplianceReport

  Assert(JSONRPC_Compliance_RunCore(@report), "Core JSON-RPC compliance suite should pass.")
  Assert(report\failed = 0, "Compliance suite should report zero failures.")
  Assert(report\passed >= 17, "Compliance suite should run the expanded matrix checks.")
EndProcedureUnit

ProcedureUnit ComplianceSummaryIsJson()
  Protected report.JSONRPC_ComplianceReport
  Protected summary.s

  JSONRPC_Compliance_RunCore(@report)
  summary = JSONRPC_Compliance_Summary(@report)

  Assert(FindString(summary, ~"\"passed\":", 1) > 0, "Summary should contain passed count.")
  Assert(FindString(summary, ~"\"failed\":0", 1) > 0, "Summary should contain failed count.")
EndProcedureUnit
