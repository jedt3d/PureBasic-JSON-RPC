EnableExplicit

XIncludeFile "protocol.pbi"

Prototype.i JSONRPC_RequestHandler(paramsValue, *context, *result)
Prototype.i JSONRPC_NotificationHandler(paramsValue, *context)
Prototype.i JSONRPC_StarRequestHandler(method.s, paramsValue, *context, *result)
Prototype.i JSONRPC_StarNotificationHandler(method.s, paramsValue, *context)

Structure JSONRPC_RequestContext
  method.s
  idText.s
  hasId.i
  cancellationIdText.s
  cancellationRequested.i
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
  starRequestHandler.JSONRPC_StarRequestHandler
  starNotificationHandler.JSONRPC_StarNotificationHandler
  replaceHandlers.i
EndStructure

Declare JSONRPC_Dispatcher_Init(*dispatcher.JSONRPC_Dispatcher)
Declare JSONRPC_Dispatcher_SetReplaceHandlers(*dispatcher.JSONRPC_Dispatcher, replaceHandlers.i)
Declare.i JSONRPC_RegisterRequest(*dispatcher.JSONRPC_Dispatcher, method.s, *handler.JSONRPC_RequestHandler)
Declare.i JSONRPC_RegisterNotification(*dispatcher.JSONRPC_Dispatcher, method.s, *handler.JSONRPC_NotificationHandler)
Declare.i JSONRPC_RegisterStarRequest(*dispatcher.JSONRPC_Dispatcher, *handler.JSONRPC_StarRequestHandler)
Declare.i JSONRPC_RegisterStarNotification(*dispatcher.JSONRPC_Dispatcher, *handler.JSONRPC_StarNotificationHandler)
Declare.i JSONRPC_UnregisterRequest(*dispatcher.JSONRPC_Dispatcher, method.s)
Declare.i JSONRPC_UnregisterNotification(*dispatcher.JSONRPC_Dispatcher, method.s)
Declare.i JSONRPC_Dispatcher_HasRequest(*dispatcher.JSONRPC_Dispatcher, method.s)
Declare.i JSONRPC_Dispatcher_HasNotification(*dispatcher.JSONRPC_Dispatcher, method.s)
Declare.i JSONRPC_RequestContext_IsCancellationRequested(*context.JSONRPC_RequestContext)
Declare.s JSONRPC_RequestContext_CancellationId(*context.JSONRPC_RequestContext)
Declare.s JSONRPC_Dispatcher_Dispatch(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)
Declare.i JSONRPC_Dispatcher_DispatchToConnection(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)

Procedure JSONRPC_Dispatcher_Init(*dispatcher.JSONRPC_Dispatcher)
  ClearMap(*dispatcher\requestHandlers())
  ClearMap(*dispatcher\notificationHandlers())
  *dispatcher\starRequestHandler = 0
  *dispatcher\starNotificationHandler = 0
  *dispatcher\replaceHandlers = #True
EndProcedure

Procedure JSONRPC_Dispatcher_SetReplaceHandlers(*dispatcher.JSONRPC_Dispatcher, replaceHandlers.i)
  If *dispatcher <> 0
    *dispatcher\replaceHandlers = Bool(replaceHandlers)
  EndIf
EndProcedure

Procedure.i JSONRPC_RegisterRequest(*dispatcher.JSONRPC_Dispatcher, method.s, *handler.JSONRPC_RequestHandler)
  If method = "" Or *handler = 0
    ProcedureReturn #False
  EndIf

  If FindMapElement(*dispatcher\requestHandlers(), method) And *dispatcher\replaceHandlers = #False
    ProcedureReturn #False
  EndIf

  *dispatcher\requestHandlers(method) = *handler
  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_RegisterNotification(*dispatcher.JSONRPC_Dispatcher, method.s, *handler.JSONRPC_NotificationHandler)
  If method = "" Or *handler = 0
    ProcedureReturn #False
  EndIf

  If FindMapElement(*dispatcher\notificationHandlers(), method) And *dispatcher\replaceHandlers = #False
    ProcedureReturn #False
  EndIf

  *dispatcher\notificationHandlers(method) = *handler
  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_RegisterStarRequest(*dispatcher.JSONRPC_Dispatcher, *handler.JSONRPC_StarRequestHandler)
  If *dispatcher = 0 Or *handler = 0
    ProcedureReturn #False
  EndIf

  *dispatcher\starRequestHandler = *handler
  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_RegisterStarNotification(*dispatcher.JSONRPC_Dispatcher, *handler.JSONRPC_StarNotificationHandler)
  If *dispatcher = 0 Or *handler = 0
    ProcedureReturn #False
  EndIf

  *dispatcher\starNotificationHandler = *handler
  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_UnregisterRequest(*dispatcher.JSONRPC_Dispatcher, method.s)
  If *dispatcher = 0 Or method = ""
    ProcedureReturn #False
  EndIf

  If FindMapElement(*dispatcher\requestHandlers(), method)
    DeleteMapElement(*dispatcher\requestHandlers())
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i JSONRPC_UnregisterNotification(*dispatcher.JSONRPC_Dispatcher, method.s)
  If *dispatcher = 0 Or method = ""
    ProcedureReturn #False
  EndIf

  If FindMapElement(*dispatcher\notificationHandlers(), method)
    DeleteMapElement(*dispatcher\notificationHandlers())
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i JSONRPC_Dispatcher_HasRequest(*dispatcher.JSONRPC_Dispatcher, method.s)
  If *dispatcher = 0 Or method = ""
    ProcedureReturn #False
  EndIf

  ProcedureReturn FindMapElement(*dispatcher\requestHandlers(), method)
