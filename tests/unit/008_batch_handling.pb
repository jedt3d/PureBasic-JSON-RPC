EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "batch.pbi"

PureUnitOptions(Thread)

Global BatchNotificationCount.i

Procedure.i BatchEchoHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
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

Procedure.i BatchNotifyHandler(paramsValue, *context.JSONRPC_RequestContext)
  BatchNotificationCount + 1
  ProcedureReturn #True
EndProcedure

Procedure BatchPrepare(*dispatcher.JSONRPC_Dispatcher)
  BatchNotificationCount = 0
  JSONRPC_Dispatcher_Init(*dispatcher)
  JSONRPC_RegisterRequest(*dispatcher, "tools/echo", @BatchEchoHandler())
  JSONRPC_RegisterNotification(*dispatcher, "notifications/log", @BatchNotifyHandler())
EndProcedure

ProcedureUnit EmptyBatchReturnsInvalidRequest()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  BatchPrepare(@dispatcher)
  response = JSONRPC_Batch_Dispatch(@dispatcher, 0, "[]")

  Assert(FindString(response, ~"\"code\":-32600", 1) > 0, "Empty batch should return invalid request.")
  Assert(FindString(response, ~"\"id\":null", 1) > 0, "Empty batch id should be null.")
EndProcedureUnit

ProcedureUnit NotificationOnlyBatchReturnsNothing()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  BatchPrepare(@dispatcher)
  response = JSONRPC_Batch_Dispatch(@dispatcher, 0, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"notifications/log\"}]")

  AssertString(response, "", "Notification-only batch should produce no response.")
  Assert(BatchNotificationCount = 1, "Notification handler should run.")
EndProcedureUnit

ProcedureUnit MixedBatchReturnsOnlyRequiredResponses()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  BatchPrepare(@dispatcher)
  response = JSONRPC_Batch_Dispatch(@dispatcher, 0, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"tools/echo\",\"params\":{\"text\":\"one\"},\"id\":1},{\"jsonrpc\":\"2.0\",\"method\":\"notifications/log\"},{\"foo\":\"boo\"},{\"jsonrpc\":\"2.0\",\"method\":\"tools/missing\",\"id\":\"x\"}]")

  Assert(Left(response, 1) = "[", "Mixed batch should return an array.")
  Assert(FindString(response, ~"\"result\":\"one\"", 1) > 0, "Batch should include successful response.")
  Assert(FindString(response, ~"\"code\":-32600", 1) > 0, "Batch should include invalid item response.")
  Assert(FindString(response, ~"\"code\":-32601", 1) > 0, "Batch should include unknown method response.")
  Assert(BatchNotificationCount = 1, "Batch notification should run without response.")
EndProcedureUnit

ProcedureUnit NonBatchFallsBackToSingleDispatch()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  BatchPrepare(@dispatcher)
  response = JSONRPC_Batch_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/echo\",\"params\":{\"text\":\"solo\"},\"id\":7}")

  AssertString(response, ~"{\"jsonrpc\":\"2.0\",\"result\":\"solo\",\"id\":7}", "Non-batch body should dispatch as one message.")
EndProcedureUnit

ProcedureUnit BatchDispatchToConnectionWritesArray()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  BatchPrepare(@dispatcher)
  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_Batch_DispatchToConnection(@dispatcher, @connection, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"tools/echo\",\"params\":{\"text\":\"two\"},\"id\":2}]"), "Batch dispatch should write.")
  AssertString(writer\captured, ~"[{\"jsonrpc\":\"2.0\",\"result\":\"two\",\"id\":2}]", "Writer should capture batch response array.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
