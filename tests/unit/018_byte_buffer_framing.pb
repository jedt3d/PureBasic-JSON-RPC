EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "codec.pbi"

PureUnitOptions(Thread)

ProcedureUnit ByteBufferTracksUtf8Length()
  Protected buffer.JSONRPC_ByteBuffer
  Protected body.s

  JSONRPC_ByteBuffer_Init(@buffer)
  body = "a" + Chr($E4)
  Assert(JSONRPC_ByteBuffer_AppendUtf8(@buffer, "a"), "Append should succeed.")
  Assert(JSONRPC_ByteBuffer_AppendUtf8(@buffer, Chr($E4)), "Append should accept UTF-8 text.")

  Assert(JSONRPC_ByteBuffer_Length(@buffer) = 3, "Byte buffer should count UTF-8 bytes, not characters.")
  AssertString(JSONRPC_ByteBuffer_AsText(@buffer), body, "Byte buffer should preserve text.")
EndProcedureUnit

ProcedureUnit ByteBufferHonorsMaximum()
  Protected buffer.JSONRPC_ByteBuffer

  JSONRPC_ByteBuffer_Init(@buffer, 3)
  Assert(JSONRPC_ByteBuffer_AppendUtf8(@buffer, "abc"), "Append within limit should pass.")
  Assert(JSONRPC_ByteBuffer_AppendUtf8(@buffer, "d") = #False, "Append beyond limit should fail.")
  Assert(JSONRPC_ByteBuffer_HasOverflow(@buffer), "Overflow flag should be set.")
  AssertString(JSONRPC_ByteBuffer_AsText(@buffer), "abc", "Rejected append should not alter text.")
EndProcedureUnit

ProcedureUnit FramingKeepsRemainderInByteBuffer()
  Protected state.JSONRPC_FrameState
  Protected message.JSONRPC_Message
  Protected first.s
  Protected second.s

  JSONRPC_Framing_Init(@state)
  first = JSONRPC_Framing_BuildFrame(~"{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":\"one\"}")
  second = JSONRPC_Framing_BuildFrame(~"{\"jsonrpc\":\"2.0\",\"id\":2,\"result\":\"two\"}")

  JSONRPC_Framing_PushBytes(@state, first + second)
  Assert(JSONRPC_Framing_NextMessage(@state, @message), "First framed message should be available.")
  Assert(FindString(message\body, "one", 1) > 0, "First body should be returned.")
  Assert(JSONRPC_ByteBuffer_Length(@state\buffer) = JSONRPC_Framing_Utf8ByteLength(second), "Remainder should stay byte-counted.")
  Assert(JSONRPC_Framing_NextMessage(@state, @message), "Second framed message should still be available.")
  Assert(FindString(message\body, "two", 1) > 0, "Second body should be returned.")
EndProcedureUnit

ProcedureUnit StdioCodecAllowsMultipleMessagesBeyondSingleLimit()
  Protected state.JSONRPC_StdioCodecState
  Protected message.JSONRPC_Message

  JSONRPC_Codec_StdioInit(@state, 8)
  JSONRPC_Codec_StdioPushBytes(@state, "12345678" + #LF$ + "abcd" + #LF$)

  Assert(JSONRPC_Codec_StdioNextMessage(@state, @message), "First max-sized stdio message should be available.")
  AssertString(message\body, "12345678", "First line should be preserved.")
  Assert(JSONRPC_Codec_StdioNextMessage(@state, @message), "Second line should be available from same chunk.")
  AssertString(message\body, "abcd", "Second line should be preserved.")
EndProcedureUnit
