EnableExplicit

XIncludeFile "../../src/jsonrpc/mcp_tools.pbi"

#MCP_Toolkit_ProjectInspectName$ = "purebasic/project/inspect"
#MCP_Toolkit_WorkflowBriefName$ = "purebasic/workflow/brief"
#MCP_Toolkit_HarnessChecklistName$ = "purebasic/harness/checklist"
#MCP_Toolkit_IncludeGraphName$ = "purebasic/include/graph"
#MCP_Toolkit_SymbolSearchName$ = "purebasic/symbol/search"
#MCP_Toolkit_ProcedureListName$ = "purebasic/procedure/list"
#MCP_Toolkit_PbpListTargetsName$ = "purebasic/pbp/list-targets"
#MCP_Toolkit_TestRunName$ = "purebasic/test/run"
#MCP_Toolkit_BuildRunName$ = "purebasic/build/run"
#MCP_Toolkit_CheckName$ = "purebasic/check"
#MCP_Toolkit_DocsBuildName$ = "purebasic/docs/build"
#MCP_Toolkit_BriefCreateName$ = "purebasic/brief/create"
#MCP_Toolkit_AlgorithmExplainName$ = "purebasic/algorithm/explain"
#MCP_Toolkit_DecisionRecordCreateName$ = "purebasic/decision-record/create"
#MCP_Toolkit_GitPreflightName$ = "purebasic/git/preflight"
#MCP_Toolkit_GitCommitSummaryName$ = "purebasic/git/commit-summary"
#MCP_Toolkit_GithubPrDraftName$ = "purebasic/github/pr-draft"
#MCP_Toolkit_GithubReleaseDraftName$ = "purebasic/github/release-draft"
#MCP_Toolkit_DocsCheckName$ = "purebasic/docs/check"
#MCP_Toolkit_DocsUpdateRouteName$ = "purebasic/docs/update-route"
#MCP_Toolkit_MilestoneCreateName$ = "purebasic/milestone/create"

#MCP_Toolkit_ProjectInspectSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"
#MCP_Toolkit_WorkflowBriefSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"
#MCP_Toolkit_HarnessChecklistSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"
#MCP_Toolkit_IncludeGraphSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"
#MCP_Toolkit_SymbolSearchSchema$ = ~"{\"type\":\"object\",\"properties\":{\"query\":{\"type\":\"string\"}},\"required\":[\"query\"],\"additionalProperties\":false}"
#MCP_Toolkit_ProcedureListSchema$ = ~"{\"type\":\"object\",\"properties\":{\"prefix\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_PbpListTargetsSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"
#MCP_Toolkit_HarnessExecutionSchema$ = ~"{\"type\":\"object\",\"properties\":{\"dryRun\":{\"type\":\"boolean\"},\"timeoutMs\":{\"type\":\"integer\",\"minimum\":1000,\"maximum\":900000},\"maxOutputBytes\":{\"type\":\"integer\",\"minimum\":1000,\"maximum\":60000}},\"additionalProperties\":false}"
#MCP_Toolkit_BriefCreateSchema$ = ~"{\"type\":\"object\",\"properties\":{\"goal\":{\"type\":\"string\"},\"context\":{\"type\":\"string\"},\"nonGoals\":{\"type\":\"string\"},\"deliverables\":{\"type\":\"string\"},\"risks\":{\"type\":\"string\"},\"tests\":{\"type\":\"string\"},\"docs\":{\"type\":\"string\"},\"save\":{\"type\":\"boolean\"},\"fileName\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_AlgorithmExplainSchema$ = ~"{\"type\":\"object\",\"properties\":{\"title\":{\"type\":\"string\"},\"inputs\":{\"type\":\"string\"},\"flow\":{\"type\":\"string\"},\"state\":{\"type\":\"string\"},\"errors\":{\"type\":\"string\"},\"humanDecisions\":{\"type\":\"string\"},\"save\":{\"type\":\"boolean\"},\"fileName\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_DecisionRecordCreateSchema$ = ~"{\"type\":\"object\",\"properties\":{\"title\":{\"type\":\"string\"},\"status\":{\"type\":\"string\"},\"context\":{\"type\":\"string\"},\"decision\":{\"type\":\"string\"},\"options\":{\"type\":\"string\"},\"consequences\":{\"type\":\"string\"},\"followUp\":{\"type\":\"string\"},\"save\":{\"type\":\"boolean\"},\"fileName\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_GitPreflightSchema$ = ~"{\"type\":\"object\",\"properties\":{\"baseBranch\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_GitCommitSummarySchema$ = ~"{\"type\":\"object\",\"properties\":{\"messageHint\":{\"type\":\"string\"},\"scope\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_GithubPrDraftSchema$ = ~"{\"type\":\"object\",\"properties\":{\"title\":{\"type\":\"string\"},\"summary\":{\"type\":\"string\"},\"tests\":{\"type\":\"string\"},\"risks\":{\"type\":\"string\"},\"baseBranch\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_GithubReleaseDraftSchema$ = ~"{\"type\":\"object\",\"properties\":{\"version\":{\"type\":\"string\"},\"highlights\":{\"type\":\"string\"},\"verification\":{\"type\":\"string\"},\"knownLimitations\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_DocsCheckSchema$ = ~"{\"type\":\"object\",\"properties\":{\"route\":{\"type\":\"string\"},\"track\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_DocsUpdateRouteSchema$ = ~"{\"type\":\"object\",\"properties\":{\"route\":{\"type\":\"string\"},\"track\":{\"type\":\"string\"},\"summary\":{\"type\":\"string\"},\"publicApi\":{\"type\":\"string\"},\"docs\":{\"type\":\"string\"},\"save\":{\"type\":\"boolean\"},\"fileName\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_MilestoneCreateSchema$ = ~"{\"type\":\"object\",\"properties\":{\"route\":{\"type\":\"string\"},\"track\":{\"type\":\"string\"},\"branch\":{\"type\":\"string\"},\"status\":{\"type\":\"string\"},\"purpose\":{\"type\":\"string\"},\"tools\":{\"type\":\"string\"},\"acceptance\":{\"type\":\"string\"},\"save\":{\"type\":\"boolean\"},\"fileName\":{\"type\":\"string\"}},\"additionalProperties\":false}"

#MCP_Toolkit_DefaultMaxScanResults = 80
#MCP_Toolkit_DefaultCommandTimeoutMs = 300000
#MCP_Toolkit_MinCommandTimeoutMs = 1000
#MCP_Toolkit_MaxCommandTimeoutMs = 900000
#MCP_Toolkit_DefaultCommandMaxOutputBytes = 20000
#MCP_Toolkit_MinCommandMaxOutputBytes = 1000
#MCP_Toolkit_MaxCommandMaxOutputBytes = 60000
#MCP_Toolkit_RecordFieldMaxChars = 4000
#MCP_Toolkit_RecordOutputMaxChars = 24000

Structure MCP_Toolkit_Config
  projectRoot.s
EndStructure

Structure MCP_Toolkit_ScanState
  count.i
  truncated.i
EndStructure

Structure MCP_Toolkit_HarnessOptions
  dryRun.i
  timeoutMs.i
  maxOutputBytes.i
EndStructure

Structure MCP_Toolkit_HarnessResult
  label.s
  relativeScript.s
  launched.i
  dryRun.i
  timedOut.i
  exitCode.i
  output.s
  truncated.i
EndStructure

Structure MCP_Toolkit_RecordSaveResult
  saved.i
  relativePath.s
  errorMessage.s
EndStructure

Global MCP_Toolkit_Config.MCP_Toolkit_Config

Declare MCP_Toolkit_SetConfig(projectRoot.s)
Declare.i MCP_Toolkit_Register(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)

Procedure.s MCP_Toolkit_DefaultProjectRoot()
  ProcedureReturn GetCurrentDirectory()
EndProcedure

Procedure.s MCP_Toolkit_Path(root.s, relativePath.s)
  If root = ""
    root = MCP_Toolkit_DefaultProjectRoot()
  EndIf

  If Right(root, 1) = "/" Or relativePath = ""
    ProcedureReturn root + relativePath
  EndIf

  ProcedureReturn root + "/" + relativePath
EndProcedure

Procedure.i MCP_Toolkit_FileExists(root.s, relativePath.s)
  ProcedureReturn Bool(FileSize(MCP_Toolkit_Path(root, relativePath)) >= 0)
EndProcedure

Procedure.i MCP_Toolkit_DirectoryExists(root.s, relativePath.s)
  ProcedureReturn Bool(FileSize(MCP_Toolkit_Path(root, relativePath)) = -2)
EndProcedure

