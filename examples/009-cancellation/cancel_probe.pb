EnableExplicit

XIncludeFile "../../src/jsonrpc/cancel.pbi"

Define writer.JSONRPC_FakeWriter
Define connection.JSONRPC_Connection

JSONRPC_FakeWriter_Init(@writer)

If JSONRPC_Connection_Init(@connection, @writer) = #False
  PrintN("connection init failed")
  End 1
EndIf

If JSONRPC_Cancel_ProcessNotification(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"$/cancelRequest\",\"params\":{\"id\":42}}") = #False
  PrintN("cancel notification failed")
  End 1
EndIf

If JSONRPC_Cancel_IsRequested(@connection, "42") = #False
  PrintN("cancel token missing")
  End 1
EndIf

If JSONRPC_Cancel_Clear(@connection, "42") = #False
  PrintN("cancel clear failed")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("cancellation scenario: OK")
