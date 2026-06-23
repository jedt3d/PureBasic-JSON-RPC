EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "codec.pbi"

PureUnitOptions(Thread)

ProcedureUnit StdioBuildMessageAppendsNewline()
  Protected body.s
  Protected encoded.s

  body = ~"{\"jsonrpc\":\"2.0\",\"method\":\"ping\"}"
  encoded = JSONRPC_Codec_StdioBuildMessage(body)

  AssertString(encoded, body + #LF$, "Stdio codec should append exactly one newline.")
EndProcedureUnit

ProcedureUnit StdioBuildMessageRejectsEmbeddedNewline()
  Protected encoded.s

  encoded = JSONRPC_Codec_StdioBuildMessage("before" + #LF$ + "after")

  AssertString(encoded, "", "Stdio codec must reject outbound messages with embedded newlines.")
EndProcedureUnit

ProcedureUnit StdioReaderWaitsForPartialLine()
  Protected state.JSONRPC_StdioCodecState
  Protected message.JSONRPC_Message

  JSONRPC_Codec_StdioInit(@state)
  JSONRPC_Codec_StdioPushBytes(@state, ~"{\"jsonrpc\":\"2.0\"")

  Assert(JSONRPC_Codec_StdioNextMessage(@state, @message) = #False, "Partial stdio line must wait.")
  Assert(JSONRPC_Codec_StdioHasError(@state) = #False, "Partial stdio line is not an error.")
EndProcedureUnit

ProcedureUnit StdioReaderExtractsSingleLine()
  Protected state.JSONRPC_StdioCodecState
  Protected message.JSONRPC_Message
  Protected body.s

  body = ~"{\"jsonrpc\":\"2.0\",\"method\":\"ping\"}"

  JSONRPC_Codec_StdioInit(@state)
  JSONRPC_Codec_StdioPushBytes(@state, body + #LF$)

  Assert(JSONRPC_Codec_StdioNextMessage(@state, @message) = #True, "Complete stdio line should produce a message.")
  AssertString(message\body, body, "Extracted stdio message should not include the newline delimiter.")
  Assert(message\byteLength = JSONRPC_Framing_Utf8ByteLength(body), "Stdio message should report UTF-8 byte length.")
EndProcedureUnit

ProcedureUnit StdioReaderExtractsMultipleLines()
  Protected state.JSONRPC_StdioCodecState
  Protected message.JSONRPC_Message
  Protected first.s
  Protected second.s

  first = ~"{\"jsonrpc\":\"2.0\",\"method\":\"first\"}"
  second = ~"{\"jsonrpc\":\"2.0\",\"method\":\"second\"}"

  JSONRPC_Codec_StdioInit(@state)
  JSONRPC_Codec_StdioPushBytes(@state, first + #LF$ + second + #LF$)

  Assert(JSONRPC_Codec_StdioNextMessage(@state, @message) = #True, "First stdio message should be available.")
  AssertString(message\body, first, "First stdio message should match.")

  Assert(JSONRPC_Codec_StdioNextMessage(@state, @message) = #True, "Second stdio message should remain buffered.")
  AssertString(message\body, second, "Second stdio message should match.")
EndProcedureUnit

ProcedureUnit StdioReaderAcceptsCrLfDelimiter()
  Protected state.JSONRPC_StdioCodecState
  Protected message.JSONRPC_Message
  Protected body.s

  body = ~"{\"jsonrpc\":\"2.0\",\"method\":\"ping\"}"

  JSONRPC_Codec_StdioInit(@state)
  JSONRPC_Codec_StdioPushBytes(@state, body + #CRLF$)

  Assert(JSONRPC_Codec_StdioNextMessage(@state, @message) = #True, "CRLF should be accepted as a stdio delimiter.")
  AssertString(message\body, body, "Trailing carriage return should be stripped.")
EndProcedureUnit

ProcedureUnit StdioReaderRejectsEmbeddedCarriageReturn()
  Protected state.JSONRPC_StdioCodecState
  Protected message.JSONRPC_Message

  JSONRPC_Codec_StdioInit(@state)
  JSONRPC_Codec_StdioPushBytes(@state, "before" + #CR$ + "after" + #LF$)

  Assert(JSONRPC_Codec_StdioNextMessage(@state, @message) = #False, "Embedded carriage return must reject the stdio message.")
  Assert(JSONRPC_Codec_StdioGetErrorCode(@state) = #JSONRPC_Codec_ErrorEmbeddedNewline, "Embedded newline should set the expected error code.")
EndProcedureUnit

ProcedureUnit StdioReaderRejectsOversizedPartialLine()
  Protected state.JSONRPC_StdioCodecState

  JSONRPC_Codec_StdioInit(@state, 4)
  JSONRPC_Codec_StdioPushBytes(@state, "hello")

  Assert(JSONRPC_Codec_StdioGetErrorCode(@state) = #JSONRPC_Codec_ErrorMessageTooLarge, "Oversized partial stdio line should fail fast.")
EndProcedureUnit

