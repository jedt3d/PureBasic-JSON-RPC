EnableExplicit

XIncludeFile "protocol.pbi"

Prototype.i JSONRPC_RequestHandler(paramsValue, *context, *result)
Prototype.i JSONRPC_NotificationHandler(paramsValue, *context)

Structure JSONRPC_RequestContext
  method.s
  idText.s
  hasId.i
  *connection.JSONRPC_Connection
EndStructure

Structure JSONRPC_HandlerResult
  ok.i
  resultJson.s
  errorCode.i
  errorMessage.s
EndStructure

Structure JSONRPC_Dispatcher
  Map requestHandlers.i()
  Map notificationHandlers.i()
EndStructure

Declare JSONRPC_Dispatcher_Init(*dispatcher.JSONRPC_Dispatcher)
Declare.i JSONRPC_RegisterRequest(*dispatcher.JSONRPC_Dispatcher, method.s, *handler.JSONRPC_RequestHandler)
Declare.i JSONRPC_RegisterNotification(*dispatcher.JSONRPC_Dispatcher, method.s, *handler.JSONRPC_NotificationHandler)
Declare.s JSONRPC_Dispatcher_Dispatch(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)
Declare.i JSONRPC_Dispatcher_DispatchToConnection(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)

Procedure JSONRPC_Dispatcher_Init(*dispatcher.JSONRPC_Dispatcher)
  ClearMap(*dispatcher\requestHandlers())
  ClearMap(*dispatcher\notificationHandlers())
EndProcedure

Procedure.i JSONRPC_RegisterRequest(*dispatcher.JSONRPC_Dispatcher, method.s, *handler.JSONRPC_RequestHandler)
  If method = "" Or *handler = 0
    ProcedureReturn #False
  EndIf

  *dispatcher\requestHandlers(method) = *handler
  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_RegisterNotification(*dispatcher.JSONRPC_Dispatcher, method.s, *handler.JSONRPC_NotificationHandler)
  If method = "" Or *handler = 0
    ProcedureReturn #False
  EndIf

  *dispatcher\notificationHandlers(method) = *handler
  ProcedureReturn #True
EndProcedure

Procedure JSONRPC_Dispatcher_ResetHandlerResult(*result.JSONRPC_HandlerResult)
  *result\ok = #False
  *result\resultJson = "null"
  *result\errorCode = #JSONRPC_Error_Internal
  *result\errorMessage = "Internal error"
EndProcedure

Procedure JSONRPC_Dispatcher_FillContext(*context.JSONRPC_RequestContext, *inspect.JSONRPC_ProtocolResult, *connection.JSONRPC_Connection)
  *context\method = *inspect\method
  *context\idText = *inspect\idText
  *context\hasId = *inspect\hasId
  *context\connection = *connection
EndProcedure

Procedure.s JSONRPC_Dispatcher_Dispatch(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)
  Protected inspect.JSONRPC_ProtocolResult
  Protected context.JSONRPC_RequestContext
  Protected handlerResult.JSONRPC_HandlerResult
  Protected json.i
  Protected root
  Protected paramsValue
  Protected requestHandler.JSONRPC_RequestHandler
  Protected notificationHandler.JSONRPC_NotificationHandler
  Protected handlerOk.i

  If *connection <> 0
    *connection\diagnostics\receivedMessages + 1
  EndIf

  If JSONRPC_Protocol_Inspect(body, @inspect) = #False
    If *connection <> 0
      *connection\diagnostics\errors + 1
      JSONRPC_Connection_EmitEvent(*connection, #JSONRPC_Connection_EventMalformedMessage, inspect\errorMessage)
    EndIf

    If inspect\requiresResponse
      ProcedureReturn JSONRPC_Protocol_BuildErrorResponse(inspect\errorCode, inspect\errorMessage, inspect\idText)
    EndIf

    ProcedureReturn ""
  EndIf

  If inspect\messageType = #JSONRPC_MessageTypeResponse
    ProcedureReturn ""
  EndIf

  json = ParseJSON(#PB_Any, body)
  If json = 0
    ProcedureReturn JSONRPC_Protocol_BuildErrorResponse(#JSONRPC_Error_Parse, "Parse error", "null")
  EndIf

  root = JSONValue(json)
  paramsValue = GetJSONMember(root, "params")
  JSONRPC_Dispatcher_FillContext(@context, @inspect, *connection)

  If inspect\messageType = #JSONRPC_MessageTypeNotification
    If FindMapElement(*dispatcher\notificationHandlers(), inspect\method)
      notificationHandler = *dispatcher\notificationHandlers()
      notificationHandler(paramsValue, @context)
    ElseIf *connection <> 0
      JSONRPC_Connection_EmitEvent(*connection, #JSONRPC_Connection_EventUnhandledNotification, inspect\method)
    EndIf

    FreeJSON(json)
    ProcedureReturn ""
  EndIf

  If FindMapElement(*dispatcher\requestHandlers(), inspect\method) = #False
    If *connection <> 0
      *connection\diagnostics\errors + 1
    EndIf

    FreeJSON(json)
    ProcedureReturn JSONRPC_Protocol_BuildMethodNotFoundResponse(inspect\idText)
  EndIf

  requestHandler = *dispatcher\requestHandlers()
  JSONRPC_Dispatcher_ResetHandlerResult(@handlerResult)
  handlerOk = requestHandler(paramsValue, @context, @handlerResult)
  FreeJSON(json)

  If handlerOk = #False And handlerResult\ok = #False And handlerResult\errorCode = #JSONRPC_Error_Internal
    If *connection <> 0
      *connection\diagnostics\errors + 1
    EndIf

    ProcedureReturn JSONRPC_Protocol_BuildErrorResponse(#JSONRPC_Error_Internal, "Internal error", inspect\idText)
  EndIf

  If handlerResult\ok
    ProcedureReturn JSONRPC_Protocol_BuildResultResponse(handlerResult\resultJson, inspect\idText)
  EndIf

  If *connection <> 0
    *connection\diagnostics\errors + 1
  EndIf

  ProcedureReturn JSONRPC_Protocol_BuildErrorResponse(handlerResult\errorCode, handlerResult\errorMessage, inspect\idText)
EndProcedure

Procedure.i JSONRPC_Dispatcher_DispatchToConnection(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)
  Protected response.s

  response = JSONRPC_Dispatcher_Dispatch(*dispatcher, *connection, body)

  If response = ""
    ProcedureReturn #True
  EndIf

  ProcedureReturn JSONRPC_Connection_SendBody(*connection, response)
EndProcedure
