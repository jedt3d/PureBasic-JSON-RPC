EnableExplicit

XIncludeFile "../../src/jsonrpc/batch.pbi"

Procedure.i ScenarioEcho(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = #DQUOTE$ + "ok" + #DQUOTE$
  ProcedureReturn #True
EndProcedure

Define dispatcher.JSONRPC_Dispatcher
Define response.s

JSONRPC_Dispatcher_Init(@dispatcher)
JSONRPC_RegisterRequest(@dispatcher, "tools/echo", @ScenarioEcho())

response = JSONRPC_Batch_Dispatch(@dispatcher, 0, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"tools/echo\",\"id\":1},{\"jsonrpc\":\"2.0\",\"method\":\"notifications/log\"}]")

If response <> ~"[{\"jsonrpc\":\"2.0\",\"result\":\"ok\",\"id\":1}]"
  PrintN("batch response mismatch")
  End 1
EndIf

If JSONRPC_Batch_Dispatch(@dispatcher, 0, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"notifications/log\"}]") <> ""
  PrintN("notification-only batch produced response")
  End 1
EndIf

PrintN("batch handling scenario: OK")
