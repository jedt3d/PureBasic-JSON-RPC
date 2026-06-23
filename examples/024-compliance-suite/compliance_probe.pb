EnableExplicit

XIncludeFile "../../src/jsonrpc/compliance.pbi"

Define report.JSONRPC_ComplianceReport

If JSONRPC_Compliance_RunCore(@report) = #False
  PrintN("compliance failed: " + JSONRPC_Compliance_Summary(@report))
  End 1
EndIf

PrintN("compliance suite scenario: OK")
End 0