EndProcedure

Procedure.i JSONRPC_Dispatcher_HasNotification(*dispatcher.JSONRPC_Dispatcher, method.s)
  If *dispatcher = 0 Or method = ""
    ProcedureReturn #False
  EndIf

  ProcedureReturn FindMapElement(*dispatcher\notificationHandlers(), method)
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
  *context\cancellationIdText = *inspect\idText
  *context\cancellationRequested = JSONRPC_Connection_IsCancellationRequested(*connection, *inspect\idText)
  *context\connection = *connection
EndProcedure

Procedure.i JSONRPC_RequestContext_IsCancellationRequested(*context.JSONRPC_RequestContext)
  If *context = 0
    ProcedureReturn #False
  EndIf

  If *context\cancellationRequested
    ProcedureReturn #True
  EndIf

  ProcedureReturn JSONRPC_Connection_IsCancellationRequested(*context\connection, *context\cancellationIdText)
EndProcedure

Procedure.s JSONRPC_RequestContext_CancellationId(*context.JSONRPC_RequestContext)
  If *context = 0
    ProcedureReturn ""
  EndIf

  ProcedureReturn *context\cancellationIdText
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
  Protected starRequestHandler.JSONRPC_StarRequestHandler
  Protected starNotificationHandler.JSONRPC_StarNotificationHandler
  Protected handlerOk.i

  If *connection <> 0
    *connection\diagnostics\receivedMessages + 1
    If *connection\tracePayloads
      JSONRPC_Trace_Log(*connection, #JSONRPC_Trace_Messages, "received: " + body)
    Else
      JSONRPC_Trace_Log(*connection, #JSONRPC_Trace_Messages, "received message bytes=" + Str(StringByteLength(body, #PB_UTF8)))
    EndIf
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
    ElseIf *dispatcher\starNotificationHandler <> 0
      starNotificationHandler = *dispatcher\starNotificationHandler
      starNotificationHandler(inspect\method, paramsValue, @context)
    ElseIf *connection <> 0
      JSONRPC_Connection_EmitEvent(*connection, #JSONRPC_Connection_EventUnhandledNotification, inspect\method)
    EndIf

    FreeJSON(json)
    ProcedureReturn ""
  EndIf

  If FindMapElement(*dispatcher\requestHandlers(), inspect\method) = #False And *dispatcher\starRequestHandler = 0
    If *connection <> 0
      *connection\diagnostics\errors + 1
    EndIf

    FreeJSON(json)
    ProcedureReturn JSONRPC_Protocol_BuildMethodNotFoundResponse(inspect\idText)
  EndIf

  If FindMapElement(*dispatcher\requestHandlers(), inspect\method)
    requestHandler = *dispatcher\requestHandlers()
  Else
    starRequestHandler = *dispatcher\starRequestHandler
  EndIf

  JSONRPC_Dispatcher_ResetHandlerResult(@handlerResult)

  If requestHandler <> 0
    handlerOk = requestHandler(paramsValue, @context, @handlerResult)
  Else
    handlerOk = starRequestHandler(inspect\method, paramsValue, @context, @handlerResult)
  EndIf

  FreeJSON(json)

  If *connection <> 0 And inspect\hasId
    JSONRPC_Connection_ClearCancellation(*connection, inspect\idText)
  EndIf

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
