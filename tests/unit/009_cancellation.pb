EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "cancel.pbi"

PureUnitOptions(Thread)

ProcedureUnit CancellationNotificationMarksId()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_Cancel_ProcessNotification(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"$/cancelRequest\",\"params\":{\"id\":1}}"), "Cancellation notification should be processed.")
  Assert(JSONRPC_Cancel_IsRequested(@connection, "1"), "Cancellation should be queryable by id.")
  AssertString(JSONRPC_Cancel_GetLastCancelledIdText(@connection), "1", "Last cancelled id should be recorded.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit StringCancellationIdIsPreserved()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_Cancel_ProcessNotification(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"$/cancelRequest\",\"params\":{\"id\":\"abc\"}}"), "String id should be accepted.")
  Assert(JSONRPC_Cancel_IsRequested(@connection, #DQUOTE$ + "abc" + #DQUOTE$), "String id should be stored as JSON id text.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit CancellationCanBeCleared()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Cancel_Request(@connection, "7")

  Assert(JSONRPC_Cancel_Clear(@connection, "7"), "Cancellation should clear.")
  Assert(JSONRPC_Cancel_IsRequested(@connection, "7") = #False, "Cleared cancellation should not be requested.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit InvalidCancellationNotificationIsIgnored()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_Cancel_ProcessNotification(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"$/cancelRequest\",\"params\":{}}") = #False, "Missing id should be ignored.")
  Assert(JSONRPC_Cancel_ProcessNotification(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"other\",\"params\":{\"id\":1}}") = #False, "Other notification should be ignored.")
  Assert(JSONRPC_Cancel_GetLastCancelledIdText(@connection) = "", "No cancellation should be recorded.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit CloseClearsCancellationTokens()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Cancel_Request(@connection, "3")

  Assert(JSONRPC_Cancel_IsRequested(@connection, "3"), "Cancellation should be present before close.")
  JSONRPC_Connection_Close(@connection)
  Assert(JSONRPC_Cancel_IsRequested(@connection, "3") = #False, "Close should clear cancellations.")
EndProcedureUnit
