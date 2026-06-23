EnableExplicit

XIncludeFile "../../src/jsonrpc/diagnostics.pbi"

Define writer.JSONRPC_FakeWriter
Define connection.JSONRPC_Connection
Define summary.s

JSONRPC_FakeWriter_Init(@writer)

If JSONRPC_Connection_Init(@connection, @writer) = #False
  PrintN("connection init failed")
  End 1
EndIf

If JSONRPC_Connection_SendNotification(@connection, "notifications/log", "") = #False
  PrintN("send notification failed")
  End 1
EndIf

summary = JSONRPC_Diagnostics_Summary(@connection)
If FindString(summary, ~"\"sentMessages\":1", 1) = 0
  PrintN("sent counter missing")
  End 1
EndIf

JSONRPC_Diagnostics_Reset(@connection)
If JSONRPC_Diagnostics_Summary(@connection) <> ~"{\"receivedMessages\":0,\"sentMessages\":0,\"errors\":0,\"timeouts\":0,\"orphanResponses\":0,\"batches\":0,\"cancellations\":0}"
  PrintN("reset failed")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("diagnostics scenario: OK")
