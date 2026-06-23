EnableExplicit

XIncludeFile "../../src/jsonrpc/codec.pbi"

Define state.JSONRPC_StdioCodecState
Define first.JSONRPC_Message
Define second.JSONRPC_Message
Define firstBody.s
Define secondBody.s
Define encoded.s

firstBody = ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}"
secondBody = ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/log\",\"params\":{\"message\":\"ready\"}}"

encoded = JSONRPC_Codec_StdioBuildMessage(firstBody)
encoded + JSONRPC_Codec_StdioBuildMessage(secondBody)

JSONRPC_Codec_StdioInit(@state)
JSONRPC_Codec_StdioPushBytes(@state, Left(encoded, 18))

If JSONRPC_Codec_StdioNextMessage(@state, @first)
  PrintN("unexpected complete message from partial stdio chunk")
  End 1
EndIf

JSONRPC_Codec_StdioPushBytes(@state, Mid(encoded, 19))

If JSONRPC_Codec_StdioNextMessage(@state, @first) = #False
  PrintN("missing first stdio message")
  End 1
EndIf

If JSONRPC_Codec_StdioNextMessage(@state, @second) = #False
  PrintN("missing second stdio message")
  End 1
EndIf

If first\body <> firstBody Or second\body <> secondBody
  PrintN("stdio message bodies did not match")
  End 1
EndIf

If JSONRPC_Codec_StdioHasError(@state)
  PrintN("stdio codec error: " + JSONRPC_Codec_StdioGetErrorMessage(@state))
  End 1
EndIf

PrintN("stdio codec scenario: OK")
End 0

