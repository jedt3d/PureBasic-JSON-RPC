EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "jsonrpc.pbi"

PureUnitOptions(Thread)

ProcedureUnit VersionMetadataIsAvailable()
  AssertString(JSONRPC_LibraryName(), "PureBasic JSON-RPC 2.0", "Library name should be exposed.")
  AssertString(JSONRPC_LibraryVersion(), "0.1.0-alpha.1", "Alpha version should be exposed.")
  AssertString(JSONRPC_LibraryStatus(), "alpha", "Library status should be exposed.")
EndProcedureUnit

ProcedureUnit ConsolidatedIncludeExposesCompliance()
  Protected report.JSONRPC_ComplianceReport

  Assert(JSONRPC_Compliance_RunCore(@report), "Consolidated include should expose compliance runner.")
  Assert(report\failed = 0, "Compliance runner should pass through consolidated include.")
EndProcedureUnit
