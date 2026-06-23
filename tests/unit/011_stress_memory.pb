EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "stress.pbi"

PureUnitOptions(Thread)

ProcedureUnit RepeatedMalformedMessagesStayBounded()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected index.i
  Protected response.s
  Protected snapshot.JSONRPC_Diagnostics

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  For index = 1 To 50
    response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"broken")
    Assert(FindString(response, ~"\"code\":-32700", 1) > 0, "Malformed input should return parse error.")
  Next

  JSONRPC_Diagnostics_Copy(@connection, @snapshot)
  Assert(snapshot\receivedMessages = 50, "Malformed loop should count all received messages.")
  Assert(snapshot\errors = 50, "Malformed loop should count all errors.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Malformed loop should not create pending state.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit RepeatedTimeoutCleanupRemovesPendingState()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected index.i
  Protected id.q
  Protected deadline.q

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  For index = 1 To 50
    id = JSONRPC_Connection_SendRequest(@connection, "tools/wait", "", 1)
    deadline = JSONRPC_Connection_PendingDeadline(@connection, Str(id))
    JSONRPC_Connection_CleanupTimeouts(@connection, deadline)
  Next

  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Timeout cleanup should remove every pending request.")
  Assert(connection\diagnostics\timeouts = 50, "Timeout diagnostics should count every cleanup.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit RepeatedBatchAndCancellationCleanup()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected index.i
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  For index = 1 To 50
    response = JSONRPC_Batch_Dispatch(@dispatcher, @connection, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"notifications/log\"}]")
    AssertString(response, "", "Notification-only batch should stay response-free.")
    JSONRPC_Cancel_Request(@connection, Str(index))
    Assert(JSONRPC_Cancel_Clear(@connection, Str(index)), "Cancellation should clear.")
  Next

  Assert(connection\diagnostics\batches = 50, "Batch diagnostics should count every batch.")
  Assert(connection\diagnostics\cancellations = 50, "Cancellation diagnostics should count every request.")
  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit StressHelperRunsBasicLoop()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_Stress_RunBasic(@dispatcher, @connection, 10), "Stress helper should complete.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Stress helper should leave no pending requests.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
