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

PrintN("mcp purebasic toolkit scenario: OK")
End 0
