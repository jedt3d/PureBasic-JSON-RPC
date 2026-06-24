EnableExplicit

XIncludeFile "../../MCP/mcp-purebasic-toolkit/purebasic_toolkit_tools.pbi"

PureUnitOptions(Thread)

Procedure.s ToolkitRoot()
  Protected root.s

  root = GetCurrentDirectory()
  If FileSize(root + "MCP/mcp-purebasic-toolkit/purebasic_toolkit_tools.pbi") >= 0
    ProcedureReturn root
  EndIf

  If FileSize(root + "../../MCP/mcp-purebasic-toolkit/purebasic_toolkit_tools.pbi") >= 0
    ProcedureReturn root + "../../"
  EndIf

  ProcedureReturn root
EndProcedure

Procedure.s WorkstationAbsolutePathMarker()
  ProcedureReturn "/" + "Users" + "/"
EndProcedure

Procedure ToolkitInit(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)
  Protected server.MCP_ServerInfo

  JSONRPC_Dispatcher_Init(*dispatcher)
  MCP_ToolRegistry_Init(*registry)
  MCP_ServerInfo_Init(@server, "toolkit-test", "0", "Toolkit Test", "")
  MCP_Toolkit_SetConfig(ToolkitRoot())
  MCP_RegisterLifecycle(*dispatcher, @server)
  MCP_Toolkit_Register(*dispatcher, *registry)
EndProcedure

