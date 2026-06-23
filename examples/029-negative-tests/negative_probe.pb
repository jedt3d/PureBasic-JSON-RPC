EnableExplicit

XIncludeFile "../../src/jsonrpc/jsonrpc.pbi"

Define result.JSONRPC_ProtocolResult
Define stdio.JSONRPC_StdioCodecState
Define message.JSONRPC_Message
Define dispatcher.JSONRPC_Dispatcher
Define writer.JSONRPC_Writer
Define connection.JSONRPC_Connection
Define response.s

If JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"method\":\"echo\",\"id\":{}}", @result)
  PrintN("invalid object id was accepted")
  End 1
EndIf

If result\errorCode <> #JSONRPC_Error_InvalidRequest Or result\idText <> "null"
  PrintN("invalid object id did not produce invalid request with null id")
  End 1
EndIf

JSONRPC_Dispatcher_Init(@dispatcher)
JSONRPC_Writer_Init(@writer)
JSONRPC_Connection_Init(@connection, @writer)

response = JSONRPC_Batch_Dispatch(@dispatcher, @connection, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"missing\",\"id\":[]}]")
If FindString(response, ~"\"code\":-32600", 1) = 0
  PrintN("invalid batch id did not produce invalid request")
  End 1
EndIf

JSONRPC_Codec_StdioInit(@stdio, 8)
JSONRPC_Codec_StdioPushBytes(@stdio, "123456789")
If JSONRPC_Codec_StdioNextMessage(@stdio, @message) Or JSONRPC_Codec_StdioGetErrorCode(@stdio) <> #JSONRPC_Codec_ErrorMessageTooLarge
  PrintN("oversized stdio message was not rejected")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("negative tests scenario: OK")
End 0
