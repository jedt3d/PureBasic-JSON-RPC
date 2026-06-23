EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "protocol.pbi"

PureUnitOptions(Thread)

ProcedureUnit InvalidJsonReturnsParseError()
  Protected result.JSONRPC_ProtocolResult
  Protected response.s

  Assert(JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"method\":\"broken", @result) = #False, "Invalid JSON should fail inspection.")
  Assert(result\errorCode = #JSONRPC_Error_Parse, "Invalid JSON should produce parse error.")
  AssertString(result\idText, "null", "Parse error id should be null.")

  response = JSONRPC_Protocol_BuildErrorResponse(result\errorCode, result\errorMessage, result\idText)
  Assert(FindString(response, ~"\"code\":-32700", 1) > 0, "Parse error response should contain -32700.")
EndProcedureUnit

ProcedureUnit InvalidRequestObjectReturnsInvalidRequest()
  Protected result.JSONRPC_ProtocolResult

  Assert(JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"method\":1,\"params\":\"bar\"}", @result) = #False, "Invalid request object should fail.")
  Assert(result\errorCode = #JSONRPC_Error_InvalidRequest, "Invalid request should use -32600.")
  AssertString(result\idText, "null", "Invalid request without id should use null id.")
EndProcedureUnit

ProcedureUnit MissingMethodReturnsInvalidRequest()
  Protected result.JSONRPC_ProtocolResult

  Assert(JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"id\":1}", @result) = #False, "Object without method/result/error should fail.")
  Assert(result\errorCode = #JSONRPC_Error_InvalidRequest, "Missing method should be invalid request.")
  AssertString(result\idText, "1", "Detectable id should be preserved.")
EndProcedureUnit

ProcedureUnit NotificationProducesNoResponse()
  Protected result.JSONRPC_ProtocolResult

  Assert(JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"method\":\"notify_hello\",\"params\":[7]}", @result), "Valid notification should pass.")
  Assert(result\messageType = #JSONRPC_MessageTypeNotification, "Notification should be classified.")
  Assert(result\requiresResponse = #False, "Notification should not require a response.")
EndProcedureUnit

ProcedureUnit ValidRequestPreservesIdAndMethod()
  Protected result.JSONRPC_ProtocolResult

  Assert(JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"method\":\"subtract\",\"params\":[42,23],\"id\":1}", @result), "Valid request should pass.")
  Assert(result\messageType = #JSONRPC_MessageTypeRequest, "Request should be classified.")
  Assert(result\requiresResponse, "Request should require a response.")
  AssertString(result\method, "subtract", "Method should be captured.")
  AssertString(result\idText, "1", "Numeric id should be preserved.")
EndProcedureUnit

ProcedureUnit ResponseRequiresExactlyOneResultOrError()
  Protected result.JSONRPC_ProtocolResult

  Assert(JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"result\":19,\"error\":{\"code\":-1,\"message\":\"bad\"},\"id\":1}", @result) = #False, "Response cannot include result and error.")
  Assert(result\errorCode = #JSONRPC_Error_InvalidRequest, "Invalid response shape should use invalid request.")

  Assert(JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"result\":19,\"id\":1}", @result), "Response with result should pass.")
  Assert(result\messageType = #JSONRPC_MessageTypeResponse, "Response should be classified.")
  Assert(result\requiresResponse = #False, "Response should not require another response.")
EndProcedureUnit

ProcedureUnit InvalidParamsShapeReturnsInvalidParams()
  Protected result.JSONRPC_ProtocolResult

  Assert(JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"method\":\"subtract\",\"params\":\"bad\",\"id\":1}", @result) = #False, "Params must be structured.")
  Assert(result\errorCode = #JSONRPC_Error_InvalidParams, "Invalid params shape should use -32602.")
  AssertString(result\idText, "1", "Invalid params should preserve request id.")
EndProcedureUnit

ProcedureUnit BuildResultAndMethodNotFoundResponses()
  Protected resultResponse.s
  Protected errorResponse.s

  resultResponse = JSONRPC_Protocol_BuildResultResponse("19", "1")
  errorResponse = JSONRPC_Protocol_BuildMethodNotFoundResponse(#DQUOTE$ + "abc" + #DQUOTE$)

  AssertString(resultResponse, ~"{\"jsonrpc\":\"2.0\",\"result\":19,\"id\":1}", "Result response should match compact JSON.")
  Assert(FindString(errorResponse, ~"\"code\":-32601", 1) > 0, "Method-not-found response should contain -32601.")
  Assert(FindString(errorResponse, ~"\"id\":\"abc\"", 1) > 0, "String id should be preserved.")
EndProcedureUnit

