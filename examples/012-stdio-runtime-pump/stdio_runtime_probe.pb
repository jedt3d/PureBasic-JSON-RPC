EnableExplicit

XIncludeFile "../../src/jsonrpc/stdio_runtime.pbi"

Procedure.i ScenarioPing(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = #DQUOTE$ + "pong" + #DQUOTE$
  ProcedureReturn #True
EndProcedure

Define pump.JSONRPC_StdioRuntime
Define dispatcher.JSONRPC_Dispatcher
Define writer.JSONRPC_FakeWriter
Define connection.JSONRPC_Connection

JSONRPC_StdioRuntime_Init(@pump)
JSONRPC_Dispatcher_Init(@dispatcher)
JSONRPC_RegisterRequest(@dispatcher, "tools/ping", @ScenarioPing())
JSONRPC_FakeWriter_Init(@writer)
JSONRPC_Connection_Init(@connection, @writer)

If JSONRPC_StdioRuntime_Feed(@pump, @dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/ping\",\"id\":1}\n") = #False
  PrintN("runtime feed failed")
  End 1
EndIf

If writer\captured <> ~"{\"jsonrpc\":\"2.0\",\"result\":\"pong\",\"id\":1}"
  PrintN("runtime response mismatch")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("stdio runtime scenario: OK")
