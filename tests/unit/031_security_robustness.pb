EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "jsonrpc.pbi"

PureUnitOptions(Thread)

Procedure.i RobustnessOkHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = ~"{\"ok\":true}"
  ProcedureReturn #True
EndProcedure

Procedure.s ReadTextFile(path.s)
  Protected file.i
  Protected text.s

  file = ReadFile(#PB_Any, path, #PB_UTF8)
  If file = 0
    ProcedureReturn ""
  EndIf

  While Eof(file) = 0
    text + ReadString(file, #PB_UTF8) + #LF$
  Wend

  CloseFile(file)
  ProcedureReturn text
EndProcedure

Procedure.s ReadProjectTextFile(path.s)
  Protected text.s

  text = ReadTextFile(path)
  If text <> ""
    ProcedureReturn text
  EndIf

  text = ReadTextFile("../" + path)
  If text <> ""
    ProcedureReturn text
  EndIf

  text = ReadTextFile("../../" + path)
  If text <> ""
    ProcedureReturn text
  EndIf

  ProcedureReturn ""
EndProcedure

ProcedureUnit TracePayloadsRemainOptIn()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected trace.s
  Protected body.s = ~"{\"jsonrpc\":\"2.0\",\"method\":\"secret\",\"params\":{\"token\":\"do-not-log\"},\"id\":1}"

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  JSONRPC_Trace_Set(@connection, #JSONRPC_Trace_Messages)
  JSONRPC_Connection_SendBody(@connection, body)
  trace = JSONRPC_Trace_GetCaptured(@connection)

  Assert(FindString(trace, "sent message bytes=", 1) > 0, "Trace should contain message metadata.")
  Assert(FindString(trace, "do-not-log", 1) = 0, "Trace should hide payloads by default.")

  JSONRPC_Trace_Clear(@connection)
  JSONRPC_Trace_Set(@connection, #JSONRPC_Trace_Messages, #True)
  JSONRPC_Connection_SendBody(@connection, body)
  trace = JSONRPC_Trace_GetCaptured(@connection)

  Assert(FindString(trace, "do-not-log", 1) > 0, "Payload tracing should be explicit opt-in.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit MalformedMessageRecoveryAllowsNextValidRequest()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_RegisterRequest(@dispatcher, "ok", @RobustnessOkHandler())
  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"broken")
  Assert(FindString(response, ~"\"code\":-32700", 1) > 0, "Malformed JSON should return parse error.")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"ok\",\"id\":1}")
  Assert(FindString(response, ~"\"result\":{\"ok\":true}", 1) > 0, "Valid request should succeed after malformed input.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Malformed recovery should not leave pending state.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit WriteFailureCanRecoverOnNextWrite()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  JSONRPC_Writer_FailNextWrite(@writer)
  Assert(JSONRPC_Connection_SendBody(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"first\"}") = #False, "First write should fail.")
  Assert(JSONRPC_Connection_PendingWriteCount(@connection) = 0, "Failed body should be dropped.")
  Assert(connection\diagnostics\writeFailures = 1, "Write failure should be counted.")

  Assert(JSONRPC_Connection_SendBody(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"second\"}"), "Next write should recover.")
  Assert(connection\diagnostics\sentMessages = 1, "Recovered write should be counted as sent.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit SizeLimitsRejectBeforeDispatch()
  Protected frame.JSONRPC_FrameState
  Protected stdio.JSONRPC_StdioCodecState
  Protected message.JSONRPC_Message

  JSONRPC_Framing_Init(@frame, 64, 4)
  JSONRPC_Framing_PushBytes(@frame, "Content-Length: 5" + #CRLF$ + #CRLF$ + "12345")
  Assert(JSONRPC_Framing_NextMessage(@frame, @message) = #False, "Framing should reject body over max bytes.")
  Assert(JSONRPC_Framing_GetErrorCode(@frame) = #JSONRPC_Framing_ErrorBodyTooLarge, "Framing should report body too large.")

  JSONRPC_Codec_StdioInit(@stdio, 4)
  JSONRPC_Codec_StdioPushBytes(@stdio, "12345" + #LF$)
  Assert(JSONRPC_Codec_StdioNextMessage(@stdio, @message) = #False, "Stdio should reject message over max bytes.")
  Assert(JSONRPC_Codec_StdioGetErrorCode(@stdio) = #JSONRPC_Codec_ErrorMessageTooLarge, "Stdio should report message too large.")
EndProcedureUnit

ProcedureUnit SecurityRobustnessDocsAndPathHarnessArePresent()
  Protected docs.s
  Protected checkScript.s

  docs = ReadProjectTextFile("docs/security-robustness.md")
  checkScript = ReadProjectTextFile("tools/check.sh")

  Assert(FindString(docs, "Application Responsibilities", 1) > 0, "Security docs should separate application responsibilities.")
  Assert(FindString(docs, "Trace Payloads", 1) > 0, "Security docs should document trace payload behavior.")
  Assert(FindString(docs, "tools/verify-paths.sh", 1) > 0, "Security docs should reference path verification.")
  Assert(FindString(checkScript, "verify-paths.sh", 1) > 0, "Full check should run path verification.")
EndProcedureUnit
