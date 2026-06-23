EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "diagnostics.pbi"

PureUnitOptions(Thread)

Procedure.i DiagnosticsOkHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = "true"
  ProcedureReturn #True
EndProcedure

ProcedureUnit DiagnosticsCountSendReceiveAndErrors()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected snapshot.JSONRPC_Diagnostics

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_RegisterRequest(@dispatcher, "tools/ok", @DiagnosticsOkHandler())
  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  JSONRPC_Dispatcher_DispatchToConnection(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/ok\",\"id\":1}")
  JSONRPC_Dispatcher_DispatchToConnection(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/missing\",\"id\":2}")
  JSONRPC_Diagnostics_Copy(@connection, @snapshot)

  Assert(snapshot\receivedMessages = 2, "Two inbound messages should be counted.")
  Assert(snapshot\sentMessages = 2, "Two responses should be sent.")
  Assert(snapshot\errors = 1, "Unknown method should count as one error.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit DiagnosticsCountTimeoutOrphanBatchAndCancel()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected snapshot.JSONRPC_Diagnostics
  Protected id.q
  Protected deadline.q

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  id = JSONRPC_Connection_SendRequest(@connection, "tools/wait", "", 5)
  deadline = JSONRPC_Connection_PendingDeadline(@connection, Str(id))
  JSONRPC_Connection_CleanupTimeouts(@connection, deadline)
  JSONRPC_Connection_MatchResponse(@connection, ~"{\"jsonrpc\":\"2.0\",\"result\":true,\"id\":99}")
  JSONRPC_Batch_Dispatch(@dispatcher, @connection, "[]")
  JSONRPC_Cancel_Request(@connection, "7")
  JSONRPC_Diagnostics_Copy(@connection, @snapshot)

  Assert(snapshot\timeouts = 1, "Timeout should be counted.")
  Assert(snapshot\orphanResponses = 1, "Orphan response should be counted.")
  Assert(snapshot\batches = 1, "Batch should be counted.")
  Assert(snapshot\cancellations = 1, "Cancellation should be counted.")
  Assert(snapshot\errors >= 3, "Timeout, orphan, and empty batch should count as errors.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit DiagnosticsResetClearsCounters()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected snapshot.JSONRPC_Diagnostics

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Connection_SendNotification(@connection, "notifications/log", "")

  JSONRPC_Diagnostics_Reset(@connection)
  JSONRPC_Diagnostics_Copy(@connection, @snapshot)

  Assert(snapshot\sentMessages = 0, "Reset should clear sent messages.")
  AssertString(JSONRPC_Diagnostics_Summary(@connection), ~"{\"receivedMessages\":0,\"sentMessages\":0,\"errors\":0,\"timeouts\":0,\"orphanResponses\":0,\"batches\":0,\"cancellations\":0,\"queuedWrites\":0,\"writeFailures\":0}", "Summary should be compact JSON.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
