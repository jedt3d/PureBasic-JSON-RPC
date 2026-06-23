EnableExplicit

XIncludeFile "../../src/jsonrpc/stress.pbi"

Define dispatcher.JSONRPC_Dispatcher
Define writer.JSONRPC_FakeWriter
Define connection.JSONRPC_Connection

JSONRPC_Dispatcher_Init(@dispatcher)
JSONRPC_FakeWriter_Init(@writer)

If JSONRPC_Connection_Init(@connection, @writer) = #False
  PrintN("connection init failed")
  End 1
EndIf

If JSONRPC_Stress_RunBasic(@dispatcher, @connection, 25) = #False
  PrintN("stress helper failed")
  End 1
EndIf

If JSONRPC_Connection_PendingCount(@connection) <> 0
  PrintN("pending state leaked")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("stress memory scenario: OK")
