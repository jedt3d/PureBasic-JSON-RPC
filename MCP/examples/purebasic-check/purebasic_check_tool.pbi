EnableExplicit

XIncludeFile "../../../src/jsonrpc/mcp_tools.pbi"

#MCP_CheckTool_Name$ = "purebasic/check"
#MCP_CheckTool_Title$ = "PureBasic Check"
#MCP_CheckTool_Description$ = "Run the project PureBasic verification script."
#MCP_CheckTool_InputSchema$ = ~"{\"type\":\"object\",\"properties\":{},\"additionalProperties\":false}"
#MCP_CheckTool_DefaultMaxOutputChars = 8000

Structure MCP_CheckTool_Config
  projectRoot.s
  shellCommand.s
  maxOutputChars.i
EndStructure

Structure MCP_CheckTool_CommandResult
  launched.i
  exitCode.i
  output.s
  truncated.i
EndStructure

Global MCP_CheckTool_Config.MCP_CheckTool_Config

Declare MCP_CheckTool_SetConfig(projectRoot.s, shellCommand.s = "./tools/check.sh 2>&1", maxOutputChars.i = #MCP_CheckTool_DefaultMaxOutputChars)
Declare MCP_CheckTool_ResetConfig()
Declare.i MCP_CheckTool_RunCommand(*commandResult.MCP_CheckTool_CommandResult)
Declare.i MCP_CheckTool_Handler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
Declare.i MCP_CheckTool_Register(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)

Procedure.s MCP_CheckTool_DefaultProjectRoot()
  ProcedureReturn GetCurrentDirectory()
EndProcedure

Procedure MCP_CheckTool_SetConfig(projectRoot.s, shellCommand.s = "./tools/check.sh 2>&1", maxOutputChars.i = #MCP_CheckTool_DefaultMaxOutputChars)
  MCP_CheckTool_Config\projectRoot = projectRoot
  MCP_CheckTool_Config\shellCommand = shellCommand
  MCP_CheckTool_Config\maxOutputChars = maxOutputChars

  If MCP_CheckTool_Config\projectRoot = ""
    MCP_CheckTool_Config\projectRoot = MCP_CheckTool_DefaultProjectRoot()
  EndIf

  If MCP_CheckTool_Config\shellCommand = ""
    MCP_CheckTool_Config\shellCommand = "./tools/check.sh 2>&1"
  EndIf

  If MCP_CheckTool_Config\maxOutputChars <= 0
    MCP_CheckTool_Config\maxOutputChars = #MCP_CheckTool_DefaultMaxOutputChars
  EndIf
EndProcedure

Procedure MCP_CheckTool_ResetConfig()
  MCP_CheckTool_SetConfig(MCP_CheckTool_DefaultProjectRoot())
EndProcedure

Procedure MCP_CheckTool_AppendOutput(*commandResult.MCP_CheckTool_CommandResult, chunk.s)
  Protected remaining.i

  If *commandResult\truncated
    ProcedureReturn
  EndIf

  remaining = MCP_CheckTool_Config\maxOutputChars - Len(*commandResult\output)
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

Procedure.i MCP_CheckTool_RunCommand(*commandResult.MCP_CheckTool_CommandResult)
  Protected program.i

  *commandResult\launched = #False
  *commandResult\exitCode = -1
  *commandResult\output = ""
  *commandResult\truncated = #False

  program = RunProgram("sh", ~"-c \"" + MCP_CheckTool_Config\shellCommand + ~"\"", MCP_CheckTool_Config\projectRoot, #PB_Program_Open | #PB_Program_Read)
  If program = 0
    *commandResult\output = "Unable to launch check command."
    ProcedureReturn #False
  EndIf

  *commandResult\launched = #True

  While ProgramRunning(program)
    If AvailableProgramOutput(program)
      MCP_CheckTool_AppendOutput(*commandResult, ReadProgramString(program) + #LF$)
    Else
      Delay(5)
    EndIf
  Wend

  While AvailableProgramOutput(program)
    MCP_CheckTool_AppendOutput(*commandResult, ReadProgramString(program) + #LF$)
  Wend

  *commandResult\exitCode = ProgramExitCode(program)
  CloseProgram(program)
  ProcedureReturn Bool(*commandResult\exitCode = 0)
EndProcedure

Procedure.s MCP_CheckTool_FormatResult(*commandResult.MCP_CheckTool_CommandResult)
  Protected text.s

  If *commandResult\exitCode = 0
    text = "purebasic/check passed with exit code 0."
  Else
    text = "purebasic/check failed with exit code " + Str(*commandResult\exitCode) + "."
  EndIf

  If *commandResult\output <> ""
    text + #LF$ + #LF$ + *commandResult\output
  EndIf

  If *commandResult\truncated
    text + #LF$ + "[output truncated]"
  EndIf

  ProcedureReturn text
EndProcedure

Procedure.i MCP_CheckTool_Handler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected commandResult.MCP_CheckTool_CommandResult
  Protected ok.i

  ok = MCP_CheckTool_RunCommand(@commandResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult(MCP_CheckTool_FormatResult(@commandResult), Bool(ok = #False))
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_CheckTool_Register(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)
  If *dispatcher = 0 Or *registry = 0
    ProcedureReturn #False
  EndIf

  If MCP_RegisterTool(*registry, #MCP_CheckTool_Name$, #MCP_CheckTool_Title$, #MCP_CheckTool_Description$, #MCP_CheckTool_InputSchema$) = #False
    ProcedureReturn #False
  EndIf

  If MCP_RegisterToolHandler(*registry, #MCP_CheckTool_Name$, @MCP_CheckTool_Handler()) = #False
    ProcedureReturn #False
  EndIf

  If MCP_RegisterToolsList(*dispatcher, *registry) = #False
    ProcedureReturn #False
  EndIf

  ProcedureReturn MCP_RegisterToolsCall(*dispatcher, *registry)
EndProcedure

MCP_CheckTool_ResetConfig()
