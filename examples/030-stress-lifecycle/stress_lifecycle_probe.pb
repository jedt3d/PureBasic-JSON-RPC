EnableExplicit

XIncludeFile "../../src/jsonrpc/stress.pbi"

Define dispatcher.JSONRPC_Dispatcher
Define writer.JSONRPC_Writer
Define connection.JSONRPC_Connection

JSONRPC_Dispatcher_Init(@dispatcher)
JSONRPC_Writer_Init(@writer)
JSONRPC_Connection_Init(@connection, @writer)

If JSONRPC_Stress_RunLifecycle(@dispatcher, @connection, 50) = #False
  PrintN("lifecycle stress helper failed")
  End 1
EndIf

If JSONRPC_Connection_PendingCount(@connection) <> 0 Or JSONRPC_Connection_PendingWriteCount(@connection) <> 0
  PrintN("lifecycle stress left pending state")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("stress lifecycle scenario: OK")
End 0
