EnableExplicit

XIncludeFile "../../src/jsonrpc/framing.pbi"

Define state.JSONRPC_FrameState
Define first.JSONRPC_Message
Define second.JSONRPC_Message
Define stream.s

stream = JSONRPC_Framing_BuildFrame(~"{\"jsonrpc\":\"2.0\",\"method\":\"alpha\"}")
stream + JSONRPC_Framing_BuildFrame(~"{\"jsonrpc\":\"2.0\",\"method\":\"beta\"}")

JSONRPC_Framing_Init(@state)
JSONRPC_Framing_PushBytes(@state, Left(stream, 20))

If JSONRPC_Framing_NextMessage(@state, @first)
  PrintN("unexpected complete message from partial stream")
  End 1
EndIf

JSONRPC_Framing_PushBytes(@state, Mid(stream, 21))

If JSONRPC_Framing_NextMessage(@state, @first) = #False
  PrintN("missing first framed message")
  End 1
EndIf

If JSONRPC_Framing_NextMessage(@state, @second) = #False
  PrintN("missing second framed message")
  End 1
EndIf

If FindString(first\body, "alpha", 1) = 0 Or FindString(second\body, "beta", 1) = 0
  PrintN("framed message bodies did not match")
  End 1
EndIf

If JSONRPC_Framing_HasError(@state)
  PrintN("framing error: " + JSONRPC_Framing_GetErrorMessage(@state))
  End 1
EndIf

PrintN("framing scenario: OK")
End 0
