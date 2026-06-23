EnableExplicit

XIncludeFile "../../src/jsonrpc/protocol.pbi"

Define result.JSONRPC_ProtocolResult
Define response.s

If JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"method\":\"foobar,\"params\":\"bar\",\"baz]", @result)
  PrintN("invalid JSON passed inspection")
  End 1
EndIf

If result\errorCode <> #JSONRPC_Error_Parse
  PrintN("expected parse error")
  End 1
EndIf

response = JSONRPC_Protocol_BuildErrorResponse(result\errorCode, result\errorMessage, result\idText)
If FindString(response, ~"\"code\":-32700", 1) = 0
  PrintN("parse error response missing code")
  End 1
EndIf

If JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"method\":\"subtract\",\"params\":[42,23],\"id\":1}", @result) = #False
  PrintN("valid request failed inspection")
  End 1
EndIf

If result\messageType <> #JSONRPC_MessageTypeRequest Or result\requiresResponse = #False
  PrintN("valid request was not classified correctly")
  End 1
EndIf

response = JSONRPC_Protocol_BuildMethodNotFoundResponse(result\idText)
If FindString(response, ~"\"code\":-32601", 1) = 0
  PrintN("method-not-found response missing code")
  End 1
EndIf

PrintN("protocol errors scenario: OK")
End 0

