EnableExplicit

XIncludeFile "../../src/jsonrpc/cancel.pbi"

Global ProbeSawCancellation.i

Procedure.i ProbeHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  ProbeSawCancellation = JSONRPC_RequestContext_IsCancellationRequested(*context)
  *result\ok = #True
  *result\resultJson = ~"{\"ok\":true}"
  ProcedureReturn #True
EndProcedure

Define dispatcher.JSONRPC_Dispatcher
Define writer.JSONRPC_Writer
Define connection.JSONRPC_Connection

JSONRPC_Dispatcher_Init(@dispatcher)
JSONRPC_RegisterRequest(@dispatcher, "work/run", @ProbeHandler())
JSONRPC_Writer_Init(@writer)
JSONRPC_Connection_Init(@connection, @writer)

JSONRPC_Cancel_Request(@connection, "1")
JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"work/run\",\"id\":1}")

If ProbeSawCancellation = #False
  PrintN("handler did not see cancellation")
  End 1
EndIf

If JSONRPC_Cancel_IsRequested(@connection, "1")
  PrintN("cancellation was not cleared after dispatch")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("handler cancellation tokens scenario: OK")
End 0
