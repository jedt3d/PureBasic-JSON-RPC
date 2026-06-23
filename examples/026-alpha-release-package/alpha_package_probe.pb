EnableExplicit

XIncludeFile "../../src/jsonrpc/jsonrpc.pbi"

Define report.JSONRPC_ComplianceReport

If JSONRPC_LibraryVersion() <> "0.1.0-alpha.1"
  PrintN("unexpected library version: " + JSONRPC_LibraryVersion())
  End 1
EndIf

If JSONRPC_LibraryStatus() <> "alpha"
  PrintN("unexpected library status: " + JSONRPC_LibraryStatus())
  End 1
EndIf

If Not JSONRPC_Compliance_RunCore(@report)
  PrintN("compliance suite failed: " + Str(report\failed))
  End 1
EndIf

PrintN("alpha release package scenario: OK")
End 0
