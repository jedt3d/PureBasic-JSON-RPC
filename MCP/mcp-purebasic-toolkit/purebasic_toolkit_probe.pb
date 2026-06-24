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

If FindString(response, #MCP_Toolkit_BriefCreateName$, 1) = 0
  PrintN("tools/list is missing brief create")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_AlgorithmExplainName$, 1) = 0
  PrintN("tools/list is missing algorithm explain")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_DecisionRecordCreateName$, 1) = 0
  PrintN("tools/list is missing decision record create")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_GitPreflightName$, 1) = 0
  PrintN("tools/list is missing git preflight")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_GitCommitSummaryName$, 1) = 0
  PrintN("tools/list is missing git commit summary")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_GithubPrDraftName$, 1) = 0
  PrintN("tools/list is missing github pr draft")
  End 1
EndIf

If FindString(response, #MCP_Toolkit_GithubReleaseDraftName$, 1) = 0
  PrintN("tools/list is missing github release draft")
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

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/brief/create\",\"arguments\":{\"goal\":\"Add a focused PureBasic feature\",\"tests\":\"Focused PureUnit plus check.sh\"}},\"id\":11}")
If FindString(response, "# PureBasic Implementation Brief", 1) = 0 Or FindString(response, "Questions To Clarify", 1) = 0
  PrintN("brief create did not return a pair-development brief")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/algorithm/explain\",\"arguments\":{\"title\":\"Bounded harness execution\",\"flow\":\"Validate arguments, run fixed script, capture bounded output.\"}},\"id\":12}")
If FindString(response, "Algorithm Explanation: Bounded harness execution", 1) = 0 Or FindString(response, "Default Review Checklist", 1) = 0
  PrintN("algorithm explain did not return an implementation flow")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/decision-record/create\",\"arguments\":{\"title\":\"Keep toolkit records under .local\",\"decision\":\"Generated records should stay outside tracked source unless promoted by a human.\"}},\"id\":13}")
If FindString(response, "Decision Record: Keep toolkit records under .local", 1) = 0 Or FindString(response, "Generated records should stay outside tracked source", 1) = 0
  PrintN("decision record create did not return a decision record")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/git/preflight\",\"arguments\":{\"baseBranch\":\"main\"}},\"id\":14}")
If FindString(response, "# Git Preflight", 1) = 0 Or FindString(response, "Mode: read-only inspection", 1) = 0
  PrintN("git preflight did not return read-only inspection")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/git/commit-summary\",\"arguments\":{\"messageHint\":\"feat: add toolkit git workflow\"}},\"id\":15}")
If FindString(response, "Git Commit Summary Draft", 1) = 0 Or FindString(response, "No `git add` or `git commit` was executed", 1) = 0
  PrintN("git commit summary did not return a safe draft")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/github/pr-draft\",\"arguments\":{\"title\":\"Toolkit Git workflow\",\"summary\":\"Add read-only Git workflow helpers.\",\"tests\":\"./tools/check.sh\"}},\"id\":16}")
If FindString(response, "GitHub PR Draft", 1) = 0 Or FindString(response, "No branch was pushed and no PR was opened", 1) = 0
  PrintN("github pr draft did not return a safe PR draft")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/github/release-draft\",\"arguments\":{\"version\":\"0.1.0-alpha.next\",\"highlights\":\"Toolkit Git helpers\",\"verification\":\"./tools/check.sh\"}},\"id\":17}")
If FindString(response, "GitHub Release Draft", 1) = 0 Or FindString(response, "No tag, release, or upload was created", 1) = 0
  PrintN("github release draft did not return a safe release draft")
  End 1
EndIf

PrintN("mcp purebasic toolkit scenario: OK")
End 0
