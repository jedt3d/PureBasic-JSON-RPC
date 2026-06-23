EnableExplicit

XIncludeFile "mcp_lifecycle.pbi"

Structure MCP_Tool
  name.s
  title.s
  description.s
  inputSchemaJson.s
EndStructure

Structure MCP_ToolRegistry
  Map tools.MCP_Tool()
  listChanged.i
EndStructure

Declare MCP_ToolRegistry_Init(*registry.MCP_ToolRegistry)
Declare.i MCP_RegisterTool(*registry.MCP_ToolRegistry, name.s, title.s, description.s, inputSchemaJson.s)
Declare.s MCP_Tools_BuildListResult(*registry.MCP_ToolRegistry)
Declare.s MCP_Tools_BuildListChangedNotification()
Declare.i MCP_RegisterToolsList(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)
Declare.i MCP_ToolsListHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)

Global *MCP_CurrentToolRegistry.MCP_ToolRegistry

Procedure MCP_ToolRegistry_Init(*registry.MCP_ToolRegistry)
  ClearMap(*registry\tools())
  *registry\listChanged = #False
EndProcedure

Procedure.i MCP_ToolNameIsValid(name.s)
  Protected index.i
  Protected charCode.i

  If Len(name) < 1 Or Len(name) > 128
    ProcedureReturn #False
  EndIf

  For index = 1 To Len(name)
    charCode = Asc(Mid(name, index, 1))
    If (charCode >= 'A' And charCode <= 'Z') Or (charCode >= 'a' And charCode <= 'z') Or (charCode >= '0' And charCode <= '9') Or charCode = '_' Or charCode = '-' Or charCode = '.'
      Continue
    EndIf

    ProcedureReturn #False
  Next

  ProcedureReturn #True
EndProcedure

Procedure.i MCP_RegisterTool(*registry.MCP_ToolRegistry, name.s, title.s, description.s, inputSchemaJson.s)
  If *registry = 0 Or MCP_ToolNameIsValid(name) = #False
    ProcedureReturn #False
  EndIf

  If JSONRPC_Protocol_IsValidParamsJson(inputSchemaJson) = #False
    ProcedureReturn #False
  EndIf

  AddMapElement(*registry\tools(), name)
  *registry\tools()\name = name
  *registry\tools()\title = title
  *registry\tools()\description = description
  *registry\tools()\inputSchemaJson = inputSchemaJson
  *registry\listChanged = #True

  ProcedureReturn #True
EndProcedure

Procedure.s MCP_Tool_ToJson(*tool.MCP_Tool)
  Protected json.s

  json = ~"{\"name\":\"" + JSONRPC_Protocol_EscapeString(*tool\name) + ~"\",\"description\":\"" + JSONRPC_Protocol_EscapeString(*tool\description) + ~"\",\"inputSchema\":" + *tool\inputSchemaJson

  If *tool\title <> ""
    json + ~",\"title\":\"" + JSONRPC_Protocol_EscapeString(*tool\title) + ~"\""
  EndIf

  json + "}"
  ProcedureReturn json
EndProcedure

Procedure.s MCP_Tools_BuildListResult(*registry.MCP_ToolRegistry)
  Protected toolsJson.s
  Protected count.i

  If *registry <> 0
    ForEach *registry\tools()
      If count > 0
        toolsJson + ","
      EndIf

      toolsJson + MCP_Tool_ToJson(@*registry\tools())
      count + 1
    Next
  EndIf

  ProcedureReturn ~"{\"tools\":[" + toolsJson + "]}"
EndProcedure

Procedure.s MCP_Tools_BuildListChangedNotification()
  ProcedureReturn ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/tools/list_changed\"}"
EndProcedure

Procedure.i MCP_ToolsListHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  If *MCP_CurrentToolRegistry = 0
    *result\ok = #False
    *result\errorCode = #JSONRPC_Error_Internal
    *result\errorMessage = "MCP tool registry is not configured"
    ProcedureReturn #True
  EndIf

  *result\ok = #True
  *result\resultJson = MCP_Tools_BuildListResult(*MCP_CurrentToolRegistry)
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_RegisterToolsList(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)
  If *dispatcher = 0 Or *registry = 0
    ProcedureReturn #False
  EndIf

  *MCP_CurrentToolRegistry = *registry
  ProcedureReturn JSONRPC_RegisterRequest(*dispatcher, "tools/list", @MCP_ToolsListHandler())
EndProcedure
