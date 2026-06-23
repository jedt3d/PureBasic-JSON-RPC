EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "dispatch.pbi"

PureUnitOptions(Thread)

Global DispatchNotificationMethod.s
Global DispatchNotificationMessage.s

Procedure.i EchoRequestHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected textValue

  If paramsValue <> 0 And JSONType(paramsValue) = #PB_JSON_Object
    textValue = GetJSONMember(paramsValue, "text")
    If textValue <> 0 And JSONType(textValue) = #PB_JSON_String
      *result\ok = #True
      *result\resultJson = #DQUOTE$ + JSONRPC_Protocol_EscapeString(GetJSONString(textValue)) + #DQUOTE$
      ProcedureReturn #True
    EndIf
  EndIf

  *result\ok = #False
  *result\errorCode = #JSONRPC_Error_InvalidParams
  *result\errorMessage = "Invalid params"
  ProcedureReturn #True
EndProcedure

Procedure.i InvalidParamsRequestHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #False
  *result\errorCode = #JSONRPC_Error_InvalidParams
  *result\errorMessage = "Invalid params"
  ProcedureReturn #True
EndProcedure

Procedure.i LogNotificationHandler(paramsValue, *context.JSONRPC_RequestContext)
  Protected messageValue

  DispatchNotificationMethod = *context\method
  DispatchNotificationMessage = ""

  If paramsValue <> 0 And JSONType(paramsValue) = #PB_JSON_Object
    messageValue = GetJSONMember(paramsValue, "message")
    If messageValue <> 0 And JSONType(messageValue) = #PB_JSON_String
      DispatchNotificationMessage = GetJSONString(messageValue)
    EndIf
  EndIf

  ProcedureReturn #True
EndProcedure

ProcedureUnit RequestHandlerReturnsResponse()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_RegisterRequest(@dispatcher, "tools/echo", @EchoRequestHandler()), "Request handler should register.")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/echo\",\"params\":{\"text\":\"hello\"},\"id\":1}")

  AssertString(response, ~"{\"jsonrpc\":\"2.0\",\"result\":\"hello\",\"id\":1}", "Request handler should return a JSON-RPC result response.")
  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit DispatchToConnectionWritesResponse()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  JSONRPC_RegisterRequest(@dispatcher, "tools/echo", @EchoRequestHandler())

  Assert(JSONRPC_Dispatcher_DispatchToConnection(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/echo\",\"params\":{\"text\":\"captured\"},\"id\":2}"), "Dispatch to connection should write response.")
  AssertString(writer\captured, ~"{\"jsonrpc\":\"2.0\",\"result\":\"captured\",\"id\":2}", "Fake writer should capture dispatch response.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit NotificationHandlerReceivesParamsAndEmitsNoResponse()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  DispatchNotificationMethod = ""
  DispatchNotificationMessage = ""
  JSONRPC_Dispatcher_Init(@dispatcher)

  Assert(JSONRPC_RegisterNotification(@dispatcher, "notifications/log", @LogNotificationHandler()), "Notification handler should register.")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/log\",\"params\":{\"message\":\"ready\"}}")

  AssertString(response, "", "Notification should not emit a response.")
  AssertString(DispatchNotificationMethod, "notifications/log", "Notification context should include method.")
  AssertString(DispatchNotificationMessage, "ready", "Notification handler should receive params.")
EndProcedureUnit

ProcedureUnit UnknownRequestReturnsMethodNotFound()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/missing\",\"id\":\"abc\"}")

  Assert(FindString(response, ~"\"code\":-32601", 1) > 0, "Unknown request should return method-not-found.")
  Assert(FindString(response, ~"\"id\":\"abc\"", 1) > 0, "Unknown request should preserve id.")
EndProcedureUnit

ProcedureUnit UnknownNotificationEmitsNoResponse()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/missing\"}")

  AssertString(response, "", "Unknown notifications should not produce responses.")
EndProcedureUnit

ProcedureUnit HandlerCanReturnInvalidParams()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_RegisterRequest(@dispatcher, "tools/needsParams", @InvalidParamsRequestHandler())

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/needsParams\",\"params\":{},\"id\":3}")

  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "Handler should be able to return invalid params.")
  Assert(FindString(response, ~"\"id\":3", 1) > 0, "Invalid params response should preserve id.")
EndProcedureUnit

