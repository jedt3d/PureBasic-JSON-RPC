EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "stress.pbi"

PureUnitOptions(Thread)

ProcedureUnit LifecycleStressHelperCleansState()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_Stress_RunLifecycle(@dispatcher, @connection, 75), "Lifecycle stress helper should complete.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Lifecycle stress should leave no pending requests.")
  Assert(JSONRPC_Connection_PendingWriteCount(@connection) = 0, "Lifecycle stress should leave no queued writes.")
  Assert(JSONRPC_Trace_GetCaptured(@connection) = "", "Lifecycle stress should clear trace capture each loop.")
  Assert(connection\diagnostics\timeouts = 75, "Lifecycle stress should count timeout cleanup.")
  Assert(connection\diagnostics\batches = 75, "Lifecycle stress should count batch dispatch.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit RepeatedCreateCloseCyclesAreClean()
  Protected index.i
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  For index = 1 To 50
    JSONRPC_Writer_Init(@writer)
    Assert(JSONRPC_Connection_Init(@connection, @writer), "Connection should initialize in repeated close loop.")
    Assert(JSONRPC_Connection_SendBody(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"close-probe\"}"), "Connection should write before close.")
    Assert(JSONRPC_Connection_Close(@connection), "Connection should close cleanly.")
    Assert(JSONRPC_Connection_IsClosed(@connection), "Connection should be closed.")
    Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Close should leave no pending requests.")
    Assert(JSONRPC_Connection_PendingWriteCount(@connection) = 0, "Close should leave no queued writes.")
  Next
EndProcedureUnit

ProcedureUnit RepeatedWriteFailuresDropQueuedBodies()
  Protected index.i
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  For index = 1 To 25
    JSONRPC_Writer_FailNextWrite(@writer)
    Assert(JSONRPC_Connection_SendBody(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"fail\",\"id\":" + Str(index) + "}") = #False, "Failed write should be reported.")
    Assert(JSONRPC_Connection_PendingWriteCount(@connection) = 0, "Failed write should drop the queued body.")
  Next

  Assert(connection\diagnostics\writeFailures = 25, "Each failed write should be counted.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