Procedure.s MCP_Toolkit_NormalizeRelativePath(path.s)
  path = ReplaceString(path, "\", "/")

  While Left(path, 2) = "./"
    path = Mid(path, 3)
  Wend

  ProcedureReturn path
EndProcedure

Procedure.i MCP_Toolkit_HasSuffix(text.s, suffix.s)
  If Len(text) < Len(suffix)
    ProcedureReturn #False
  EndIf

  ProcedureReturn Bool(LCase(Right(text, Len(suffix))) = LCase(suffix))
EndProcedure

Procedure.i MCP_Toolkit_LineStartsWithKeyword(trimmed.s, keyword.s)
  Protected nextChar.s

  If Left(trimmed, Len(keyword)) <> keyword
    ProcedureReturn #False
  EndIf

  If Len(trimmed) = Len(keyword)
    ProcedureReturn #True
  EndIf

  nextChar = Mid(trimmed, Len(keyword) + 1, 1)
  ProcedureReturn Bool(nextChar = " " Or nextChar = Chr(9))
EndProcedure

Procedure.i MCP_Toolkit_IsSourceFile(name.s)
  ProcedureReturn Bool(MCP_Toolkit_HasSuffix(name, ".pb") Or MCP_Toolkit_HasSuffix(name, ".pbi"))
EndProcedure

Procedure.i MCP_Toolkit_IsIgnoredDirectory(name.s)
  Select name
    Case ".", "..", ".git", ".build", ".local", ".reports"
      ProcedureReturn #True
  EndSelect

  ProcedureReturn #False
EndProcedure

Procedure.s MCP_Toolkit_YesNo(value.i)
  If value
    ProcedureReturn "yes"
  EndIf

  ProcedureReturn "no"
EndProcedure

Procedure.i MCP_Toolkit_IsDigit(text.s, index.i)
  Protected code.i

  If index < 1 Or index > Len(text)
    ProcedureReturn #False
  EndIf

  code = Asc(Mid(text, index, 1))
  ProcedureReturn Bool(code >= '0' And code <= '9')
EndProcedure

Procedure.i MCP_Toolkit_IsNumberedExampleName(name.s)
  If Len(name) < 5
    ProcedureReturn #False
  EndIf

  If Mid(name, 4, 1) <> "-"
    ProcedureReturn #False
  EndIf

  ProcedureReturn Bool(MCP_Toolkit_IsDigit(name, 1) And MCP_Toolkit_IsDigit(name, 2) And MCP_Toolkit_IsDigit(name, 3))
EndProcedure

Procedure.i MCP_Toolkit_CountFiles(root.s, relativeDir.s, pattern.s)
  Protected dir.i
  Protected count.i

  dir = ExamineDirectory(#PB_Any, MCP_Toolkit_Path(root, relativeDir), pattern)
  If dir = 0
    ProcedureReturn 0
  EndIf

  While NextDirectoryEntry(dir)
    If DirectoryEntryType(dir) = #PB_DirectoryEntry_File
      count + 1
    EndIf
  Wend

  FinishDirectory(dir)
  ProcedureReturn count
EndProcedure

Procedure.i MCP_Toolkit_CountNumberedExamples(root.s)
  Protected dir.i
  Protected count.i
  Protected name.s

  dir = ExamineDirectory(#PB_Any, MCP_Toolkit_Path(root, "examples"), "*")
  If dir = 0
    ProcedureReturn 0
  EndIf

  While NextDirectoryEntry(dir)
    If DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory
      name = DirectoryEntryName(dir)
      If MCP_Toolkit_IsNumberedExampleName(name)
        count + 1
      EndIf
    EndIf
  Wend

  FinishDirectory(dir)
  ProcedureReturn count
EndProcedure

Procedure.i MCP_Toolkit_CountSkillFolders(root.s)
  Protected dir.i
  Protected count.i
  Protected name.s

  dir = ExamineDirectory(#PB_Any, MCP_Toolkit_Path(root, "MCP/mcp-purebasic-toolkit/skills"), "*")
  If dir = 0
    ProcedureReturn 0
  EndIf

  While NextDirectoryEntry(dir)
    If DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory
      name = DirectoryEntryName(dir)
      If name <> "." And name <> ".."
        If MCP_Toolkit_FileExists(root, "MCP/mcp-purebasic-toolkit/skills/" + name + "/SKILL.md")
          count + 1
        EndIf
      EndIf
    EndIf
  Wend

  FinishDirectory(dir)
  ProcedureReturn count
EndProcedure

Procedure.s MCP_Toolkit_GetQuotedValue(line.s)
  Protected firstQuote.i
  Protected secondQuote.i

  firstQuote = FindString(line, #DQUOTE$, 1)
  If firstQuote = 0
    ProcedureReturn ""
  EndIf

  secondQuote = FindString(line, #DQUOTE$, firstQuote + 1)
  If secondQuote = 0
    ProcedureReturn ""
  EndIf

  ProcedureReturn Mid(line, firstQuote + 1, secondQuote - firstQuote - 1)
EndProcedure

Procedure.s MCP_Toolkit_ReadArgumentString(argumentsValue, name.s, defaultValue.s = "")
  Protected value

  If argumentsValue = 0 Or JSONType(argumentsValue) <> #PB_JSON_Object
    ProcedureReturn defaultValue
  EndIf

  value = GetJSONMember(argumentsValue, name)
  If value = 0 Or JSONType(value) <> #PB_JSON_String
    ProcedureReturn defaultValue
  EndIf

  ProcedureReturn GetJSONString(value)
EndProcedure

Procedure.i MCP_Toolkit_ReadOptionalInteger(argumentsValue, name.s, defaultValue.i, *present.Integer)
  Protected value

  If *present <> 0
    *present\i = #False
  EndIf

  If argumentsValue = 0 Or JSONType(argumentsValue) <> #PB_JSON_Object
    ProcedureReturn defaultValue
  EndIf

  value = GetJSONMember(argumentsValue, name)
  If value = 0
    ProcedureReturn defaultValue
  EndIf

  If *present <> 0
    *present\i = #True
  EndIf

  If JSONType(value) <> #PB_JSON_Number
    ProcedureReturn defaultValue
  EndIf

  ProcedureReturn GetJSONInteger(value)
EndProcedure

Procedure.i MCP_Toolkit_ReadOptionalBoolean(argumentsValue, name.s, defaultValue.i, *present.Integer)
  Protected value

  If *present <> 0
    *present\i = #False
  EndIf

  If argumentsValue = 0 Or JSONType(argumentsValue) <> #PB_JSON_Object
    ProcedureReturn defaultValue
  EndIf

  value = GetJSONMember(argumentsValue, name)
  If value = 0
    ProcedureReturn defaultValue
  EndIf

  If *present <> 0
    *present\i = #True
  EndIf

  If JSONType(value) <> #PB_JSON_Boolean
    ProcedureReturn defaultValue
  EndIf

  ProcedureReturn GetJSONBoolean(value)
EndProcedure

Procedure MCP_Toolkit_SetInvalidParams(*result.JSONRPC_HandlerResult, message.s)
  *result\ok = #False
  *result\errorCode = #JSONRPC_Error_InvalidParams
  *result\errorMessage = message
EndProcedure

Procedure.i MCP_Toolkit_ReadHarnessOptions(argumentsValue, *options.MCP_Toolkit_HarnessOptions, *result.JSONRPC_HandlerResult)
  Protected present.Integer

  *options\dryRun = MCP_Toolkit_ReadOptionalBoolean(argumentsValue, "dryRun", #False, @present)
  If present\i And JSONType(GetJSONMember(argumentsValue, "dryRun")) <> #PB_JSON_Boolean
    MCP_Toolkit_SetInvalidParams(*result, "dryRun must be a boolean")
    ProcedureReturn #False
  EndIf

  *options\timeoutMs = MCP_Toolkit_ReadOptionalInteger(argumentsValue, "timeoutMs", #MCP_Toolkit_DefaultCommandTimeoutMs, @present)
  If present\i
    If JSONType(GetJSONMember(argumentsValue, "timeoutMs")) <> #PB_JSON_Number
      MCP_Toolkit_SetInvalidParams(*result, "timeoutMs must be an integer")
      ProcedureReturn #False
    EndIf

    If *options\timeoutMs < #MCP_Toolkit_MinCommandTimeoutMs Or *options\timeoutMs > #MCP_Toolkit_MaxCommandTimeoutMs
      MCP_Toolkit_SetInvalidParams(*result, "timeoutMs is outside the allowed range")
      ProcedureReturn #False
    EndIf
  EndIf

  *options\maxOutputBytes = MCP_Toolkit_ReadOptionalInteger(argumentsValue, "maxOutputBytes", #MCP_Toolkit_DefaultCommandMaxOutputBytes, @present)
  If present\i
    If JSONType(GetJSONMember(argumentsValue, "maxOutputBytes")) <> #PB_JSON_Number
      MCP_Toolkit_SetInvalidParams(*result, "maxOutputBytes must be an integer")
      ProcedureReturn #False
    EndIf

    If *options\maxOutputBytes < #MCP_Toolkit_MinCommandMaxOutputBytes Or *options\maxOutputBytes > #MCP_Toolkit_MaxCommandMaxOutputBytes
      MCP_Toolkit_SetInvalidParams(*result, "maxOutputBytes is outside the allowed range")
      ProcedureReturn #False
    EndIf
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure MCP_Toolkit_AppendCommandOutput(*commandResult.MCP_Toolkit_HarnessResult, chunk.s, maxOutputBytes.i)
  Protected remaining.i

  If chunk = "" Or *commandResult\truncated
    ProcedureReturn
  EndIf

  remaining = maxOutputBytes - Len(*commandResult\output)
  If remaining <= 0
    *commandResult\truncated = #True
    ProcedureReturn
  EndIf

  If Len(chunk) > remaining
    *commandResult\output + Left(chunk, remaining)
    *commandResult\truncated = #True
  Else
    *commandResult\output + chunk
  EndIf
EndProcedure

Procedure.s MCP_Toolkit_SanitizeCommandOutput(output.s, root.s)
  Protected normalizedRoot.s

  normalizedRoot = ReplaceString(root, "\", "/")
  If Right(normalizedRoot, 1) = "/"
    normalizedRoot = Left(normalizedRoot, Len(normalizedRoot) - 1)
  EndIf

  If normalizedRoot <> ""
    output = ReplaceString(output, normalizedRoot, ".")
  EndIf

  ProcedureReturn output
EndProcedure

Procedure MCP_Toolkit_DrainProgramOutput(program.i, root.s, maxOutputBytes.i, *commandResult.MCP_Toolkit_HarnessResult)
  Protected chunk.s

  While AvailableProgramOutput(program)
    chunk = ReadProgramString(program) + #LF$
    MCP_Toolkit_AppendCommandOutput(*commandResult, MCP_Toolkit_SanitizeCommandOutput(chunk, root), maxOutputBytes)
  Wend
EndProcedure

Procedure MCP_Toolkit_RunHarnessCommand(label.s, relativeScript.s, *options.MCP_Toolkit_HarnessOptions, *commandResult.MCP_Toolkit_HarnessResult)
  Protected root.s = MCP_Toolkit_Config\projectRoot
  Protected program.i
  Protected started.q

  If root = ""
    root = MCP_Toolkit_DefaultProjectRoot()
  EndIf

  *commandResult\label = label
  *commandResult\relativeScript = relativeScript
  *commandResult\dryRun = *options\dryRun
  *commandResult\exitCode = -1

  If FileSize(MCP_Toolkit_Path(root, relativeScript)) < 0
    *commandResult\output = "Harness script is missing: ./" + relativeScript + #LF$
    ProcedureReturn
  EndIf

  If *options\dryRun
    *commandResult\launched = #False
    *commandResult\exitCode = 0
    *commandResult\output = "Dry run only. No process was launched." + #LF$
    ProcedureReturn
  EndIf

  program = RunProgram("sh", ~"-c \"" + relativeScript + ~" 2>&1\"", root, #PB_Program_Open | #PB_Program_Read)
  If program = 0
    *commandResult\output = "Could not launch harness script: ./" + relativeScript + #LF$
    ProcedureReturn
  EndIf

  *commandResult\launched = #True
  started = ElapsedMilliseconds()

  While ProgramRunning(program)
    MCP_Toolkit_DrainProgramOutput(program, root, *options\maxOutputBytes, *commandResult)
    If ElapsedMilliseconds() - started > *options\timeoutMs
      *commandResult\timedOut = #True
      KillProgram(program)
      Break
    EndIf
    Delay(10)
  Wend

  MCP_Toolkit_DrainProgramOutput(program, root, *options\maxOutputBytes, *commandResult)
  *commandResult\exitCode = ProgramExitCode(program)
  CloseProgram(program)

  If *commandResult\timedOut
    MCP_Toolkit_AppendCommandOutput(*commandResult, "Command timed out after " + Str(*options\timeoutMs) + " ms." + #LF$, *options\maxOutputBytes)
  EndIf
EndProcedure

Procedure.i MCP_Toolkit_HarnessResultIsError(*commandResult.MCP_Toolkit_HarnessResult)
  If *commandResult\dryRun
    ProcedureReturn #False
  EndIf

  ProcedureReturn Bool(*commandResult\launched = #False Or *commandResult\timedOut Or *commandResult\exitCode <> 0)
EndProcedure

Procedure.s MCP_Toolkit_HarnessResultText(*commandResult.MCP_Toolkit_HarnessResult, *options.MCP_Toolkit_HarnessOptions)
  Protected text.s

  text = "PureBasic harness execution" + #LF$
  text + "Command: ./" + *commandResult\relativeScript + #LF$
  text + "Label: " + *commandResult\label + #LF$
  text + "Mode: "
  If *commandResult\dryRun
    text + "dry-run" + #LF$
  Else
    text + "execute" + #LF$
  EndIf
  text + "Timeout: " + Str(*options\timeoutMs) + " ms" + #LF$
  text + "Max output: " + Str(*options\maxOutputBytes) + " bytes" + #LF$
  text + "Exit status: " + Str(*commandResult\exitCode) + #LF$
  text + "Timed out: " + MCP_Toolkit_YesNo(*commandResult\timedOut) + #LF$
  text + "Output truncated: " + MCP_Toolkit_YesNo(*commandResult\truncated) + #LF$
  text + #LF$
  text + "Output:" + #LF$
  If *commandResult\output = ""
    text + "(no output)" + #LF$
  Else
    text + *commandResult\output
  EndIf

  ProcedureReturn text
EndProcedure

Procedure.i MCP_Toolkit_RunHarnessTool(argumentsValue, *result.JSONRPC_HandlerResult, label.s, relativeScript.s)
  Protected options.MCP_Toolkit_HarnessOptions
  Protected commandResult.MCP_Toolkit_HarnessResult

  If MCP_Toolkit_ReadHarnessOptions(argumentsValue, @options, *result) = #False
    ProcedureReturn #True
  EndIf

  MCP_Toolkit_RunHarnessCommand(label, relativeScript, @options, @commandResult)

  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_HarnessResultText(@commandResult, @options), MCP_Toolkit_HarnessResultIsError(@commandResult))
  ProcedureReturn #True
EndProcedure

Procedure.s MCP_Toolkit_LimitText(text.s, maxChars.i)
  If Len(text) <= maxChars
    ProcedureReturn text
  EndIf

  ProcedureReturn Left(text, maxChars) + #LF$ + "[truncated]" + #LF$
EndProcedure

Procedure.s MCP_Toolkit_RecordField(text.s)
  text = Trim(text)
  If text = ""
    ProcedureReturn "(not specified yet)"
  EndIf

  ProcedureReturn MCP_Toolkit_LimitText(text, #MCP_Toolkit_RecordFieldMaxChars)
EndProcedure

Procedure.s MCP_Toolkit_MarkdownSection(title.s, body.s)
  ProcedureReturn "## " + title + #LF$ + MCP_Toolkit_RecordField(body) + #LF$ + #LF$
EndProcedure

Procedure.i MCP_Toolkit_ReadSaveFlag(argumentsValue, *result.JSONRPC_HandlerResult)
  Protected present.Integer
  Protected save.i

  save = MCP_Toolkit_ReadOptionalBoolean(argumentsValue, "save", #False, @present)
  If present\i And JSONType(GetJSONMember(argumentsValue, "save")) <> #PB_JSON_Boolean
    MCP_Toolkit_SetInvalidParams(*result, "save must be a boolean")
    ProcedureReturn -1
  EndIf

  ProcedureReturn save
EndProcedure

Procedure.s MCP_Toolkit_RecordFileName(argumentsValue, prefix.s, *result.JSONRPC_HandlerResult)
  Protected fileName.s
  Protected normalized.s

  fileName = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "fileName"))
  If fileName = ""
    fileName = prefix + "-" + Str(Date()) + ".md"
  EndIf

  normalized = ReplaceString(fileName, "\", "/")
  If FindString(normalized, "/", 1) > 0 Or FindString(normalized, "..", 1) > 0 Or FindString(normalized, ":", 1) > 0
    MCP_Toolkit_SetInvalidParams(*result, "fileName must be a simple markdown filename")
    ProcedureReturn ""
  EndIf

  If MCP_Toolkit_HasSuffix(fileName, ".md") = #False
    fileName + ".md"
  EndIf

  If fileName = ".md"
    MCP_Toolkit_SetInvalidParams(*result, "fileName must not be empty")
    ProcedureReturn ""
  EndIf

  ProcedureReturn fileName
EndProcedure

Procedure.i MCP_Toolkit_EnsureRelativeDirectory(root.s, relativeDir.s)
  Protected index.i
  Protected part.s
  Protected current.s
  Protected count.i

  count = CountString(relativeDir, "/") + 1
  For index = 1 To count
    part = StringField(relativeDir, index, "/")
    If part = ""
      Continue
    EndIf

    If current = ""
      current = part
    Else
      current + "/" + part
    EndIf

    If FileSize(MCP_Toolkit_Path(root, current)) <> -2
      If CreateDirectory(MCP_Toolkit_Path(root, current)) = 0
        ProcedureReturn #False
      EndIf
    EndIf
  Next

  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_SaveRecord(category.s, fileName.s, content.s, *saveResult.MCP_Toolkit_RecordSaveResult)
  Protected root.s = MCP_Toolkit_Config\projectRoot
  Protected relativeDir.s
  Protected file.i

  If root = ""
    root = MCP_Toolkit_DefaultProjectRoot()
  EndIf

  relativeDir = ".local/mcp-purebasic-toolkit/records/" + category
  If MCP_Toolkit_EnsureRelativeDirectory(root, relativeDir) = #False
    *saveResult\errorMessage = "Could not create record directory: " + relativeDir
    ProcedureReturn #False
  EndIf

  *saveResult\relativePath = relativeDir + "/" + fileName
  file = CreateFile(#PB_Any, MCP_Toolkit_Path(root, *saveResult\relativePath), #PB_UTF8)
  If file = 0
    *saveResult\errorMessage = "Could not write record: " + *saveResult\relativePath
    ProcedureReturn #False
  EndIf

  WriteString(file, content, #PB_UTF8)
  CloseFile(file)
  *saveResult\saved = #True
  ProcedureReturn #True
EndProcedure

Procedure.s MCP_Toolkit_RecordWithSaveNote(content.s, *saveResult.MCP_Toolkit_RecordSaveResult)
  If *saveResult\saved
    ProcedureReturn content + #LF$ + "Saved record: " + *saveResult\relativePath + #LF$
  EndIf

  If *saveResult\errorMessage <> ""
    ProcedureReturn content + #LF$ + "Save failed: " + *saveResult\errorMessage + #LF$
  EndIf

  ProcedureReturn content
EndProcedure

Procedure.i MCP_Toolkit_SetRecordToolResult(argumentsValue, *result.JSONRPC_HandlerResult, category.s, prefix.s, content.s)
  Protected save.i
  Protected fileName.s
  Protected saveResult.MCP_Toolkit_RecordSaveResult
  Protected isError.i

  save = MCP_Toolkit_ReadSaveFlag(argumentsValue, *result)
  If save = -1
    ProcedureReturn #True
  EndIf

  content = MCP_Toolkit_LimitText(content, #MCP_Toolkit_RecordOutputMaxChars)
  If save
    fileName = MCP_Toolkit_RecordFileName(argumentsValue, prefix, *result)
    If fileName = ""
      ProcedureReturn #True
    EndIf

    If MCP_Toolkit_SaveRecord(category, fileName, content, @saveResult) = #False
      isError = #True
    EndIf
    content = MCP_Toolkit_RecordWithSaveNote(content, @saveResult)
  EndIf

  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(content, isError)
  ProcedureReturn #True
EndProcedure

Procedure.s MCP_Toolkit_BriefMarkdown(argumentsValue)
  Protected text.s

  text = "# PureBasic Implementation Brief" + #LF$ + #LF$
  text + MCP_Toolkit_MarkdownSection("Goal", MCP_Toolkit_ReadArgumentString(argumentsValue, "goal"))
  text + MCP_Toolkit_MarkdownSection("Context", MCP_Toolkit_ReadArgumentString(argumentsValue, "context"))
  text + MCP_Toolkit_MarkdownSection("Non-goals", MCP_Toolkit_ReadArgumentString(argumentsValue, "nonGoals"))
  text + MCP_Toolkit_MarkdownSection("Deliverables", MCP_Toolkit_ReadArgumentString(argumentsValue, "deliverables"))
  text + MCP_Toolkit_MarkdownSection("Risks", MCP_Toolkit_ReadArgumentString(argumentsValue, "risks"))
  text + MCP_Toolkit_MarkdownSection("Tests", MCP_Toolkit_ReadArgumentString(argumentsValue, "tests"))
  text + MCP_Toolkit_MarkdownSection("Documentation", MCP_Toolkit_ReadArgumentString(argumentsValue, "docs"))
  text + "## Questions To Clarify" + #LF$
  text + "- What PureBasic target type is affected: console, GUI app, shared library, or include-only library?" + #LF$
  text + "- What public API, MCP method, or tool schema changes?" + #LF$
  text + "- What malformed-input, path-safety, memory-lifecycle, and docs checks must pass?" + #LF$
  text + "- Which human decisions should be made before implementation continues?" + #LF$

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_AlgorithmMarkdown(argumentsValue)
  Protected title.s
  Protected text.s

  title = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "title", "Untitled PureBasic Flow"))
  text = "# Algorithm Explanation: " + title + #LF$ + #LF$
  text + MCP_Toolkit_MarkdownSection("Inputs", MCP_Toolkit_ReadArgumentString(argumentsValue, "inputs"))
  text + MCP_Toolkit_MarkdownSection("Flow", MCP_Toolkit_ReadArgumentString(argumentsValue, "flow"))
  text + MCP_Toolkit_MarkdownSection("State And Ownership", MCP_Toolkit_ReadArgumentString(argumentsValue, "state"))
  text + MCP_Toolkit_MarkdownSection("Errors And Edge Cases", MCP_Toolkit_ReadArgumentString(argumentsValue, "errors"))
  text + MCP_Toolkit_MarkdownSection("Human Decisions", MCP_Toolkit_ReadArgumentString(argumentsValue, "humanDecisions"))
  text + "## Default Review Checklist" + #LF$
  text + "- Validate all inputs before state changes." + #LF$
  text + "- Pair each `ParseJSON()` or `CreateJSON()` ownership path with `FreeJSON()`." + #LF$
  text + "- Keep MCP stdout protocol-only and route diagnostics to stderr." + #LF$
  text + "- Keep paths repository-relative in tracked files and generated descriptions." + #LF$
  text + "- Run focused tests first, then `./tools/check.sh`." + #LF$

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_DecisionRecordMarkdown(argumentsValue)
  Protected title.s
  Protected status.s
  Protected text.s

  title = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "title", "Untitled Decision"))
  status = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "status", "proposed"))

  text = "# Decision Record: " + title + #LF$ + #LF$
  text + "Status: " + status + #LF$ + #LF$
  text + MCP_Toolkit_MarkdownSection("Context", MCP_Toolkit_ReadArgumentString(argumentsValue, "context"))
  text + MCP_Toolkit_MarkdownSection("Decision", MCP_Toolkit_ReadArgumentString(argumentsValue, "decision"))
  text + MCP_Toolkit_MarkdownSection("Options Considered", MCP_Toolkit_ReadArgumentString(argumentsValue, "options"))
  text + MCP_Toolkit_MarkdownSection("Consequences", MCP_Toolkit_ReadArgumentString(argumentsValue, "consequences"))
  text + MCP_Toolkit_MarkdownSection("Follow-up", MCP_Toolkit_ReadArgumentString(argumentsValue, "followUp"))

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_RunGitReadOnly(arguments.s, maxOutputBytes.i = 6000)
  Protected root.s = MCP_Toolkit_Config\projectRoot
  Protected program.i
  Protected commandResult.MCP_Toolkit_HarnessResult
  Protected started.q

  If root = ""
    root = MCP_Toolkit_DefaultProjectRoot()
  EndIf

  program = RunProgram("sh", ~"-c \"git " + arguments + ~" 2>&1\"", root, #PB_Program_Open | #PB_Program_Read)
  If program = 0
    ProcedureReturn "Could not launch git " + arguments + #LF$
  EndIf

  started = ElapsedMilliseconds()
  While ProgramRunning(program)
    MCP_Toolkit_DrainProgramOutput(program, root, maxOutputBytes, @commandResult)
    If ElapsedMilliseconds() - started > 5000
      KillProgram(program)
      MCP_Toolkit_AppendCommandOutput(@commandResult, "Git command timed out." + #LF$, maxOutputBytes)
      Break
    EndIf
    Delay(10)
  Wend

  MCP_Toolkit_DrainProgramOutput(program, root, maxOutputBytes, @commandResult)
  CloseProgram(program)

  If commandResult\output = ""
    ProcedureReturn "(no output)" + #LF$
  EndIf

  ProcedureReturn commandResult\output
EndProcedure

Procedure.s MCP_Toolkit_CurrentGitBranch()
  ProcedureReturn Trim(MCP_Toolkit_RunGitReadOnly("branch --show-current", 1000))
EndProcedure

Procedure.s MCP_Toolkit_GitPreflightMarkdown(argumentsValue)
  Protected baseBranch.s
  Protected text.s

  baseBranch = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "baseBranch", "main"))
  If baseBranch = ""
    baseBranch = "main"
  EndIf

  text = "# Git Preflight" + #LF$ + #LF$
  text + "Mode: read-only inspection. No Git or GitHub mutation was executed." + #LF$ + #LF$
  text + "Base branch: `" + MCP_Toolkit_RecordField(baseBranch) + "`" + #LF$
  text + "Current branch: `" + MCP_Toolkit_RecordField(MCP_Toolkit_CurrentGitBranch()) + "`" + #LF$ + #LF$
  text + "## Status" + #LF$ + "```text" + #LF$ + MCP_Toolkit_RunGitReadOnly("status --short --branch") + "```" + #LF$ + #LF$
  text + "## Unstaged Diff Stat" + #LF$ + "```text" + #LF$ + MCP_Toolkit_RunGitReadOnly("diff --stat") + "```" + #LF$ + #LF$
  text + "## Staged Diff Stat" + #LF$ + "```text" + #LF$ + MCP_Toolkit_RunGitReadOnly("diff --cached --stat") + "```" + #LF$ + #LF$
  text + "## Recent Commits" + #LF$ + "```text" + #LF$ + MCP_Toolkit_RunGitReadOnly("log --oneline -5") + "```" + #LF$ + #LF$
  text + "## Recommended Checks" + #LF$
  text + "- Review dirty files and avoid staging unrelated local changes." + #LF$
  text + "- Run focused tests when useful." + #LF$
  text + "- Run `./tools/check.sh` before merge or push." + #LF$
  text + "- Use `git diff --check` before committing." + #LF$
  text + "- Prefer a no-fast-forward merge when preserving feature route history." + #LF$

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_GitCommitSummaryMarkdown(argumentsValue)
  Protected messageHint.s
  Protected scope.s
  Protected text.s

  messageHint = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "messageHint", "feat: describe the focused change"))
  scope = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "scope", "current route"))

  text = "# Git Commit Summary Draft" + #LF$ + #LF$
  text + "Mode: read-only draft. No `git add` or `git commit` was executed." + #LF$ + #LF$
  text + "Suggested message: `" + MCP_Toolkit_RecordField(messageHint) + "`" + #LF$
  text + "Scope: " + MCP_Toolkit_RecordField(scope) + #LF$ + #LF$
  text + "## Status" + #LF$ + "```text" + #LF$ + MCP_Toolkit_RunGitReadOnly("status --short --branch") + "```" + #LF$ + #LF$
  text + "## Staged Diff Stat" + #LF$ + "```text" + #LF$ + MCP_Toolkit_RunGitReadOnly("diff --cached --stat") + "```" + #LF$ + #LF$
  text + "## Unstaged Diff Stat" + #LF$ + "```text" + #LF$ + MCP_Toolkit_RunGitReadOnly("diff --stat") + "```" + #LF$ + #LF$
  text + "## Commit Checklist" + #LF$
  text + "- Stage only files belonging to this route." + #LF$
  text + "- Keep unrelated IDE metadata and generated files out of the commit." + #LF$
  text + "- Include verification evidence in the final human-facing summary." + #LF$

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_GithubPrDraftMarkdown(argumentsValue)
  Protected title.s
  Protected summary.s
  Protected tests.s
  Protected risks.s
  Protected baseBranch.s
  Protected text.s

  title = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "title", "PureBasic toolkit route update"))
  summary = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "summary"))
  tests = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "tests"))
  risks = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "risks"))
  baseBranch = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "baseBranch", "main"))
  If baseBranch = ""
    baseBranch = "main"
  EndIf

  text = "# GitHub PR Draft" + #LF$ + #LF$
  text + "Mode: draft text only. No branch was pushed and no PR was opened." + #LF$ + #LF$
  text + "Title: " + MCP_Toolkit_RecordField(title) + #LF$
  text + "Base branch: `" + MCP_Toolkit_RecordField(baseBranch) + "`" + #LF$
  text + "Current branch: `" + MCP_Toolkit_RecordField(MCP_Toolkit_CurrentGitBranch()) + "`" + #LF$ + #LF$
  text + "## Summary" + #LF$ + summary + #LF$ + #LF$
  text + "## Tests" + #LF$ + tests + #LF$ + #LF$
  text + "## Risks" + #LF$ + risks + #LF$ + #LF$
  text + "## Status Snapshot" + #LF$ + "```text" + #LF$ + MCP_Toolkit_RunGitReadOnly("status --short --branch") + "```" + #LF$ + #LF$
  text + "## Suggested Next Commands" + #LF$
  text + "- `./tools/check.sh`" + #LF$
  text + "- `git push origin " + MCP_Toolkit_RecordField(MCP_Toolkit_CurrentGitBranch()) + "`" + #LF$
  text + "- Open a draft PR only after reviewing staged files and verification evidence." + #LF$

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_GithubReleaseDraftMarkdown(argumentsValue)
  Protected version.s
  Protected highlights.s
  Protected verification.s
  Protected knownLimitations.s
  Protected text.s

  version = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "version", "unreleased"))
  highlights = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "highlights"))
  verification = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "verification", "./tools/check.sh"))
  knownLimitations = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "knownLimitations"))

  text = "# GitHub Release Draft" + #LF$ + #LF$
  text + "Mode: draft text only. No tag, release, or upload was created." + #LF$ + #LF$
  text + "Version: `" + MCP_Toolkit_RecordField(version) + "`" + #LF$ + #LF$
  text + "## Highlights" + #LF$ + highlights + #LF$ + #LF$
  text + "## Verification" + #LF$ + verification + #LF$ + #LF$
  text + "## Known Limitations" + #LF$ + knownLimitations + #LF$ + #LF$
  text + "## Artifact Checklist" + #LF$
  text + "- Run `./tools/check.sh` from a clean route state." + #LF$
  text + "- Confirm `.build/dist/` contains tarball, manifest, PDFs, and checksums." + #LF$
  text + "- Confirm `tools/verify-release-artifacts.sh` passes." + #LF$
  text + "- Confirm release notes and milestone documents match the package." + #LF$
  text + #LF$ + "## Recent Commits" + #LF$ + "```text" + #LF$ + MCP_Toolkit_RunGitReadOnly("log --oneline -10") + "```" + #LF$

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_ReadDocsTrack(argumentsValue, *result.JSONRPC_HandlerResult)
  Protected track.s

  track = LCase(Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "track", "toolkit")))
  If track = ""
    track = "toolkit"
  EndIf

  If track <> "toolkit" And track <> "core"
    MCP_Toolkit_SetInvalidParams(*result, "track must be either toolkit or core")
    ProcedureReturn ""
  EndIf

  ProcedureReturn track
