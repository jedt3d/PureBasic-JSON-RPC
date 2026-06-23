EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "outbound.pbi"
XIncludeFile "dispatch.pbi"

PureUnitOptions(Thread)

Global EventCaptureCount.i
Global EventCaptureCode.i
Global EventCaptureDetail.s

Procedure CaptureConnectionEvent(*connection, eventCode.i, detail.s)
  EventCaptureCount + 1
  EventCaptureCode = eventCode
  EventCaptureDetail = detail
EndProcedure

ProcedureUnit CloseEventIsRecordedAndCallbackRuns()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  EventCaptureCount = 0
  EventCaptureCode = 0
  EventCaptureDetail = ""

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Connection_SetEventHandler(@connection, @CaptureConnectionEvent())

  JSONRPC_Connection_Close(@connection)

  Assert(JSONRPC_Connection_GetLastEventCode(@connection) = #JSONRPC_Connection_EventClose, "Close should be recorded as last event.")
  Assert(EventCaptureCount = 1, "Event callback should run once.")
  Assert(EventCaptureCode = #JSONRPC_Connection_EventClose, "Callback should receive close event.")
EndProcedureUnit

ProcedureUnit MalformedMessageEventIsRecorded()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected dispatcher.JSONRPC_Dispatcher

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Dispatcher_Init(@dispatcher)

  JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"broken")

  Assert(JSONRPC_Connection_GetLastEventCode(@connection) = #JSONRPC_Connection_EventMalformedMessage, "Malformed message should be observable.")
  Assert(JSONRPC_Connection_GetEventCount(@connection) >= 1, "Event count should increase.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit UnhandledNotificationEventIsRecorded()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected dispatcher.JSONRPC_Dispatcher

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Dispatcher_Init(@dispatcher)

  JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/unknown\"}")

  Assert(JSONRPC_Connection_GetLastEventCode(@connection) = #JSONRPC_Connection_EventUnhandledNotification, "Unknown notification should be observable.")
  AssertString(JSONRPC_Connection_GetLastEventDetail(@connection), "notifications/unknown", "Event detail should carry the method.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit OrphanResponseEventIsRecorded()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  JSONRPC_Connection_MatchResponse(@connection, ~"{\"jsonrpc\":\"2.0\",\"result\":true,\"id\":99}")

  Assert(JSONRPC_Connection_GetLastEventCode(@connection) = #JSONRPC_Connection_EventOrphanResponse, "Orphan response should be observable.")
  AssertString(JSONRPC_Connection_GetLastEventDetail(@connection), "99", "Event detail should carry response id.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
