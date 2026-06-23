EnableExplicit

XIncludeFile "../../src/jsonrpc/dispatch.pbi"

Procedure.i ProbeStarRequest(method.s, paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = #DQUOTE$ + JSONRPC_Protocol_EscapeString(method) + #DQUOTE$
  ProcedureReturn #True
EndProcedure

Define dispatcher.JSONRPC_Dispatcher
Define response.s

JSONRPC_Dispatcher_Init(@dispatcher)

If JSONRPC_RegisterStarRequest(@dispatcher, @ProbeStarRequest()) = #False
  PrintN("star request registration failed")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/future\",\"id\":1}")

If FindString(response, ~"\"result\":\"tools/future\"", 1) = 0
  PrintN("star request handler did not produce expected response")
  End 1
EndIf

PrintN("handler registration lifecycle scenario: OK")
End 0
