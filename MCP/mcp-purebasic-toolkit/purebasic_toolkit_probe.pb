EnableExplicit

XIncludeFile "../../src/jsonrpc/version.pbi"
XIncludeFile "purebasic_toolkit_tools.pbi"

Define dispatcher.JSONRPC_Dispatcher
Define registry.MCP_ToolRegistry
Define server.MCP_ServerInfo
Define response.s

JSONRPC_Dispatcher_Init(@dispatcher)
MCP_ToolRegistry_Init(@registry)
MCP_ServerInfo_Init(@server, "mcp-purebasic-toolkit-probe", JSONRPC_LibraryVersion(), "PureBasic Toolkit Probe", "Probe the PureBasic development toolkit dispatcher.")

MCP_Toolkit_SetConfig(GetCurrentDirectory())
MCP_RegisterLifecycle(@dispatcher, @server)

If MCP_Toolkit_Register(@dispatcher, @registry) = #False
  PrintN("toolkit registration failed")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}")
If FindString(response, #MCP_Toolkit_ProjectInspectName$, 1) = 0
  PrintN("tools/list is missing project inspect")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_WorkflowBriefName$, 1) = 0
  PrintN("tools/list is missing workflow brief")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_HarnessChecklistName$, 1) = 0
  PrintN("tools/list is missing harness checklist")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_IncludeGraphName$, 1) = 0
  PrintN("tools/list is missing include graph")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_SymbolSearchName$, 1) = 0
  PrintN("tools/list is missing symbol search")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_ProcedureListName$, 1) = 0
  PrintN("tools/list is missing procedure list")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_PbpListTargetsName$, 1) = 0
  PrintN("tools/list is missing pbp target list")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_TestRunName$, 1) = 0
  PrintN("tools/list is missing test run")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_BuildRunName$, 1) = 0
  PrintN("tools/list is missing build run")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_CheckName$, 1) = 0
  PrintN("tools/list is missing check")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_DocsBuildName$, 1) = 0
  PrintN("tools/list is missing docs build")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/project/inspect\",\"arguments\":{}},\"id\":2}")
If FindString(response, "Toolkit milestones: yes", 1) = 0
  PrintN("project inspect did not find toolkit milestones")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/workflow/brief\",\"arguments\":{}},\"id\":3}")
If FindString(response, "Interview and align", 1) = 0
  PrintN("workflow brief is missing pair-development guidance")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/harness/checklist\",\"arguments\":{}},\"id\":4}")
If FindString(response, "./tools/check.sh", 1) = 0
  PrintN("harness checklist is missing full check")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/include/graph\",\"arguments\":{}},\"id\":5}")
If FindString(response, "src/jsonrpc/jsonrpc.pbi -> version.pbi", 1) = 0
  PrintN("include graph is missing jsonrpc include edge")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/symbol/search\",\"arguments\":{\"query\":\"JSONRPC_Dispatcher_Dispatch\"}},\"id\":6}")
If FindString(response, "src/jsonrpc/dispatch.pbi", 1) = 0
  PrintN("symbol search did not find dispatcher source")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/procedure/list\",\"arguments\":{\"prefix\":\"MCP_Toolkit\"}},\"id\":7}")
If FindString(response, "MCP_Toolkit_Register", 1) = 0
  PrintN("procedure list did not find toolkit registration")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/pbp/list-targets\",\"arguments\":{}},\"id\":8}")
If FindString(response, "MCP/mcp-purebasic-toolkit/purebasic_toolkit.pbp", 1) = 0
  PrintN("pbp target list did not find toolkit project")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/check\",\"arguments\":{\"dryRun\":true}},\"id\":9}")
If FindString(response, "Command: ./tools/check.sh", 1) = 0 Or FindString(response, "Mode: dry-run", 1) = 0
  PrintN("check dry run did not describe the bounded harness command")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/docs/build\",\"arguments\":{\"dryRun\":true}},\"id\":10}")
If FindString(response, "Command: ./tools/build-docs.sh", 1) = 0 Or FindString(response, ~"\"isError\":false", 1) = 0
  PrintN("docs build dry run did not return a successful MCP tool result")
  End 1
EndIf

PrintN("mcp purebasic toolkit scenario: OK")
End 0
