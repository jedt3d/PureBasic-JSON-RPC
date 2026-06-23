EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "framing.pbi"

PureUnitOptions(Thread)

ProcedureUnit BuildFrameUsesUtf8ByteLength()
  Protected body.s
  Protected frame.s

  body = "hello " + Chr($E4)
  frame = JSONRPC_Framing_BuildFrame(body)

  Assert(FindString(frame, "Content-Length: 8" + #CRLF$ + #CRLF$, 1) = 1, "Frame must use UTF-8 byte length.")
EndProcedureUnit

ProcedureUnit ReaderWaitsForPartialHeader()
  Protected state.JSONRPC_FrameState
  Protected message.JSONRPC_Message

  JSONRPC_Framing_Init(@state)
  JSONRPC_Framing_PushBytes(@state, "Content-Len")

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #False, "Partial header must not produce a message.")
  Assert(JSONRPC_Framing_HasError(@state) = #False, "Partial header should be a waiting state, not an error.")
EndProcedureUnit

ProcedureUnit ReaderExtractsMessageAcrossChunks()
  Protected state.JSONRPC_FrameState
  Protected message.JSONRPC_Message

  JSONRPC_Framing_Init(@state)
  JSONRPC_Framing_PushBytes(@state, "Content-Length: 5" + #CRLF$)
  JSONRPC_Framing_PushBytes(@state, #CRLF$ + "he")

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #False, "Incomplete body must wait.")

  JSONRPC_Framing_PushBytes(@state, "llo")

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #True, "Complete body must produce a message.")
  AssertString(message\body, "hello", "Extracted body must match the framed body.")
  Assert(message\byteLength = 5, "Message must report the byte length from Content-Length.")
EndProcedureUnit

ProcedureUnit ReaderPreservesBytesAfterFirstMessage()
  Protected state.JSONRPC_FrameState
  Protected message.JSONRPC_Message
  Protected stream.s

  stream = JSONRPC_Framing_BuildFrame("one") + JSONRPC_Framing_BuildFrame("two")

  JSONRPC_Framing_Init(@state)
  JSONRPC_Framing_PushBytes(@state, stream)

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #True, "First message should be available.")
  AssertString(message\body, "one", "First body should match.")

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #True, "Second message should remain buffered.")
  AssertString(message\body, "two", "Second body should match.")

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #False, "No third message should be available.")
  Assert(JSONRPC_Framing_HasError(@state) = #False, "Exhausted buffer should not be an error.")
EndProcedureUnit

ProcedureUnit ReaderHandlesUnicodeBodyByteLength()
  Protected state.JSONRPC_FrameState
  Protected message.JSONRPC_Message
  Protected body.s

  body = Chr($E4)

  JSONRPC_Framing_Init(@state)
  JSONRPC_Framing_PushBytes(@state, JSONRPC_Framing_BuildFrame(body))

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #True, "Unicode body should be extracted by UTF-8 byte length.")
  AssertString(message\body, body, "Unicode body should survive framing.")
  Assert(message\byteLength = 2, "Latin small letter a with diaeresis should be two UTF-8 bytes.")
EndProcedureUnit

ProcedureUnit ReaderRejectsInvalidContentLength()
  Protected state.JSONRPC_FrameState
  Protected message.JSONRPC_Message

  JSONRPC_Framing_Init(@state)
  JSONRPC_Framing_PushBytes(@state, "Content-Length: 5x" + #CRLF$ + #CRLF$ + "hello")

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #False, "Invalid Content-Length must not produce a message.")
  Assert(JSONRPC_Framing_GetErrorCode(@state) = #JSONRPC_Framing_ErrorInvalidContentLength, "Invalid Content-Length should set the expected error code.")
EndProcedureUnit

ProcedureUnit ReaderRejectsMissingContentLength()
  Protected state.JSONRPC_FrameState
  Protected message.JSONRPC_Message

  JSONRPC_Framing_Init(@state)
  JSONRPC_Framing_PushBytes(@state, "X-Test: value" + #CRLF$ + #CRLF$ + "hello")

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #False, "Missing Content-Length must not produce a message.")
  Assert(JSONRPC_Framing_GetErrorCode(@state) = #JSONRPC_Framing_ErrorMissingContentLength, "Missing Content-Length should set the expected error code.")
EndProcedureUnit

ProcedureUnit ReaderRejectsDuplicateContentLength()
  Protected state.JSONRPC_FrameState
  Protected message.JSONRPC_Message

  JSONRPC_Framing_Init(@state)
  JSONRPC_Framing_PushBytes(@state, "Content-Length: 5" + #CRLF$ + "Content-Length: 5" + #CRLF$ + #CRLF$ + "hello")

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #False, "Duplicate Content-Length must not produce a message.")
  Assert(JSONRPC_Framing_GetErrorCode(@state) = #JSONRPC_Framing_ErrorDuplicateContentLength, "Duplicate Content-Length should set the expected error code.")
EndProcedureUnit

ProcedureUnit ReaderRejectsOversizedBody()
  Protected state.JSONRPC_FrameState
  Protected message.JSONRPC_Message

  JSONRPC_Framing_Init(@state, #JSONRPC_Framing_DefaultMaxHeaderBytes, 4)
  JSONRPC_Framing_PushBytes(@state, "Content-Length: 5" + #CRLF$ + #CRLF$ + "hello")

  Assert(JSONRPC_Framing_NextMessage(@state, @message) = #False, "Oversized body must not produce a message.")
  Assert(JSONRPC_Framing_GetErrorCode(@state) = #JSONRPC_Framing_ErrorBodyTooLarge, "Oversized body should set the expected error code.")
EndProcedureUnit
