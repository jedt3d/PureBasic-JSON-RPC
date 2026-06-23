EnableExplicit

XIncludeFile "../../src/jsonrpc/outbound.pbi"

Define writer.JSONRPC_FakeWriter
Define connection.JSONRPC_Connection
Define requestId.q

JSONRPC_FakeWriter_Init(@writer)

If JSONRPC_Connection_Init(@connection, @writer) = #False
  PrintN("connection init failed")
  End 1
EndIf

requestId = JSONRPC_Connection_SendRequest(@connection, "tools/list", ~"{\"cursor\":\"first\"}")
If requestId <> 1
  PrintN("unexpected request id")
  End 1
EndIf

If JSONRPC_Connection_PendingCount(@connection) <> 1
  PrintN("request was not tracked")
  End 1
EndIf

If JSONRPC_Connection_MatchResponse(@connection, ~"{\"jsonrpc\":\"2.0\",\"result\":{\"tools\":[]},\"id\":1}") = #False
  PrintN("response did not match")
  End 1
EndIf

If JSONRPC_Connection_PendingCount(@connection) <> 0
  PrintN("pending request was not cleared")
  End 1
EndIf

If JSONRPC_Connection_SendNotification(@connection, "notifications/log", ~"{\"message\":\"ready\"}") = #False
  PrintN("notification send failed")
  End 1
EndIf

If JSONRPC_Connection_GetNextId(@connection) <> 2
  PrintN("notification consumed a request id")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("outbound requests scenario: OK")
