EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "diagnostics.pbi"

PureUnitOptions(Thread)

ProcedureUnit QueueBodyWaitsForExplicitFlush()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_Connection_QueueBody(@connection, "one"), "Queue should accept body.")
  Assert(JSONRPC_Connection_PendingWriteCount(@connection) = 1, "Queued body should wait.")
  Assert(writer\writeCount = 0, "Writer should not be called before flush.")

  Assert(JSONRPC_Connection_FlushWrites(@connection), "Flush should write queued body.")
  Assert(JSONRPC_Connection_PendingWriteCount(@connection) = 0, "Flush should drain queue.")
  AssertString(writer\captured, "one", "Writer should receive queued body.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit SendBodyUsesQueueAndFlushesSynchronously()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected snapshot.JSONRPC_Diagnostics

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_Connection_SendBody(@connection, "body"), "SendBody should queue and flush.")
  JSONRPC_Diagnostics_Copy(@connection, @snapshot)

  Assert(snapshot\queuedWrites = 1, "SendBody should count a queued write.")
  Assert(snapshot\sentMessages = 1, "SendBody should count a sent message.")
  Assert(JSONRPC_Connection_PendingWriteCount(@connection) = 0, "SendBody should leave queue empty after success.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit FailedWriteIsDroppedAndCounted()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected snapshot.JSONRPC_Diagnostics

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Writer_FailNextWrite(@writer)

  Assert(JSONRPC_Connection_SendBody(@connection, "fail") = #False, "Failed writer should fail SendBody.")
  JSONRPC_Diagnostics_Copy(@connection, @snapshot)

  Assert(JSONRPC_Connection_GetLastErrorCode(@connection) = #JSONRPC_Connection_ErrorWriteFailed, "Connection should expose write failure.")
  Assert(snapshot\writeFailures = 1, "Failed write should be counted.")
  Assert(JSONRPC_Connection_PendingWriteCount(@connection) = 0, "Failed write should be dropped from queue.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit CloseClearsQueuedWritesAndRejectsNewWrites()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Connection_QueueBody(@connection, "pending")

  Assert(JSONRPC_Connection_PendingWriteCount(@connection) = 1, "Precondition: one queued write.")
  JSONRPC_Connection_Close(@connection)

  Assert(JSONRPC_Connection_PendingWriteCount(@connection) = 0, "Close should clear queued writes.")
  Assert(JSONRPC_Connection_QueueBody(@connection, "after-close") = #False, "Closed connection should reject queued writes.")
  Assert(JSONRPC_Connection_GetLastErrorCode(@connection) = #JSONRPC_Connection_ErrorClosed, "Closed queue should expose closed error.")
EndProcedureUnit