EndProcedure

Procedure.s MCP_Toolkit_MilestoneFileForTrack(track.s)
  If track = "core"
    ProcedureReturn "docs/milestones.md"
  EndIf

  ProcedureReturn "MCP/mcp-purebasic-toolkit/docs/milestones.md"
EndProcedure

Procedure.i MCP_Toolkit_TextFileContains(root.s, relativePath.s, needle.s)
  Protected file.i
  Protected line.s
  Protected found.i

  If root = ""
    root = MCP_Toolkit_DefaultProjectRoot()
  EndIf

  If needle = ""
    ProcedureReturn #False
  EndIf

  file = ReadFile(#PB_Any, MCP_Toolkit_Path(root, relativePath), #PB_UTF8)
  If file = 0
    ProcedureReturn #False
  EndIf

  While Eof(file) = 0
    line = ReadString(file, #PB_UTF8)
    If FindString(line, needle, 1) > 0
      found = #True
      Break
    EndIf
  Wend

  CloseFile(file)
  ProcedureReturn found
EndProcedure

Procedure.s MCP_Toolkit_PresenceLine(root.s, relativePath.s, label.s = "")
  If label = ""
    label = relativePath
  EndIf

  If MCP_Toolkit_FileExists(root, relativePath)
    ProcedureReturn "- [x] " + label + " (`" + relativePath + "`)" + #LF$
  EndIf

  ProcedureReturn "- [ ] " + label + " (`" + relativePath + "`)" + #LF$
EndProcedure

Procedure.s MCP_Toolkit_DocsCheckMarkdown(argumentsValue, track.s)
  Protected root.s = MCP_Toolkit_Config\projectRoot
  Protected route.s
  Protected milestoneFile.s
  Protected text.s

  If root = ""
    root = MCP_Toolkit_DefaultProjectRoot()
  EndIf

  route = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "route", "current route"))
  If route = ""
    route = "current route"
  EndIf

  milestoneFile = MCP_Toolkit_MilestoneFileForTrack(track)

  text = "# Documentation Route Check" + #LF$ + #LF$
  text + "Mode: read-only documentation audit. No tracked file was modified." + #LF$ + #LF$
  text + "Route: `" + MCP_Toolkit_RecordField(route) + "`" + #LF$
  text + "Track: `" + track + "`" + #LF$
  text + "Milestone file: `" + milestoneFile + "`" + #LF$ + #LF$

  text + "## Source-Of-Truth Files" + #LF$
  text + MCP_Toolkit_PresenceLine(root, "AGENTS.md", "agent workflow")
  text + MCP_Toolkit_PresenceLine(root, "docs/guideline.md", "project guideline")
  text + MCP_Toolkit_PresenceLine(root, "docs/project-request.md", "project request")
  text + MCP_Toolkit_PresenceLine(root, "docs/index.md", "ReadTheDocs/Sphinx entry")
  text + MCP_Toolkit_PresenceLine(root, "docs/release-notes.md", "release notes")
  text + MCP_Toolkit_PresenceLine(root, milestoneFile, "milestone log")

  If track = "core"
    text + MCP_Toolkit_PresenceLine(root, "API/index.md", "API index")
    text + MCP_Toolkit_PresenceLine(root, "docs/api.md", "docs API bridge")
  Else
    text + MCP_Toolkit_PresenceLine(root, "MCP/mcp-purebasic-toolkit/README.md", "toolkit README")
    text + MCP_Toolkit_PresenceLine(root, "MCP/mcp-purebasic-toolkit/docs/architecture.md", "toolkit architecture")
    text + MCP_Toolkit_PresenceLine(root, "MCP/mcp-purebasic-toolkit/docs/workflow.md", "toolkit workflow")
    text + MCP_Toolkit_PresenceLine(root, "docs/mcp-purebasic-toolkit.md", "Sphinx toolkit bridge")
  EndIf

  text + #LF$ + "## Route Mentions" + #LF$
  text + "- Milestone mentions route: " + MCP_Toolkit_YesNo(MCP_Toolkit_TextFileContains(root, milestoneFile, route)) + #LF$
  text + "- Release notes mention route: " + MCP_Toolkit_YesNo(MCP_Toolkit_TextFileContains(root, "docs/release-notes.md", route)) + #LF$
  text + "- Sphinx toolkit bridge mentions route: " + MCP_Toolkit_YesNo(MCP_Toolkit_TextFileContains(root, "docs/mcp-purebasic-toolkit.md", route)) + #LF$

  text + #LF$ + "## Required Human Review" + #LF$
  text + "- Confirm route docs describe behavior, tests, risks, and limitations." + #LF$
  text + "- Confirm milestone status matches implementation reality." + #LF$
  text + "- Confirm major docs are present in `docs/index.md` when needed." + #LF$
  text + "- Confirm no workstation-specific absolute paths are introduced." + #LF$
  text + "- Confirm generated PDFs/packages are rebuilt, not assumed current." + #LF$

  text + #LF$ + "## Verification Commands" + #LF$
  text + "- `./tools/verify-docs.sh`" + #LF$
  text + "- `./tools/verify-paths.sh`" + #LF$
  text + "- `./tools/build-docs.sh`" + #LF$
  text + "- `./tools/check.sh`" + #LF$

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_DocsUpdateRouteMarkdown(argumentsValue, track.s)
  Protected route.s
  Protected summary.s
  Protected publicApi.s
  Protected docs.s
  Protected milestoneFile.s
  Protected text.s

  route = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "route", "current route"))
  If route = ""
    route = "current route"
  EndIf

  summary = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "summary"))
  publicApi = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "publicApi"))
  docs = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "docs"))
  milestoneFile = MCP_Toolkit_MilestoneFileForTrack(track)

  text = "# Documentation Route Update Draft" + #LF$ + #LF$
  text + "Mode: draft text only. No tracked documentation file was modified." + #LF$ + #LF$
  text + "Route: `" + MCP_Toolkit_RecordField(route) + "`" + #LF$
  text + "Track: `" + track + "`" + #LF$
  text + "Milestone file: `" + milestoneFile + "`" + #LF$ + #LF$
  text + "## Summary" + #LF$ + summary + #LF$ + #LF$
  text + "## Public API Impact" + #LF$ + publicApi + #LF$ + #LF$
  text + "## Requested Docs Notes" + #LF$ + docs + #LF$ + #LF$
  text + "## Default Files To Review" + #LF$

  If track = "core"
    text + "- `API/index.md` and a route-specific API page when public API changes." + #LF$
    text + "- `docs/api.md` for the API bridge." + #LF$
    text + "- `docs/milestones.md` for numbered core milestones." + #LF$
  Else
    text + "- `MCP/mcp-purebasic-toolkit/docs/milestones.md` for toolkit milestones." + #LF$
    text + "- `MCP/mcp-purebasic-toolkit/README.md` for tool inventory and usage." + #LF$
    text + "- `MCP/mcp-purebasic-toolkit/docs/architecture.md` and `workflow.md` for design and process." + #LF$
    text + "- `docs/mcp-purebasic-toolkit.md` for the Sphinx bridge." + #LF$
  EndIf

  text + "- `docs/release-notes.md` for route-visible changes." + #LF$
  text + "- `docs/index.md` when adding or moving major docs." + #LF$
  text + "- `AGENTS.md` when the agent workflow contract changes." + #LF$
  text + #LF$ + "## Completion Checklist" + #LF$
  text + "- Docs and milestones agree with code, tests, examples, and harness behavior." + #LF$
  text + "- Path references are repository-relative in tracked source and docs." + #LF$
  text + "- `./tools/verify-docs.sh` and `./tools/build-docs.sh` pass before final check." + #LF$
  text + "- `./tools/check.sh` passes before merge or push." + #LF$

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_MilestoneCreateMarkdown(argumentsValue, track.s)
  Protected route.s
  Protected branch.s
  Protected status.s
  Protected purpose.s
  Protected tools.s
  Protected acceptance.s
  Protected milestoneFile.s
  Protected text.s

  route = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "route", "untitled-route"))
  If route = ""
    route = "untitled-route"
  EndIf

  branch = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "branch", "feature/" + route))
  status = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "status", "planned"))
  purpose = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "purpose"))
  tools = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "tools"))
  acceptance = MCP_Toolkit_RecordField(MCP_Toolkit_ReadArgumentString(argumentsValue, "acceptance"))
  milestoneFile = MCP_Toolkit_MilestoneFileForTrack(track)

  text = "# Milestone Draft: " + route + #LF$ + #LF$
  text + "Mode: draft text only. No tracked milestone file was modified." + #LF$ + #LF$
  text + "Track: `" + track + "`" + #LF$
  text + "Milestone file: `" + milestoneFile + "`" + #LF$ + #LF$
  text + "## " + route + #LF$ + #LF$
  text + "Branch: `" + MCP_Toolkit_RecordField(branch) + "`" + #LF$ + #LF$
  text + "Status: " + MCP_Toolkit_RecordField(status) + #LF$ + #LF$
  text + "Purpose:" + #LF$ + #LF$
  text + purpose + #LF$ + #LF$
  text + "Tools or surface:" + #LF$ + #LF$
  text + tools + #LF$ + #LF$
  text + "Acceptance criteria:" + #LF$ + #LF$
  text + acceptance + #LF$ + #LF$
  text + "- Route has focused PureUnit coverage or documented docs-only verification." + #LF$
  text + "- Probe or smoke input covers any MCP-facing behavior." + #LF$
  text + "- Docs, release notes, and milestone file are updated in the same route." + #LF$
  text + "- `./tools/verify-docs.sh`, `./tools/verify-paths.sh`, and `./tools/check.sh` pass." + #LF$
  text + #LF$ + "Copy this draft into `" + milestoneFile + "` only after human review." + #LF$

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_ScanIncludesInFile(root.s, relativePath.s, *state.MCP_Toolkit_ScanState)
  Protected file.i
  Protected line.s
  Protected trimmed.s
  Protected includeTarget.s
  Protected text.s

  If *state\truncated
    ProcedureReturn ""
  EndIf

  file = ReadFile(#PB_Any, MCP_Toolkit_Path(root, relativePath), #PB_UTF8)
  If file = 0
    ProcedureReturn ""
  EndIf

  While Eof(file) = 0
    line = ReadString(file, #PB_UTF8)
    trimmed = Trim(line)

    If MCP_Toolkit_LineStartsWithKeyword(trimmed, "XIncludeFile") Or MCP_Toolkit_LineStartsWithKeyword(trimmed, "IncludeFile")
      includeTarget = MCP_Toolkit_GetQuotedValue(trimmed)
      If includeTarget <> ""
        text + relativePath + " -> " + includeTarget + #LF$
        *state\count + 1
        If *state\count >= #MCP_Toolkit_DefaultMaxScanResults
          *state\truncated = #True
          Break
        EndIf
      EndIf
    EndIf
  Wend

  CloseFile(file)
  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_IncludeGraphDirectory(root.s, relativeDir.s, *state.MCP_Toolkit_ScanState)
  Protected dir.i
  Protected name.s
  Protected childRelative.s
  Protected text.s

  dir = ExamineDirectory(#PB_Any, MCP_Toolkit_Path(root, relativeDir), "*")
  If dir = 0
    ProcedureReturn ""
  EndIf

  While NextDirectoryEntry(dir)
    name = DirectoryEntryName(dir)
    childRelative = MCP_Toolkit_NormalizeRelativePath(relativeDir + "/" + name)

    If DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory
      If MCP_Toolkit_IsIgnoredDirectory(name) = #False
        text + MCP_Toolkit_IncludeGraphDirectory(root, childRelative, *state)
      EndIf
    ElseIf MCP_Toolkit_IsSourceFile(name)
      text + MCP_Toolkit_ScanIncludesInFile(root, childRelative, *state)
    EndIf

    If *state\truncated
      Break
    EndIf
  Wend

  FinishDirectory(dir)
  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_IncludeGraphText()
  Protected root.s = MCP_Toolkit_Config\projectRoot
  Protected state.MCP_Toolkit_ScanState
  Protected text.s

  text = "PureBasic include graph" + #LF$
  text + MCP_Toolkit_IncludeGraphDirectory(root, "src/jsonrpc", @state)
  text + MCP_Toolkit_IncludeGraphDirectory(root, "MCP/mcp-purebasic-toolkit", @state)

  If state\count = 0
    text + "(no include edges found)" + #LF$
  EndIf

  If state\truncated
    text + "[truncated after " + Str(state\count) + " include edges]" + #LF$
  EndIf

  ProcedureReturn text
EndProcedure

Procedure.i MCP_Toolkit_LineMatchesProcedureList(trimmed.s)
  ProcedureReturn Bool(Left(trimmed, 9) = "Procedure" Or Left(trimmed, 7) = "Declare" Or Left(trimmed, 9) = "Prototype" Or Left(trimmed, 9) = "Structure")
EndProcedure

Procedure.s MCP_Toolkit_SearchFile(root.s, relativePath.s, query.s, *state.MCP_Toolkit_ScanState)
  Protected file.i
  Protected line.s
  Protected lineNumber.i
  Protected text.s
  Protected loweredQuery.s = LCase(query)

  If *state\truncated
    ProcedureReturn ""
  EndIf

  file = ReadFile(#PB_Any, MCP_Toolkit_Path(root, relativePath), #PB_UTF8)
  If file = 0
    ProcedureReturn ""
  EndIf

  While Eof(file) = 0
    lineNumber + 1
    line = ReadString(file, #PB_UTF8)

    If FindString(LCase(line), loweredQuery, 1) > 0
      text + relativePath + ":" + Str(lineNumber) + ": " + Trim(line) + #LF$
      *state\count + 1
      If *state\count >= #MCP_Toolkit_DefaultMaxScanResults
        *state\truncated = #True
        Break
      EndIf
    EndIf
  Wend

  CloseFile(file)
  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_SearchDirectory(root.s, relativeDir.s, query.s, *state.MCP_Toolkit_ScanState)
  Protected dir.i
  Protected name.s
  Protected childRelative.s
  Protected text.s

  dir = ExamineDirectory(#PB_Any, MCP_Toolkit_Path(root, relativeDir), "*")
  If dir = 0
    ProcedureReturn ""
  EndIf

  While NextDirectoryEntry(dir)
    name = DirectoryEntryName(dir)
    childRelative = MCP_Toolkit_NormalizeRelativePath(relativeDir + "/" + name)

    If DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory
      If MCP_Toolkit_IsIgnoredDirectory(name) = #False
        text + MCP_Toolkit_SearchDirectory(root, childRelative, query, *state)
      EndIf
    ElseIf MCP_Toolkit_IsSourceFile(name) Or MCP_Toolkit_HasSuffix(name, ".pbp") Or MCP_Toolkit_HasSuffix(name, ".md") Or MCP_Toolkit_HasSuffix(name, ".sh")
      text + MCP_Toolkit_SearchFile(root, childRelative, query, *state)
    EndIf

    If *state\truncated
      Break
    EndIf
  Wend

  FinishDirectory(dir)
  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_SymbolSearchText(query.s)
  Protected root.s = MCP_Toolkit_Config\projectRoot
  Protected state.MCP_Toolkit_ScanState
  Protected text.s

  text = "PureBasic symbol search" + #LF$
  text + "Query: " + query + #LF$
  text + MCP_Toolkit_SearchDirectory(root, "src/jsonrpc", query, @state)
  text + MCP_Toolkit_SearchDirectory(root, "examples", query, @state)
  text + MCP_Toolkit_SearchDirectory(root, "MCP", query, @state)
  text + MCP_Toolkit_SearchDirectory(root, "tools", query, @state)

  If state\count = 0
    text + "(no matches found)" + #LF$
  EndIf

  If state\truncated
    text + "[truncated after " + Str(state\count) + " matches]" + #LF$
  EndIf

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_ProcedureListFile(root.s, relativePath.s, prefix.s, *state.MCP_Toolkit_ScanState)
  Protected file.i
  Protected line.s
  Protected trimmed.s
  Protected lineNumber.i
  Protected text.s

  If *state\truncated
    ProcedureReturn ""
  EndIf

  file = ReadFile(#PB_Any, MCP_Toolkit_Path(root, relativePath), #PB_UTF8)
  If file = 0
    ProcedureReturn ""
  EndIf

  While Eof(file) = 0
    lineNumber + 1
    line = ReadString(file, #PB_UTF8)
    trimmed = Trim(line)

    If MCP_Toolkit_LineMatchesProcedureList(trimmed)
      If prefix = "" Or FindString(trimmed, prefix, 1) > 0
        text + relativePath + ":" + Str(lineNumber) + ": " + trimmed + #LF$
        *state\count + 1
        If *state\count >= #MCP_Toolkit_DefaultMaxScanResults
          *state\truncated = #True
          Break
        EndIf
      EndIf
    EndIf
  Wend

  CloseFile(file)
  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_ProcedureListDirectory(root.s, relativeDir.s, prefix.s, *state.MCP_Toolkit_ScanState)
  Protected dir.i
  Protected name.s
  Protected childRelative.s
  Protected text.s

  dir = ExamineDirectory(#PB_Any, MCP_Toolkit_Path(root, relativeDir), "*")
  If dir = 0
    ProcedureReturn ""
  EndIf

  While NextDirectoryEntry(dir)
    name = DirectoryEntryName(dir)
    childRelative = MCP_Toolkit_NormalizeRelativePath(relativeDir + "/" + name)

    If DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory
      If MCP_Toolkit_IsIgnoredDirectory(name) = #False
        text + MCP_Toolkit_ProcedureListDirectory(root, childRelative, prefix, *state)
      EndIf
    ElseIf MCP_Toolkit_IsSourceFile(name)
      text + MCP_Toolkit_ProcedureListFile(root, childRelative, prefix, *state)
    EndIf

    If *state\truncated
      Break
    EndIf
  Wend

  FinishDirectory(dir)
  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_ProcedureListText(prefix.s)
  Protected root.s = MCP_Toolkit_Config\projectRoot
  Protected state.MCP_Toolkit_ScanState
  Protected text.s

  text = "PureBasic procedure and symbol list" + #LF$
  If prefix <> ""
    text + "Prefix/filter: " + prefix + #LF$
  EndIf

  text + MCP_Toolkit_ProcedureListDirectory(root, "src/jsonrpc", prefix, @state)
  text + MCP_Toolkit_ProcedureListDirectory(root, "MCP/mcp-purebasic-toolkit", prefix, @state)

  If state\count = 0
    text + "(no procedure symbols found)" + #LF$
  EndIf

  If state\truncated
    text + "[truncated after " + Str(state\count) + " symbols]" + #LF$
  EndIf

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_PbpTargetsFile(root.s, relativePath.s, *state.MCP_Toolkit_ScanState)
  Protected file.i
  Protected line.s
  Protected trimmed.s
  Protected targetName.s
  Protected inputFile.s
  Protected outputFile.s
  Protected format.s
  Protected text.s

  If *state\truncated
    ProcedureReturn ""
  EndIf

  file = ReadFile(#PB_Any, MCP_Toolkit_Path(root, relativePath), #PB_UTF8)
  If file = 0
    ProcedureReturn ""
  EndIf

  While Eof(file) = 0
    line = ReadString(file, #PB_UTF8)
    trimmed = Trim(line)

    If FindString(trimmed, "<target ", 1) > 0
      targetName = MCP_Toolkit_GetQuotedValue(trimmed)
      inputFile = ""
      outputFile = ""
      format = ""
    ElseIf FindString(trimmed, "<inputfile ", 1) > 0
      inputFile = MCP_Toolkit_GetQuotedValue(trimmed)
    ElseIf FindString(trimmed, "<outputfile ", 1) > 0
      outputFile = MCP_Toolkit_GetQuotedValue(trimmed)
    ElseIf FindString(trimmed, "<format ", 1) > 0
      format = MCP_Toolkit_GetQuotedValue(trimmed)
    ElseIf FindString(trimmed, "</target>", 1) > 0 And targetName <> ""
      text + relativePath + " :: " + targetName + " [" + format + "] input=" + inputFile + " output=" + outputFile + #LF$
      *state\count + 1
      targetName = ""
      If *state\count >= #MCP_Toolkit_DefaultMaxScanResults
        *state\truncated = #True
        Break
      EndIf
    EndIf
  Wend

  CloseFile(file)
  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_PbpTargetsDirectory(root.s, relativeDir.s, *state.MCP_Toolkit_ScanState)
  Protected dir.i
  Protected name.s
  Protected childRelative.s
  Protected text.s

  dir = ExamineDirectory(#PB_Any, MCP_Toolkit_Path(root, relativeDir), "*")
  If dir = 0
    ProcedureReturn ""
  EndIf

  While NextDirectoryEntry(dir)
    name = DirectoryEntryName(dir)
    childRelative = MCP_Toolkit_NormalizeRelativePath(relativeDir + "/" + name)

    If DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory
      If MCP_Toolkit_IsIgnoredDirectory(name) = #False
        text + MCP_Toolkit_PbpTargetsDirectory(root, childRelative, *state)
      EndIf
    ElseIf MCP_Toolkit_HasSuffix(name, ".pbp")
      text + MCP_Toolkit_PbpTargetsFile(root, childRelative, *state)
    EndIf

    If *state\truncated
      Break
    EndIf
  Wend

  FinishDirectory(dir)
  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_PbpTargetsText()
  Protected root.s = MCP_Toolkit_Config\projectRoot
  Protected state.MCP_Toolkit_ScanState
  Protected text.s

  text = "PureBasic .pbp targets" + #LF$
  text + MCP_Toolkit_PbpTargetsFile(root, "PureBasic-JSON-RPC.pbp", @state)
  text + MCP_Toolkit_PbpTargetsDirectory(root, "examples", @state)
  text + MCP_Toolkit_PbpTargetsDirectory(root, "MCP", @state)

  If state\count = 0
    text + "(no .pbp targets found)" + #LF$
  EndIf

  If state\truncated
    text + "[truncated after " + Str(state\count) + " targets]" + #LF$
  EndIf

  ProcedureReturn text
EndProcedure

Procedure MCP_Toolkit_SetConfig(projectRoot.s)
  MCP_Toolkit_Config\projectRoot = projectRoot
  If MCP_Toolkit_Config\projectRoot = ""
    MCP_Toolkit_Config\projectRoot = MCP_Toolkit_DefaultProjectRoot()
  EndIf
EndProcedure

Procedure.s MCP_Toolkit_ProjectInspectText()
  Protected root.s = MCP_Toolkit_Config\projectRoot
  Protected text.s

  If root = ""
    root = MCP_Toolkit_DefaultProjectRoot()
  EndIf

  text = "PureBasic project inspection" + #LF$
  text + "Project root: configured working directory (runtime path omitted)" + #LF$
  text + "Path style: repository-relative paths in tracked files" + #LF$
  text + "Library source: " + MCP_Toolkit_YesNo(MCP_Toolkit_FileExists(root, "src/jsonrpc/jsonrpc.pbi")) + #LF$
  text + "Root .pbp: " + MCP_Toolkit_YesNo(MCP_Toolkit_FileExists(root, "PureBasic-JSON-RPC.pbp")) + #LF$
  text + "Harness check: " + MCP_Toolkit_YesNo(MCP_Toolkit_FileExists(root, "tools/check.sh")) + #LF$
  text + "Docs verifier: " + MCP_Toolkit_YesNo(MCP_Toolkit_FileExists(root, "tools/verify-docs.sh")) + #LF$
  text + "Path verifier: " + MCP_Toolkit_YesNo(MCP_Toolkit_FileExists(root, "tools/verify-paths.sh")) + #LF$
  text + "ReadTheDocs entry: " + MCP_Toolkit_YesNo(MCP_Toolkit_FileExists(root, "docs/index.md")) + #LF$
  text + "Toolkit project: " + MCP_Toolkit_YesNo(MCP_Toolkit_DirectoryExists(root, "MCP/mcp-purebasic-toolkit")) + #LF$
  text + "Toolkit milestones: " + MCP_Toolkit_YesNo(MCP_Toolkit_FileExists(root, "MCP/mcp-purebasic-toolkit/docs/milestones.md")) + #LF$
  text + "JSON-RPC include files: " + Str(MCP_Toolkit_CountFiles(root, "src/jsonrpc", "*.pbi")) + #LF$
  text + "PureUnit test files: " + Str(MCP_Toolkit_CountFiles(root, "tests/unit", "*.pb")) + #LF$
  text + "Numbered examples: " + Str(MCP_Toolkit_CountNumberedExamples(root)) + #LF$
  text + "Toolkit skills: " + Str(MCP_Toolkit_CountSkillFolders(root)) + #LF$
  text + #LF$
  text + "Reviewer path:" + #LF$
  text + "1. Inspect src/jsonrpc/README.md and src/jsonrpc/jsonrpc.pbi." + #LF$
  text + "2. Follow examples/000-* through examples/032-* for the core route." + #LF$
  text + "3. Use MCP/mcp-purebasic-toolkit/docs/milestones.md for toolkit work, separate from library milestones." + #LF$
  text + "4. Run ./tools/check.sh before treating a route as complete."

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_WorkflowBriefText()
  Protected text.s

  text = "PureBasic pair-development workflow" + #LF$
  text + #LF$
  text + "1. Interview and align" + #LF$
  text + "- Grill the human until goal, non-goals, target type, API surface, examples, tests, docs, and risks are clear." + #LF$
  text + "- Summarize the shared brief before code changes." + #LF$
  text + "- Use purebasic/brief/create to capture the shared brief as Markdown when useful." + #LF$
  text + #LF$
  text + "2. Explain algorithm and flow" + #LF$
  text + "- Describe input validation, state changes, JSON ownership, error behavior, output shape, cleanup, and diagnostics." + #LF$
  text + "- Ask for human decisions when semantics or policy are not mechanical." + #LF$
  text + "- Use purebasic/algorithm/explain and purebasic/decision-record/create to make flow and decisions reviewable." + #LF$
  text + #LF$
  text + "3. Implement through harness" + #LF$
  text + "- Create a focused branch." + #LF$
  text + "- Prefer tests and scenario probes close to the changed behavior." + #LF$
  text + "- Update API docs, route docs, ReadTheDocs navigation, and release notes." + #LF$
  text + #LF$
  text + "4. Verify, then Git/GitHub" + #LF$
  text + "- Run focused tests first when useful." + #LF$
  text + "- Run ./tools/check.sh before merge or push." + #LF$
  text + "- Use purebasic/git/preflight and purebasic/git/commit-summary before committing." + #LF$
  text + "- Use purebasic/github/pr-draft or purebasic/github/release-draft as draft text only." + #LF$
  text + "- Use purebasic/docs/check before final verification to catch route-doc gaps." + #LF$
  text + "- Use no-fast-forward merges for route history when appropriate." + #LF$
  text + #LF$
  text + "Default lesson learned rules:" + #LF$
  text + "- Do not commit workstation-specific absolute paths." + #LF$
  text + "- Treat .pbp files as target metadata source of truth." + #LF$
  text + "- Keep MCP stdout protocol-only and diagnostics on stderr." + #LF$
  text + "- Pair every ParseJSON/CreateJSON ownership path with FreeJSON." + #LF$
  text + "- Do not assume docs, package, or tests are current; verify them."

  ProcedureReturn text
EndProcedure

Procedure.s MCP_Toolkit_HarnessChecklistText()
  Protected text.s

  text = "PureBasic toolkit harness checklist" + #LF$
  text + #LF$
  text + "Local commands:" + #LF$
  text + "- ./tools/discover-purebasic.sh" + #LF$
  text + "- ./tools/verify-projects.sh" + #LF$
  text + "- ./tools/verify-docs.sh" + #LF$
  text + "- ./tools/verify-paths.sh" + #LF$
  text + "- ./tools/test.sh" + #LF$
  text + "- ./tools/build.sh" + #LF$
  text + "- ./tools/build-docs.sh" + #LF$
  text + "- ./tools/package-alpha.sh" + #LF$
  text + "- ./tools/verify-release-artifacts.sh" + #LF$
  text + "- ./tools/check.sh" + #LF$
  text + #LF$
  text + "MCP execution tools:" + #LF$
  text + "- purebasic/test/run -> ./tools/test.sh" + #LF$
  text + "- purebasic/build/run -> ./tools/build.sh" + #LF$
  text + "- purebasic/check -> ./tools/check.sh" + #LF$
  text + "- purebasic/docs/build -> ./tools/build-docs.sh" + #LF$
  text + "- purebasic/docs/check -> read-only route documentation audit" + #LF$
  text + "- purebasic/docs/update-route -> route documentation update draft" + #LF$
  text + "- purebasic/milestone/create -> milestone entry draft" + #LF$
  text + "- use dryRun first when a human wants to review a long-running command" + #LF$
  text + "- output is bounded and the configured project root is reported as ." + #LF$
  text + #LF$
  text + "Git local workflow:" + #LF$
  text + "- git status --short --branch" + #LF$
  text + "- git checkout -b feature/or-docs-slug" + #LF$
  text + "- implement, test, document" + #LF$
  text + "- git diff --check" + #LF$
  text + "- git commit with an intent-focused message" + #LF$
  text + "- git checkout main && git merge --no-ff branch" + #LF$
  text + "- MCP helpers: purebasic/git/preflight and purebasic/git/commit-summary" + #LF$
  text + #LF$
  text + "GitHub workflow:" + #LF$
  text + "- git pull --ff-only on main before a collaborative branch" + #LF$
  text + "- push the feature branch when review or CI is needed" + #LF$
  text + "- open a PR with verification evidence" + #LF$
  text + "- check CI before merge" + #LF$
  text + "- delete merged branches" + #LF$
  text + "- MCP helpers: purebasic/github/pr-draft and purebasic/github/release-draft"

  ProcedureReturn text
EndProcedure

Procedure.i MCP_Toolkit_ProjectInspectHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_ProjectInspectText())
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_WorkflowBriefHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_WorkflowBriefText())
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_HarnessChecklistHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_HarnessChecklistText())
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_IncludeGraphHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_IncludeGraphText())
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_SymbolSearchHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected query.s

  query = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "query"))
  If query = ""
    *result\ok = #False
    *result\errorCode = #JSONRPC_Error_InvalidParams
    *result\errorMessage = "purebasic/symbol/search requires query"
    ProcedureReturn #True
  EndIf

  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_SymbolSearchText(query))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_ProcedureListHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected prefix.s

  prefix = Trim(MCP_Toolkit_ReadArgumentString(argumentsValue, "prefix"))
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_ProcedureListText(prefix))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_PbpListTargetsHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_PbpTargetsText())
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_TestRunHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  ProcedureReturn MCP_Toolkit_RunHarnessTool(argumentsValue, *result, "PureUnit test suite", "tools/test.sh")
EndProcedure

Procedure.i MCP_Toolkit_BuildRunHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  ProcedureReturn MCP_Toolkit_RunHarnessTool(argumentsValue, *result, "PureBasic project build", "tools/build.sh")
EndProcedure

Procedure.i MCP_Toolkit_CheckHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  ProcedureReturn MCP_Toolkit_RunHarnessTool(argumentsValue, *result, "Full repository check", "tools/check.sh")
EndProcedure

Procedure.i MCP_Toolkit_DocsBuildHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  ProcedureReturn MCP_Toolkit_RunHarnessTool(argumentsValue, *result, "ReadTheDocs/Sphinx and PDF docs build", "tools/build-docs.sh")
EndProcedure

Procedure.i MCP_Toolkit_BriefCreateHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  ProcedureReturn MCP_Toolkit_SetRecordToolResult(argumentsValue, *result, "briefs", "brief", MCP_Toolkit_BriefMarkdown(argumentsValue))
EndProcedure

Procedure.i MCP_Toolkit_AlgorithmExplainHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  ProcedureReturn MCP_Toolkit_SetRecordToolResult(argumentsValue, *result, "algorithms", "algorithm", MCP_Toolkit_AlgorithmMarkdown(argumentsValue))
EndProcedure

Procedure.i MCP_Toolkit_DecisionRecordCreateHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  ProcedureReturn MCP_Toolkit_SetRecordToolResult(argumentsValue, *result, "decisions", "decision", MCP_Toolkit_DecisionRecordMarkdown(argumentsValue))
EndProcedure

Procedure.i MCP_Toolkit_GitPreflightHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_GitPreflightMarkdown(argumentsValue))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_GitCommitSummaryHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_GitCommitSummaryMarkdown(argumentsValue))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_GithubPrDraftHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_GithubPrDraftMarkdown(argumentsValue))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_GithubReleaseDraftHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_GithubReleaseDraftMarkdown(argumentsValue))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_DocsCheckHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected track.s

  track = MCP_Toolkit_ReadDocsTrack(argumentsValue, *result)
  If track = ""
    ProcedureReturn #True
  EndIf

  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_Toolkit_DocsCheckMarkdown(argumentsValue, track))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_Toolkit_DocsUpdateRouteHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected track.s

  track = MCP_Toolkit_ReadDocsTrack(argumentsValue, *result)
  If track = ""
    ProcedureReturn #True
  EndIf

  ProcedureReturn MCP_Toolkit_SetRecordToolResult(argumentsValue, *result, "routes", "route", MCP_Toolkit_DocsUpdateRouteMarkdown(argumentsValue, track))
