EnableExplicit

XIncludeFile "stdio_runtime.pbi"

#MCP_ProtocolVersion$ = "2025-11-25"

Structure MCP_ServerInfo
  name.s
  title.s
  version.s
  instructions.s
  toolsListChanged.i
  initialized.i
EndStructure

Declare MCP_ServerInfo_Init(*server.MCP_ServerInfo, name.s, version.s, title.s = "", instructions.s = "")
Declare.s MCP_BuildInitializeResult(*server.MCP_ServerInfo)
Declare.i MCP_RegisterLifecycle(*dispatcher.JSONRPC_Dispatcher, *server.MCP_ServerInfo)
Declare.i MCP_InitializeHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
Declare.i MCP_InitializedHandler(paramsValue, *context.JSONRPC_RequestContext)

Global *MCP_CurrentLifecycleServer.MCP_ServerInfo

Procedure MCP_ServerInfo_Init(*server.MCP_ServerInfo, name.s, version.s, title.s = "", instructions.s = "")
  *server\name = name
  *server\version = version
  *server\title = title
  *server\instructions = instructions
  *server\toolsListChanged = #False
  *server\initialized = #False
EndProcedure

Procedure.s MCP_BuildServerInfoJson(*server.MCP_ServerInfo)
  Protected info.s

  info = ~"{\"name\":\"" + JSONRPC_Protocol_EscapeString(*server\name) + ~"\",\"version\":\"" + JSONRPC_Protocol_EscapeString(*server\version) + ~"\""

  If *server\title <> ""
    info + ~",\"title\":\"" + JSONRPC_Protocol_EscapeString(*server\title) + ~"\""
  EndIf

  info + "}"
  ProcedureReturn info
EndProcedure

Procedure.s MCP_BuildCapabilitiesJson(*server.MCP_ServerInfo)
  If *server\toolsListChanged
    ProcedureReturn ~"{\"tools\":{\"listChanged\":true}}"
  EndIf

  ProcedureReturn ~"{\"tools\":{}}"
EndProcedure

Procedure.s MCP_BuildInitializeResult(*server.MCP_ServerInfo)
  Protected result.s

  result = ~"{\"protocolVersion\":\"" + #MCP_ProtocolVersion$ + ~"\",\"capabilities\":" + MCP_BuildCapabilitiesJson(*server) + ~",\"serverInfo\":" + MCP_BuildServerInfoJson(*server)

  If *server\instructions <> ""
    result + ~",\"instructions\":\"" + JSONRPC_Protocol_EscapeString(*server\instructions) + ~"\""
  EndIf

  result + "}"
  ProcedureReturn result
EndProcedure

Procedure.s MCP_ReadProtocolVersion(paramsValue)
  Protected versionValue

  If paramsValue <> 0 And JSONType(paramsValue) = #PB_JSON_Object
    versionValue = GetJSONMember(paramsValue, "protocolVersion")
    If versionValue <> 0 And JSONType(versionValue) = #PB_JSON_String
      ProcedureReturn GetJSONString(versionValue)
    EndIf
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.i MCP_InitializeHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected requestedVersion.s

  If *MCP_CurrentLifecycleServer = 0
    *result\ok = #False
    *result\errorCode = #JSONRPC_Error_Internal
    *result\errorMessage = "MCP lifecycle server is not configured"
    ProcedureReturn #True
  EndIf

  requestedVersion = MCP_ReadProtocolVersion(paramsValue)
  If requestedVersion = ""
    *result\ok = #False
    *result\errorCode = #JSONRPC_Error_InvalidParams
    *result\errorMessage = "Missing protocolVersion"
    ProcedureReturn #True
  EndIf

  *result\ok = #True
  *result\resultJson = MCP_BuildInitializeResult(*MCP_CurrentLifecycleServer)
  ProcedureReturn #True
EndProcedure

Procedure.i MCP_InitializedHandler(paramsValue, *context.JSONRPC_RequestContext)
  If *MCP_CurrentLifecycleServer <> 0
    *MCP_CurrentLifecycleServer\initialized = #True
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.i MCP_RegisterLifecycle(*dispatcher.JSONRPC_Dispatcher, *server.MCP_ServerInfo)
  If *dispatcher = 0 Or *server = 0
    ProcedureReturn #False
  EndIf

  *MCP_CurrentLifecycleServer = *server
  If JSONRPC_RegisterRequest(*dispatcher, "initialize", @MCP_InitializeHandler()) = #False
    ProcedureReturn #False
  EndIf

  ProcedureReturn JSONRPC_RegisterNotification(*dispatcher, "notifications/initialized", @MCP_InitializedHandler())
EndProcedure
