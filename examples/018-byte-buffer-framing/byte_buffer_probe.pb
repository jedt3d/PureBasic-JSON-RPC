EnableExplicit

XIncludeFile "../../src/jsonrpc/codec.pbi"

Define buffer.JSONRPC_ByteBuffer
Define state.JSONRPC_FrameState
Define message.JSONRPC_Message
Define framed.s
Define text.s

JSONRPC_ByteBuffer_Init(@buffer, 4)
text = "a" + Chr($E4)

If JSONRPC_ByteBuffer_AppendUtf8(@buffer, text) = #False
  PrintN("byte buffer rejected valid UTF-8 text")
  End 1
EndIf

If JSONRPC_ByteBuffer_Length(@buffer) <> 3
  PrintN("byte buffer length did not count UTF-8 bytes")
  End 1
EndIf

JSONRPC_Framing_Init(@state)
framed = JSONRPC_Framing_BuildFrame(~"{\"jsonrpc\":\"2.0\",\"result\":\"ok\",\"id\":1}")
JSONRPC_Framing_PushBytes(@state, framed)

If JSONRPC_Framing_NextMessage(@state, @message) = #False
  PrintN("framing byte buffer did not return message")
  End 1
EndIf

If FindString(message\body, "ok", 1) = 0
  PrintN("framing byte buffer returned unexpected body")
  End 1
EndIf

PrintN("byte buffer framing scenario: OK")
End 0
