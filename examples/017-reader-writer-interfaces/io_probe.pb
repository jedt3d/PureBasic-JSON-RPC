EnableExplicit

XIncludeFile "../../src/jsonrpc/connection.pbi"

Define writer.JSONRPC_Writer
Define reader.JSONRPC_Reader
Define connection.JSONRPC_Connection

JSONRPC_Writer_Init(@writer)
JSONRPC_Reader_Init(@reader)

If JSONRPC_Connection_Init(@connection, @writer) = #False
  PrintN("connection init failed: " + JSONRPC_Connection_GetLastErrorMessage(@connection))
  End 1
EndIf

If JSONRPC_Connection_SendBody(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"probe\"}") = #False
  PrintN("generic writer send failed")
  End 1
EndIf

JSONRPC_Reader_PushBytes(@reader, "chunk-a")
JSONRPC_Reader_PushBytes(@reader, "-chunk-b")

If JSONRPC_Reader_ReadAvailable(@reader) <> "chunk-a-chunk-b"
  PrintN("generic reader did not preserve pushed data")
  End 1
EndIf

If writer\writeCount <> 1 Or FindString(writer\captured, "probe", 1) = 0
  PrintN("generic writer did not capture connection output")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

If JSONRPC_Writer_IsClosed(@writer) = #False
  PrintN("connection close did not close generic writer")
  End 1
EndIf

PrintN("reader writer interfaces scenario: OK")
End 0
