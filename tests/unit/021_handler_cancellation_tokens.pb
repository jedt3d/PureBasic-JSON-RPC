EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "cancel.pbi"

PureUnitOptions(Thread)

Global HandlerSawCancellation.i
Global HandlerCancellationId.s

Procedure.i CancellationAwareHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected cancelledJson.s

  HandlerSawCancellation = JSONRPC_RequestContext_IsCancellationRequested(*context)
  HandlerCancellationId = JSONRPC_RequestContext_CancellationId(*context)
  If HandlerSawCancellation
    cancelledJson = "true"
  Else
    cancelledJson = "false"
  EndIf

  *result\ok = #True
  *result\resultJson = ~"{\"cancelled\":" + cancelledJson + "}"
  ProcedureReturn #True
EndProcedure

ProcedureUnit HandlerCanObserveCancellationToken()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected response.s

  HandlerSawCancellation = #False
  HandlerCancellationId = ""

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_RegisterRequest(@dispatcher, "work/run", @CancellationAwareHandler())
  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  JSONRPC_Cancel_Request(@connection, "7")
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"work/run\",\"id\":7}")

  Assert(HandlerSawCancellation, "Handler should see cancellation request.")
  AssertString(HandlerCancellationId, "7", "Handler should see cancellation id.")
  Assert(FindString(response, ~"\"cancelled\":true", 1) > 0, "Handler response should reflect cancellation.")
  Assert(JSONRPC_Cancel_IsRequested(@connection, "7") = #False, "Dispatcher should clear cancellation after request completes.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit HandlerSeesFalseWhenNotCancelled()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  HandlerSawCancellation = #True
  HandlerCancellationId = ""

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_RegisterRequest(@dispatcher, "work/run", @CancellationAwareHandler())
  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"work/run\",\"id\":8}")

  Assert(HandlerSawCancellation = #False, "Handler should see non-cancelled state.")
  AssertString(HandlerCancellationId, "8", "Handler should still receive the request id as cancellation id.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit CancellationNotificationStillEmitsNoResponse()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_Cancel_ProcessNotification(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"$/cancelRequest\",\"params\":{\"id\":9}}"), "Cancellation notification should process.")
  Assert(JSONRPC_Cancel_IsRequested(@connection, "9"), "Cancellation should be recorded.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
