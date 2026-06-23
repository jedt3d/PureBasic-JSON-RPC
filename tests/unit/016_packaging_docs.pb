EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "jsonrpc.pbi"

PureUnitOptions(Thread)

ProcedureUnit ConsolidatedIncludeExposesJsonRpcAndMcp()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry

  JSONRPC_Dispatcher_Init(@dispatcher)
  MCP_ToolRegistry_Init(@registry)

  Assert(MCP_RegisterTool(@registry, "echo", "Echo", "Echo text", ~"{\"type\":\"object\"}"), "Consolidated include should expose MCP tools.")
  Assert(JSONRPC_RegisterRequest(@dispatcher, "tools/list", @MCP_ToolsListHandler()), "Consolidated include should expose dispatcher API.")
EndProcedureUnit

ProcedureUnit ConsolidatedIncludeCanBuildMcpResult()
  Protected server.MCP_ServerInfo
  Protected result.s

  MCP_ServerInfo_Init(@server, "pb-jsonrpc", "0.1.0")
  result = MCP_BuildInitializeResult(@server)

  Assert(FindString(result, ~"\"protocolVersion\":\"2025-11-25\"", 1) > 0, "Consolidated include should expose lifecycle helpers.")
EndProcedureUnit
