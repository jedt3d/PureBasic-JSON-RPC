EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "jsonrpc.pbi"

PureUnitOptions(Thread)

ProcedureUnit InvalidObjectIdReturnsInvalidRequest()
  Protected result.JSONRPC_ProtocolResult
  Protected response.s

  Assert(JSONRPC_Protocol_Inspect(~"{\"jsonrpc\":\"2.0\",\"method\":\"echo\",\"id\":{}}", @result) = #False, "Object id should be invalid.")
  Assert(result\errorCode = #JSONRPC_Error_InvalidRequest, "Invalid id should produce invalid request.")
  AssertString(result\idText, "null", "Invalid id should not be echoed.")

  response = JSONRPC_Protocol_BuildErrorResponse(result\errorCode, result\errorMessage, result\idText)
  Assert(FindString(response, ~"\"code\":-32600", 1) > 0, "Invalid id response should contain -32600.")
  Assert(FindString(response, ~"\"id\":null", 1) > 0, "Invalid id response should use null id.")
EndProcedureUnit

ProcedureUnit InvalidIdDoesNotBecomeNotification()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"missing\",\"id\":[]}")

  Assert(FindString(response, ~"\"code\":-32600", 1) > 0, "Invalid id should produce an error response.")
  Assert(FindString(response, ~"\"code\":-32601", 1) = 0, "Invalid id should not reach method dispatch.")
  Assert(connection\diagnostics\errors > 0, "Invalid id should increment error diagnostics.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit InvalidBatchItemReturnsErrorArray()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  response = JSONRPC_Batch_Dispatch(@dispatcher, @connection, ~"[1,{\"jsonrpc\":\"2.0\",\"method\":\"missing\",\"id\":{}}]")

  Assert(Left(response, 1) = "[", "Invalid batch responses should be wrapped in an array.")
  Assert(FindString(response, ~"\"code\":-32600", 1) > 0, "Invalid batch item should report invalid request.")
  Assert(FindString(response, ~"\"id\":null", 1) > 0, "Invalid batch item should use null id when id is invalid.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit OversizedFramingAndStdioMessagesAreRejected()
  Protected frame.JSONRPC_FrameState
  Protected stdio.JSONRPC_StdioCodecState
  Protected message.JSONRPC_Message

  JSONRPC_Framing_Init(@frame, 16, 8)
  JSONRPC_Framing_PushBytes(@frame, "Content-Length: 100" + #CRLF$ + #CRLF$)
  Assert(JSONRPC_Framing_NextMessage(@frame, @message) = #False, "Oversized framed body should not produce a message.")
  Assert(JSONRPC_Framing_HasError(@frame), "Oversized framed body should set an error.")
  Assert(JSONRPC_Framing_GetErrorCode(@frame) = #JSONRPC_Framing_ErrorHeaderTooLarge Or JSONRPC_Framing_GetErrorCode(@frame) = #JSONRPC_Framing_ErrorBodyTooLarge, "Framing should reject oversized input.")

  JSONRPC_Codec_StdioInit(@stdio, 8)
  JSONRPC_Codec_StdioPushBytes(@stdio, "123456789")
  Assert(JSONRPC_Codec_StdioNextMessage(@stdio, @message) = #False, "Oversized stdio line should not produce a message.")
  Assert(JSONRPC_Codec_StdioHasError(@stdio), "Oversized stdio line should set an error.")
  Assert(JSONRPC_Codec_StdioGetErrorCode(@stdio) = #JSONRPC_Codec_ErrorMessageTooLarge, "Stdio codec should reject oversized input.")
EndProcedureUnit

ProcedureUnit OrphanResponseDoesNotRemovePendingRequest()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Connection_SendRequest(@connection, "echo", ~"{\"text\":\"ok\"}")

  Assert(JSONRPC_Connection_MatchResponse(@connection, ~"{\"jsonrpc\":\"2.0\",\"result\":\"late\",\"id\":99}") = #False, "Orphan response should be rejected.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 1, "Orphan response should not remove the real pending request.")
  Assert(connection\diagnostics\orphanResponses = 1, "Orphan response should be counted.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit RepeatedMalformedDispatchStaysBounded()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected index.i
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  For index = 1 To 50
    response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"broken")
    Assert(FindString(response, ~"\"code\":-32700", 1) > 0, "Malformed JSON should return parse error.")
  Next

  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Malformed dispatch loop should not create pending requests.")
  Assert(connection\diagnostics\errors = 50, "Malformed dispatch loop should count each error.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