EndProcedure

Procedure.i MCP_Toolkit_MilestoneCreateHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected track.s

  track = MCP_Toolkit_ReadDocsTrack(argumentsValue, *result)
  If track = ""
    ProcedureReturn #True
  EndIf

  ProcedureReturn MCP_Toolkit_SetRecordToolResult(argumentsValue, *result, "milestones", "milestone", MCP_Toolkit_MilestoneCreateMarkdown(argumentsValue, track))
EndProcedure

Procedure.i MCP_Toolkit_RegisterTool(*registry.MCP_ToolRegistry, name.s, title.s, description.s, schema.s, *handler)
  If MCP_RegisterTool(*registry, name, title, description, schema) = #False
    ProcedureReturn #False
  EndIf

  ProcedureReturn MCP_RegisterToolHandler(*registry, name, *handler)
EndProcedure

Procedure.i MCP_Toolkit_Register(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)
  If *dispatcher = 0 Or *registry = 0
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_ProjectInspectName$, "PureBasic Project Inspect", "Inspect the current PureBasic project structure, harness, docs, tests, examples, and toolkit state.", #MCP_Toolkit_ProjectInspectSchema$, @MCP_Toolkit_ProjectInspectHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_WorkflowBriefName$, "PureBasic Workflow Brief", "Return the default pair-development, algorithm explanation, human decision, docs, and Git workflow brief.", #MCP_Toolkit_WorkflowBriefSchema$, @MCP_Toolkit_WorkflowBriefHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_HarnessChecklistName$, "PureBasic Harness Checklist", "Return the default harness, ReadTheDocs, release, Git, and GitHub checklist for PureBasic development routes.", #MCP_Toolkit_HarnessChecklistSchema$, @MCP_Toolkit_HarnessChecklistHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_IncludeGraphName$, "PureBasic Include Graph", "List IncludeFile and XIncludeFile edges from the JSON-RPC library and toolkit source.", #MCP_Toolkit_IncludeGraphSchema$, @MCP_Toolkit_IncludeGraphHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_SymbolSearchName$, "PureBasic Symbol Search", "Search PureBasic source, project files, docs, and harness scripts for a symbol or text query.", #MCP_Toolkit_SymbolSearchSchema$, @MCP_Toolkit_SymbolSearchHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_ProcedureListName$, "PureBasic Procedure List", "List PureBasic procedure, declare, prototype, and structure lines with an optional prefix filter.", #MCP_Toolkit_ProcedureListSchema$, @MCP_Toolkit_ProcedureListHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_PbpListTargetsName$, "PureBasic PBP Target List", "List committed .pbp project targets using repository-relative paths.", #MCP_Toolkit_PbpListTargetsSchema$, @MCP_Toolkit_PbpListTargetsHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_TestRunName$, "PureBasic Test Run", "Run ./tools/test.sh with bounded output and timeout controls.", #MCP_Toolkit_HarnessExecutionSchema$, @MCP_Toolkit_TestRunHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_BuildRunName$, "PureBasic Build Run", "Run ./tools/build.sh with bounded output and timeout controls.", #MCP_Toolkit_HarnessExecutionSchema$, @MCP_Toolkit_BuildRunHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_CheckName$, "PureBasic Check", "Run ./tools/check.sh with bounded output and timeout controls.", #MCP_Toolkit_HarnessExecutionSchema$, @MCP_Toolkit_CheckHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_DocsBuildName$, "PureBasic Docs Build", "Run ./tools/build-docs.sh with bounded output and timeout controls.", #MCP_Toolkit_HarnessExecutionSchema$, @MCP_Toolkit_DocsBuildHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_BriefCreateName$, "PureBasic Brief Create", "Create a pair-development implementation brief as Markdown, optionally saving it under .local records.", #MCP_Toolkit_BriefCreateSchema$, @MCP_Toolkit_BriefCreateHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_AlgorithmExplainName$, "PureBasic Algorithm Explain", "Create an implementation algorithm and flow explanation as Markdown, optionally saving it under .local records.", #MCP_Toolkit_AlgorithmExplainSchema$, @MCP_Toolkit_AlgorithmExplainHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_DecisionRecordCreateName$, "PureBasic Decision Record Create", "Create a concise technical decision record as Markdown, optionally saving it under .local records.", #MCP_Toolkit_DecisionRecordCreateSchema$, @MCP_Toolkit_DecisionRecordCreateHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_GitPreflightName$, "PureBasic Git Preflight", "Inspect read-only Git status, diff stats, recent commits, and route checklist before committing or pushing.", #MCP_Toolkit_GitPreflightSchema$, @MCP_Toolkit_GitPreflightHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_GitCommitSummaryName$, "PureBasic Git Commit Summary", "Draft a commit summary from read-only Git status and diff stats without staging or committing.", #MCP_Toolkit_GitCommitSummarySchema$, @MCP_Toolkit_GitCommitSummaryHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_GithubPrDraftName$, "PureBasic GitHub PR Draft", "Draft a GitHub pull request body from route summary, tests, risks, and current Git state without pushing or opening a PR.", #MCP_Toolkit_GithubPrDraftSchema$, @MCP_Toolkit_GithubPrDraftHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_GithubReleaseDraftName$, "PureBasic GitHub Release Draft", "Draft release notes and an artifact checklist without tagging, uploading, or creating a GitHub release.", #MCP_Toolkit_GithubReleaseDraftSchema$, @MCP_Toolkit_GithubReleaseDraftHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_DocsCheckName$, "PureBasic Docs Check", "Return a read-only documentation route audit for core or toolkit work without modifying tracked files.", #MCP_Toolkit_DocsCheckSchema$, @MCP_Toolkit_DocsCheckHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_DocsUpdateRouteName$, "PureBasic Docs Update Route", "Draft route documentation updates for API docs, milestones, Sphinx navigation, release notes, and workflow docs.", #MCP_Toolkit_DocsUpdateRouteSchema$, @MCP_Toolkit_DocsUpdateRouteHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_Toolkit_RegisterTool(*registry, #MCP_Toolkit_MilestoneCreateName$, "PureBasic Milestone Create", "Draft a core or toolkit milestone entry without editing the tracked milestone file automatically.", #MCP_Toolkit_MilestoneCreateSchema$, @MCP_Toolkit_MilestoneCreateHandler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_RegisterToolsList(*dispatcher, *registry) = #False
    ProcedureReturn #False
  EndIf

  ProcedureReturn MCP_RegisterToolsCall(*dispatcher, *registry)
EndProcedure

MCP_Toolkit_SetConfig(MCP_Toolkit_DefaultProjectRoot())
