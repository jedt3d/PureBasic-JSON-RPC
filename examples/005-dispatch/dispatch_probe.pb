EnableExplicit

XIncludeFile "../../src/jsonrpc/dispatch.pbi"

Global ScenarioLogMessage.s

Procedure.i ScenarioEchoHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected textValue

  textValue = GetJSONMember(paramsValue, "text")

  If textValue = 0 Or JSONType(textValue) <> #PB_JSON_String
    *result\ok = #False
    *result\errorCode = #JSONRPC_Error_InvalidParams
    *result\errorMessage = "Invalid params"
    ProcedureReturn #True
  EndIf

  *result\ok = #True
  *result\resultJson = #DQUOTE$ + JSONRPC_Protocol_EscapeString(GetJSONString(textValue)) + #DQUOTE$
  ProcedureReturn #True
EndProcedure

Procedure.i ScenarioLogHandler(paramsValue, *context.JSONRPC_RequestContext)
  Protected messageValue

  ScenarioLogMessage = ""
  messageValue = GetJSONMember(paramsValue, "message")

  If messageValue <> 0 And JSONType(messageValue) = #PB_JSON_String
    ScenarioLogMessage = GetJSONString(messageValue)
  EndIf

  ProcedureReturn #True
EndProcedure

Define dispatcher.JSONRPC_Dispatcher
Define writer.JSONRPC_FakeWriter
Define connection.JSONRPC_Connection
Define response.s

JSONRPC_Dispatcher_Init(@dispatcher)
JSONRPC_FakeWriter_Init(@writer)
JSONRPC_Connection_Init(@connection, @writer)

If JSONRPC_RegisterRequest(@dispatcher, "tools/echo", @ScenarioEchoHandler()) = #False
  PrintN("failed to register request handler")
  End 1
EndIf

If JSONRPC_RegisterNotification(@dispatcher, "notifications/log", @ScenarioLogHandler()) = #False
  PrintN("failed to register notification handler")
  End 1
EndIf

If JSONRPC_Dispatcher_DispatchToConnection(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/echo\",\"params\":{\"text\":\"hello\"},\"id\":1}") = #False
  PrintN("request dispatch failed")
  End 1
EndIf

If writer\captured <> ~"{\"jsonrpc\":\"2.0\",\"result\":\"hello\",\"id\":1}"
  PrintN("unexpected request response")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/log\",\"params\":{\"message\":\"ready\"}}")
If response <> "" Or ScenarioLogMessage <> "ready"
  PrintN("notification dispatch failed")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/missing\",\"id\":2}")
If FindString(response, ~"\"code\":-32601", 1) = 0
  PrintN("missing method did not return method-not-found")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("dispatch scenario: OK")
End 0

