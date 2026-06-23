EnableExplicit

XIncludeFile "../../src/jsonrpc/outbound.pbi"
XIncludeFile "../../src/jsonrpc/dispatch.pbi"

Define writer.JSONRPC_Writer
Define connection.JSONRPC_Connection
Define dispatcher.JSONRPC_Dispatcher

JSONRPC_Writer_Init(@writer)
JSONRPC_Connection_Init(@connection, @writer)
JSONRPC_Dispatcher_Init(@dispatcher)

JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/missing\"}")

If JSONRPC_Connection_GetLastEventCode(@connection) <> #JSONRPC_Connection_EventUnhandledNotification
  PrintN("unhandled notification event was not recorded")
  End 1
EndIf

JSONRPC_Connection_MatchResponse(@connection, ~"{\"jsonrpc\":\"2.0\",\"result\":true,\"id\":42}")

If JSONRPC_Connection_GetLastEventCode(@connection) <> #JSONRPC_Connection_EventOrphanResponse
  PrintN("orphan response event was not recorded")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

If JSONRPC_Connection_GetLastEventCode(@connection) <> #JSONRPC_Connection_EventClose
  PrintN("close event was not recorded")
  End 1
EndIf

PrintN("connection events scenario: OK")
End 0
