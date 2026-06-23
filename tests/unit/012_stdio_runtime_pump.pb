EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "stdio_runtime.pbi"

PureUnitOptions(Thread)

Procedure.i RuntimeEchoHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = #DQUOTE$ + "pong" + #DQUOTE$
  ProcedureReturn #True
EndProcedure

Procedure RuntimePrepare(*pump.JSONRPC_StdioRuntime, *dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, *writer.JSONRPC_FakeWriter)
  JSONRPC_StdioRuntime_Init(*pump)
  JSONRPC_Dispatcher_Init(*dispatcher)
  JSONRPC_RegisterRequest(*dispatcher, "tools/ping", @RuntimeEchoHandler())
  JSONRPC_FakeWriter_Init(*writer)
  JSONRPC_Connection_Init(*connection, *writer)
EndProcedure

ProcedureUnit RuntimeDispatchesNewlineRequest()
  Protected pump.JSONRPC_StdioRuntime
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  RuntimePrepare(@pump, @dispatcher, @connection, @writer)

  Assert(JSONRPC_StdioRuntime_Feed(@pump, @dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/ping\",\"id\":1}\n"), "Runtime feed should process request.")
  AssertString(writer\captured, ~"{\"jsonrpc\":\"2.0\",\"result\":\"pong\",\"id\":1}", "Runtime should write response body.")
  Assert(pump\processedMessages = 1, "Runtime should count processed message.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit RuntimeWaitsForPartialLine()
  Protected pump.JSONRPC_StdioRuntime
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  RuntimePrepare(@pump, @dispatcher, @connection, @writer)

  Assert(JSONRPC_StdioRuntime_Feed(@pump, @dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\""), "Partial line should wait.")
  Assert(writer\writeCount = 0, "Partial line should not write.")
  Assert(JSONRPC_StdioRuntime_Feed(@pump, @dispatcher, @connection, ~",\"method\":\"tools/ping\",\"id\":2}\n"), "Completing line should process.")
  Assert(writer\writeCount = 1, "Completed line should write once.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit RuntimeMatchesResponseToPending()
  Protected pump.JSONRPC_StdioRuntime
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  RuntimePrepare(@pump, @dispatcher, @connection, @writer)
  JSONRPC_Connection_SendRequest(@connection, "tools/ping", "")

  Assert(JSONRPC_StdioRuntime_Feed(@pump, @dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"result\":\"ok\",\"id\":1}\n"), "Runtime should match response.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Matched response should clear pending request.")
  AssertString(JSONRPC_Connection_GetLastMatchedIdText(@connection), "1", "Matched id should be recorded.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit RuntimeProcessesBatchAndCancellation()
  Protected pump.JSONRPC_StdioRuntime
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  RuntimePrepare(@pump, @dispatcher, @connection, @writer)

  Assert(JSONRPC_StdioRuntime_Feed(@pump, @dispatcher, @connection, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"tools/ping\",\"id\":3}]\n"), "Runtime should process batch.")
  AssertString(writer\captured, ~"[{\"jsonrpc\":\"2.0\",\"result\":\"pong\",\"id\":3}]", "Batch response should be written.")
  Assert(JSONRPC_StdioRuntime_Feed(@pump, @dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"$/cancelRequest\",\"params\":{\"id\":3}}\n"), "Runtime should process cancellation notification.")
  Assert(JSONRPC_Cancel_IsRequested(@connection, "3"), "Cancellation should be recorded.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
