EnableExplicit

XIncludeFile "../../src/jsonrpc/connection.pbi"

Define writer.JSONRPC_FakeWriter
Define connection.JSONRPC_Connection
Define body.s

body = ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}"

JSONRPC_FakeWriter_Init(@writer)

If JSONRPC_Connection_Init(@connection, @writer) = #False
  PrintN("connection init failed: " + JSONRPC_Connection_GetLastErrorMessage(@connection))
  End 1
EndIf

If JSONRPC_Connection_SendBody(@connection, body) = #False
  PrintN("send failed: " + JSONRPC_Connection_GetLastErrorMessage(@connection))
  End 1
EndIf

If writer\captured <> body Or writer\writeCount <> 1
  PrintN("fake writer did not capture outbound body")
  End 1
EndIf

If JSONRPC_Connection_Close(@connection) = #False Or JSONRPC_Connection_Close(@connection) = #False
  PrintN("idempotent close failed")
  End 1
EndIf

If JSONRPC_Connection_SendBody(@connection, body)
  PrintN("closed connection accepted a write")
  End 1
EndIf

PrintN("connection scenario: OK")
End 0

