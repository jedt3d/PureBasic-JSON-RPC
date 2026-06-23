EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "trace.pbi"

PureUnitOptions(Thread)

Global TraceCallbackCount.i
Global TraceCallbackLevel.i
Global TraceCallbackMessage.s

Procedure CaptureTraceLog(*connection, traceLevel.i, message.s)
  TraceCallbackCount + 1
  TraceCallbackLevel = traceLevel
  TraceCallbackMessage = message
EndProcedure

ProcedureUnit TraceCallbackReceivesMessages()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  TraceCallbackCount = 0
  TraceCallbackLevel = 0
  TraceCallbackMessage = ""

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Trace_Set(@connection, #JSONRPC_Trace_Messages)
  JSONRPC_Trace_SetLogger(@connection, @CaptureTraceLog())

  JSONRPC_Connection_SendBody(@connection, "body")

  Assert(TraceCallbackCount >= 1, "Trace callback should receive write trace.")
  Assert(TraceCallbackLevel = #JSONRPC_Trace_Messages Or TraceCallbackLevel = #JSONRPC_Trace_Headers, "Trace callback should receive a configured level.")
  Assert(FindString(JSONRPC_Trace_GetCaptured(@connection), "sent message bytes=", 1) > 0, "Captured trace should include sent message metadata.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit PayloadsAreHiddenByDefault()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Trace_Set(@connection, #JSONRPC_Trace_Messages)

  JSONRPC_Connection_SendBody(@connection, ~"{\"secret\":\"value\"}")

  Assert(FindString(JSONRPC_Trace_GetCaptured(@connection), "secret", 1) = 0, "Trace should not include payloads by default.")
  Assert(FindString(JSONRPC_Trace_GetCaptured(@connection), "sent message bytes=", 1) > 0, "Trace should include message metadata.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit PayloadsCanBeIncludedExplicitly()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Trace_Set(@connection, #JSONRPC_Trace_Messages, #True)

  JSONRPC_Connection_SendBody(@connection, ~"{\"visible\":true}")

  Assert(FindString(JSONRPC_Trace_GetCaptured(@connection), "visible", 1) > 0, "Explicit payload tracing should include body.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit ErrorTraceRecordsWriteFailure()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Trace_Set(@connection, #JSONRPC_Trace_Errors)
  JSONRPC_Writer_FailNextWrite(@writer)

  JSONRPC_Connection_SendBody(@connection, "fail")

  Assert(FindString(JSONRPC_Trace_GetCaptured(@connection), "error:", 1) > 0, "Error trace should record write failure.")
  Assert(FindString(JSONRPC_Trace_GetCaptured(@connection), "fail", 1) = 0, "Error trace should not include failed payload.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