ProcedureUnit ToolkitRegistersProjectIntelligenceTools()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}")

  Assert(FindString(response, #MCP_Toolkit_IncludeGraphName$, 1) > 0, "tools/list should include include graph.")
  Assert(FindString(response, #MCP_Toolkit_SymbolSearchName$, 1) > 0, "tools/list should include symbol search.")
  Assert(FindString(response, #MCP_Toolkit_ProcedureListName$, 1) > 0, "tools/list should include procedure list.")
  Assert(FindString(response, #MCP_Toolkit_PbpListTargetsName$, 1) > 0, "tools/list should include pbp target list.")
EndProcedureUnit

ProcedureUnit ToolkitRegistersHarnessExecutionTools()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}")

  Assert(FindString(response, #MCP_Toolkit_TestRunName$, 1) > 0, "tools/list should include test run.")
  Assert(FindString(response, #MCP_Toolkit_BuildRunName$, 1) > 0, "tools/list should include build run.")
  Assert(FindString(response, #MCP_Toolkit_CheckName$, 1) > 0, "tools/list should include check.")
  Assert(FindString(response, #MCP_Toolkit_DocsBuildName$, 1) > 0, "tools/list should include docs build.")
EndProcedureUnit

ProcedureUnit ToolkitRegistersPairDevelopmentRecordTools()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}")

  Assert(FindString(response, #MCP_Toolkit_BriefCreateName$, 1) > 0, "tools/list should include brief create.")
  Assert(FindString(response, #MCP_Toolkit_AlgorithmExplainName$, 1) > 0, "tools/list should include algorithm explain.")
  Assert(FindString(response, #MCP_Toolkit_DecisionRecordCreateName$, 1) > 0, "tools/list should include decision record create.")
EndProcedureUnit

ProcedureUnit ToolkitRegistersGitGithubWorkflowTools()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}")

  Assert(FindString(response, #MCP_Toolkit_GitPreflightName$, 1) > 0, "tools/list should include git preflight.")
  Assert(FindString(response, #MCP_Toolkit_GitCommitSummaryName$, 1) > 0, "tools/list should include git commit summary.")
  Assert(FindString(response, #MCP_Toolkit_GithubPrDraftName$, 1) > 0, "tools/list should include github pr draft.")
  Assert(FindString(response, #MCP_Toolkit_GithubReleaseDraftName$, 1) > 0, "tools/list should include github release draft.")
EndProcedureUnit

ProcedureUnit IncludeGraphContainsJsonRpcEdges()
  Protected text.s

  MCP_Toolkit_SetConfig(ToolkitRoot())
  text = MCP_Toolkit_IncludeGraphText()

  Assert(FindString(text, "src/jsonrpc/jsonrpc.pbi -> version.pbi", 1) > 0, "Include graph should include the consolidated include.")
  Assert(FindString(text, "MCP/mcp-purebasic-toolkit/purebasic_toolkit_server.pb -> ../../src/jsonrpc/version.pbi", 1) > 0, "Include graph should include toolkit server includes.")
  Assert(FindString(text, "purebasic_toolkit_tools.pbi -> PureBasic Include Graph", 1) = 0, "Include graph should not treat string literals as include directives.")
EndProcedureUnit

ProcedureUnit SymbolSearchFindsDispatcher()
  Protected text.s

  MCP_Toolkit_SetConfig(ToolkitRoot())
  text = MCP_Toolkit_SymbolSearchText("JSONRPC_Dispatcher_Dispatch")

  Assert(FindString(text, "src/jsonrpc/dispatch.pbi", 1) > 0, "Symbol search should find dispatcher implementation.")
  Assert(FindString(text, WorkstationAbsolutePathMarker(), 1) = 0, "Symbol search should use repository-relative paths.")
EndProcedureUnit

ProcedureUnit ProcedureListFiltersToolkitPrefix()
  Protected text.s

  MCP_Toolkit_SetConfig(ToolkitRoot())
  text = MCP_Toolkit_ProcedureListText("MCP_Toolkit")

  Assert(FindString(text, "MCP_Toolkit_Register", 1) > 0, "Procedure list should find toolkit registration.")
  Assert(FindString(text, "src/jsonrpc/", 1) = 0, "Prefix-filtered toolkit list should avoid unrelated JSON-RPC procedures.")
EndProcedureUnit

ProcedureUnit PbpTargetsListIncludesToolkitConsoleTargets()
  Protected text.s

  MCP_Toolkit_SetConfig(ToolkitRoot())
  text = MCP_Toolkit_PbpTargetsText()

  Assert(FindString(text, "MCP/mcp-purebasic-toolkit/purebasic_toolkit.pbp", 1) > 0, "PBP target list should include toolkit project.")
  Assert(FindString(text, "mcp-purebasic-toolkit stdio server [console]", 1) > 0, "Toolkit server should be a console target.")
  Assert(FindString(text, WorkstationAbsolutePathMarker(), 1) = 0, "PBP target list should use repository-relative paths.")
EndProcedureUnit

ProcedureUnit SymbolSearchRequiresQuery()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/symbol/search\",\"arguments\":{}},\"id\":2}")

  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "Missing query should return invalid params.")
EndProcedureUnit

ProcedureUnit HarnessCheckDryRunDescribesBoundedExecution()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/check\",\"arguments\":{\"dryRun\":true,\"timeoutMs\":30000,\"maxOutputBytes\":2000}},\"id\":3}")

  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "Dry-run check should not be an MCP tool error.")
  Assert(FindString(response, "Command: ./tools/check.sh", 1) > 0, "Dry-run check should name the harness script.")
  Assert(FindString(response, "Mode: dry-run", 1) > 0, "Dry-run check should report dry-run mode.")
  Assert(FindString(response, WorkstationAbsolutePathMarker(), 1) = 0, "Dry-run check should avoid workstation-specific paths.")
EndProcedureUnit

ProcedureUnit HarnessOptionsRejectInvalidTimeout()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/docs/build\",\"arguments\":{\"timeoutMs\":5}},\"id\":4}")

  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "Invalid timeout should return invalid params.")
EndProcedureUnit

ProcedureUnit HarnessOptionsRejectInvalidOutputLimit()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/build/run\",\"arguments\":{\"maxOutputBytes\":10}},\"id\":5}")

  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "Invalid output limit should return invalid params.")
EndProcedureUnit

ProcedureUnit HarnessRunnerCanExecuteFastVerifier()
  Protected options.MCP_Toolkit_HarnessOptions
  Protected commandResult.MCP_Toolkit_HarnessResult

  MCP_Toolkit_SetConfig(ToolkitRoot())
  options\timeoutMs = 30000
  options\maxOutputBytes = 4000
  MCP_Toolkit_RunHarnessCommand("Path verifier", "tools/verify-paths.sh", @options, @commandResult)

  Assert(commandResult\launched, "Harness runner should launch the fast verifier.")
  Assert(commandResult\timedOut = #False, "Fast verifier should not time out.")
  Assert(commandResult\exitCode = 0, "Fast verifier should exit successfully: " + commandResult\output)
  Assert(FindString(commandResult\output, "Verified tracked files", 1) > 0, "Fast verifier output should be captured.")
  Assert(FindString(commandResult\output, WorkstationAbsolutePathMarker(), 1) = 0, "Captured output should avoid workstation-specific paths.")
EndProcedureUnit

ProcedureUnit BriefCreateReturnsInterviewScaffold()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/brief/create\",\"arguments\":{\"goal\":\"Build a focused PureBasic MCP tool\",\"tests\":\"PureUnit plus probe\"}},\"id\":6}")

  Assert(FindString(response, "# PureBasic Implementation Brief", 1) > 0, "Brief tool should return a markdown brief.")
  Assert(FindString(response, "Build a focused PureBasic MCP tool", 1) > 0, "Brief should include the supplied goal.")
  Assert(FindString(response, "Questions To Clarify", 1) > 0, "Brief should include interview questions.")
EndProcedureUnit

ProcedureUnit AlgorithmExplainReturnsReviewChecklist()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/algorithm/explain\",\"arguments\":{\"title\":\"Record creation\",\"flow\":\"Validate fields, format markdown, optionally save.\"}},\"id\":7}")

  Assert(FindString(response, "Algorithm Explanation: Record creation", 1) > 0, "Algorithm tool should include the title.")
  Assert(FindString(response, "Validate fields, format markdown", 1) > 0, "Algorithm tool should include the flow.")
  Assert(FindString(response, "Default Review Checklist", 1) > 0, "Algorithm tool should include the default review checklist.")
EndProcedureUnit

ProcedureUnit DecisionRecordCanBeSavedRelative()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s
  Protected savedPath.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/decision-record/create\",\"arguments\":{\"title\":\"Generated records stay local\",\"decision\":\"Use .local for generated MCP toolkit records.\",\"save\":true,\"fileName\":\"unit-decision-record\"}},\"id\":8}")

  savedPath = ".local/mcp-purebasic-toolkit/records/decisions/unit-decision-record.md"
  Assert(FindString(response, "Saved record: " + savedPath, 1) > 0, "Decision record should report a repository-relative saved path.")
  Assert(FindString(response, WorkstationAbsolutePathMarker(), 1) = 0, "Saved record response should avoid workstation-specific paths.")
  Assert(FileSize(ToolkitRoot() + savedPath) >= 0, "Decision record file should be written under .local.")
EndProcedureUnit

ProcedureUnit RecordSaveRejectsPathTraversal()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/brief/create\",\"arguments\":{\"save\":true,\"fileName\":\"../bad.md\"}},\"id\":9}")

  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "Record save should reject path traversal.")
EndProcedureUnit

ProcedureUnit GitPreflightReturnsReadOnlyStatus()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/git/preflight\",\"arguments\":{\"baseBranch\":\"main\"}},\"id\":10}")

  Assert(FindString(response, "# Git Preflight", 1) > 0, "Git preflight should return a markdown report.")
  Assert(FindString(response, "Mode: read-only inspection", 1) > 0, "Git preflight should be read-only.")
  Assert(FindString(response, "Recommended Checks", 1) > 0, "Git preflight should include route checks.")
  Assert(FindString(response, WorkstationAbsolutePathMarker(), 1) = 0, "Git preflight should avoid workstation-specific paths.")
EndProcedureUnit

ProcedureUnit GitCommitSummaryReturnsDraftOnly()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/git/commit-summary\",\"arguments\":{\"messageHint\":\"feat: add toolkit git helpers\",\"scope\":\"toolkit milestone\"}},\"id\":11}")

  Assert(FindString(response, "Git Commit Summary Draft", 1) > 0, "Commit summary should return a markdown draft.")
  Assert(FindString(response, "No `git add` or `git commit` was executed", 1) > 0, "Commit summary must not imply mutation.")
  Assert(FindString(response, "feat: add toolkit git helpers", 1) > 0, "Commit summary should include the message hint.")
EndProcedureUnit

ProcedureUnit GithubPrDraftReturnsSafeTemplate()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/github/pr-draft\",\"arguments\":{\"title\":\"Toolkit Git workflow\",\"summary\":\"Add read-only workflow helpers.\",\"tests\":\"./tools/check.sh\",\"risks\":\"Draft only.\"}},\"id\":12}")

  Assert(FindString(response, "GitHub PR Draft", 1) > 0, "PR draft should return a markdown draft.")
  Assert(FindString(response, "No branch was pushed and no PR was opened", 1) > 0, "PR draft must not imply GitHub mutation.")
  Assert(FindString(response, "Add read-only workflow helpers", 1) > 0, "PR draft should include the supplied summary.")
EndProcedureUnit

ProcedureUnit GithubReleaseDraftReturnsArtifactChecklist()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/github/release-draft\",\"arguments\":{\"version\":\"0.1.0-alpha.next\",\"highlights\":\"Toolkit workflow helpers\",\"verification\":\"./tools/check.sh\"}},\"id\":13}")

  Assert(FindString(response, "GitHub Release Draft", 1) > 0, "Release draft should return a markdown draft.")
  Assert(FindString(response, "No tag, release, or upload was created", 1) > 0, "Release draft must not imply GitHub mutation.")
  Assert(FindString(response, "Artifact Checklist", 1) > 0, "Release draft should include artifact checks.")
EndProcedureUnit
