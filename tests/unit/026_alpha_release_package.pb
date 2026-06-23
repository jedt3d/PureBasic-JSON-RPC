EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "jsonrpc.pbi"

PureUnitOptions(Thread)

ProcedureUnit AlphaReleaseMetadataIsCoherent()
  AssertString(JSONRPC_LibraryVersion(), "0.1.0-alpha.1", "Alpha package should expose the alpha release version.")
  AssertString(JSONRPC_LibraryStatus(), "alpha", "Alpha package should expose alpha status.")
  Assert(FindString(JSONRPC_LibraryName(), "JSON-RPC") > 0, "Library name should identify JSON-RPC.")
EndProcedureUnit

ProcedureUnit AlphaEntrypointRunsComplianceSuite()
  Protected report.JSONRPC_ComplianceReport

  Assert(JSONRPC_Compliance_RunCore(@report), "Alpha consolidated include should run the compliance suite.")
  Assert(report\passed > 0, "Compliance suite should execute at least one case.")
  Assert(report\failed = 0, "Compliance suite should pass before packaging.")
EndProcedureUnit
