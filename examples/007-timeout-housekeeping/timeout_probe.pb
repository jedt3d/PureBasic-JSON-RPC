EnableExplicit

XIncludeFile "../../src/jsonrpc/outbound.pbi"

Define writer.JSONRPC_FakeWriter
Define connection.JSONRPC_Connection
Define requestId.q
Define deadline.q

JSONRPC_FakeWriter_Init(@writer)

If JSONRPC_Connection_Init(@connection, @writer) = #False
  PrintN("connection init failed")
  End 1
EndIf

requestId = JSONRPC_Connection_SendRequest(@connection, "tools/list", "", 10)
If requestId <> 1
  PrintN("request send failed")
  End 1
EndIf

deadline = JSONRPC_Connection_PendingDeadline(@connection, Str(requestId))
If JSONRPC_Connection_CleanupTimeouts(@connection, deadline) <> 1
  PrintN("timeout cleanup failed")
  End 1
EndIf

If JSONRPC_Connection_PendingCount(@connection) <> 0
  PrintN("pending request was not removed")
  End 1
EndIf

If JSONRPC_Connection_GetLastErrorCode(@connection) <> #JSONRPC_Connection_ErrorTimeout
  PrintN("timeout error was not recorded")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("timeout housekeeping scenario: OK")
