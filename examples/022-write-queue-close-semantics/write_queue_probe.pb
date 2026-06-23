EnableExplicit

XIncludeFile "../../src/jsonrpc/diagnostics.pbi"

Define writer.JSONRPC_Writer
Define connection.JSONRPC_Connection
Define snapshot.JSONRPC_Diagnostics

JSONRPC_Writer_Init(@writer)
JSONRPC_Connection_Init(@connection, @writer)

If JSONRPC_Connection_QueueBody(@connection, "queued") = #False
  PrintN("queue body failed")
  End 1
EndIf

If writer\writeCount <> 0 Or JSONRPC_Connection_PendingWriteCount(@connection) <> 1
  PrintN("queue flushed before explicit flush")
  End 1
EndIf

If JSONRPC_Connection_FlushWrites(@connection) = #False
  PrintN("flush failed")
  End 1
EndIf

JSONRPC_Diagnostics_Copy(@connection, @snapshot)

If snapshot\queuedWrites <> 1 Or snapshot\sentMessages <> 1
  PrintN("queue diagnostics did not update")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("write queue close semantics scenario: OK")
End 0
