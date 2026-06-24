EnableExplicit

XIncludeFile "../../src/jsonrpc/mcp_tools.pbi"

#MCP_Toolkit_ProjectInspectName$ = "purebasic/project/inspect"
#MCP_Toolkit_WorkflowBriefName$ = "purebasic/workflow/brief"
#MCP_Toolkit_HarnessChecklistName$ = "purebasic/harness/checklist"
#MCP_Toolkit_IncludeGraphName$ = "purebasic/include/graph"
#MCP_Toolkit_SymbolSearchName$ = "purebasic/symbol/search"
#MCP_Toolkit_ProcedureListName$ = "purebasic/procedure/list"
#MCP_Toolkit_PbpListTargetsName$ = "purebasic/pbp/list-targets"

#MCP_Toolkit_ProjectInspectSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"
#MCP_Toolkit_WorkflowBriefSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"
#MCP_Toolkit_HarnessChecklistSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"
#MCP_Toolkit_IncludeGraphSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"
#MCP_Toolkit_SymbolSearchSchema$ = ~"{\"type\":\"object\",\"properties\":{\"query\":{\"type\":\"string\"}},\"required\":[\"query\"],\"additionalProperties\":false}"
#MCP_Toolkit_ProcedureListSchema$ = ~"{\"type\":\"object\",\"properties\":{\"prefix\":{\"type\":\"string\"}},\"additionalProperties\":false}"
#MCP_Toolkit_PbpListTargetsSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"

#MCP_Toolkit_DefaultMaxScanResults = 80

Structure MCP_Toolkit_Config
  projectRoot.s
EndStructure

Structure MCP_Toolkit_ScanState
  count.i
  truncated.i
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

    If FindString(trimmed, "XIncludeFile", 1) > 0 Or FindString(trimmed, "IncludeFile", 1) > 0
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
  text + #LF$
  text + "2. Explain algorithm and flow" + #LF$
  text + "- Describe input validation, state changes, JSON ownership, error behavior, output shape, cleanup, and diagnostics." + #LF$
  text + "- Ask for human decisions when semantics or policy are not mechanical." + #LF$
  text + #LF$
  text + "3. Implement through harness" + #LF$
  text + "- Create a focused branch." + #LF$
  text + "- Prefer tests and scenario probes close to the changed behavior." + #LF$
  text + "- Update API docs, route docs, ReadTheDocs navigation, and release notes." + #LF$
  text + #LF$
  text + "4. Verify, then Git/GitHub" + #LF$
  text + "- Run focused tests first when useful." + #LF$
  text + "- Run ./tools/check.sh before merge or push." + #LF$
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
  text + "Git local workflow:" + #LF$
  text + "- git status --short --branch" + #LF$
  text + "- git checkout -b feature/or-docs-slug" + #LF$
  text + "- implement, test, document" + #LF$
  text + "- git diff --check" + #LF$
  text + "- git commit with an intent-focused message" + #LF$
  text + "- git checkout main && git merge --no-ff branch" + #LF$
  text + #LF$
  text + "GitHub workflow:" + #LF$
  text + "- git pull --ff-only on main before a collaborative branch" + #LF$
  text + "- push the feature branch when review or CI is needed" + #LF$
  text + "- open a PR with verification evidence" + #LF$
  text + "- check CI before merge" + #LF$
  text + "- delete merged branches"

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

  If MCP_RegisterToolsList(*dispatcher, *registry) = #False
    ProcedureReturn #False
  EndIf

  ProcedureReturn MCP_RegisterToolsCall(*dispatcher, *registry)
EndProcedure

MCP_Toolkit_SetConfig(MCP_Toolkit_DefaultProjectRoot())
