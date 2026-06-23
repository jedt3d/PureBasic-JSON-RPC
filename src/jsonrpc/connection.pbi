EnableExplicit

XIncludeFile "io.pbi"
XIncludeFile "codec.pbi"

Enumeration
  #JSONRPC_Connection_ErrorNone = 0
  #JSONRPC_Connection_ErrorMutexCreateFailed
  #JSONRPC_Connection_ErrorNoWriter
  #JSONRPC_Connection_ErrorClosed
  #JSONRPC_Connection_ErrorInvalidMethod
  #JSONRPC_Connection_ErrorInvalidParams
  #JSONRPC_Connection_ErrorOrphanResponse
  #JSONRPC_Connection_ErrorTimeout
  #JSONRPC_Connection_ErrorWriteFailed
EndEnumeration

Enumeration
  #JSONRPC_Connection_EventNone = 0
  #JSONRPC_Connection_EventError
  #JSONRPC_Connection_EventMalformedMessage
  #JSONRPC_Connection_EventUnhandledNotification
  #JSONRPC_Connection_EventOrphanResponse
  #JSONRPC_Connection_EventClose
  #JSONRPC_Connection_EventDispose
EndEnumeration

Enumeration
  #JSONRPC_Trace_Off = 0
  #JSONRPC_Trace_Errors
  #JSONRPC_Trace_Headers
  #JSONRPC_Trace_Messages
  #JSONRPC_Trace_Verbose
EndEnumeration

#JSONRPC_Connection_DefaultTimeoutMs = 30000

Prototype JSONRPC_ConnectionEventHandler(*connection, eventCode.i, detail.s)
Prototype JSONRPC_TraceLogger(*connection, traceLevel.i, message.s)

Structure JSONRPC_PendingRequest
  idText.s
  method.s
  createdAtMs.q
  timeoutMs.i
  deadlineMs.q
EndStructure

Structure JSONRPC_CancellationToken
  idText.s
  requested.i
EndStructure

Structure JSONRPC_Diagnostics
  receivedMessages.q
  sentMessages.q
  errors.q
  timeouts.q
  orphanResponses.q
  batches.q
  cancellations.q
  queuedWrites.q
  writeFailures.q
EndStructure

Structure JSONRPC_Connection
  running.i
  closing.i
  closed.i
  writerMutex.i
  *writer.JSONRPC_Writer
  nextId.q
  List writeQueue.s()
  Map pending.JSONRPC_PendingRequest()
  Map cancellations.JSONRPC_CancellationToken()
  lastMatchedIdText.s
  lastResponseBody.s
  lastTimedOutIdText.s
  lastCancelledIdText.s
  diagnostics.JSONRPC_Diagnostics
  lastErrorCode.i
  lastErrorMessage.s
  eventHandler.JSONRPC_ConnectionEventHandler
  lastEventCode.i
  lastEventDetail.s
  eventCount.q
  traceLevel.i
  tracePayloads.i
  traceLogger.JSONRPC_TraceLogger
  traceCaptured.s
EndStructure

Declare.i JSONRPC_Connection_Init(*connection.JSONRPC_Connection, *writer.JSONRPC_Writer = 0)
Declare.i JSONRPC_Connection_Close(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_QueueBody(*connection.JSONRPC_Connection, body.s)
Declare.i JSONRPC_Connection_FlushWrites(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_PendingWriteCount(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_SendBody(*connection.JSONRPC_Connection, body.s)
Declare.i JSONRPC_Connection_IsRunning(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_IsClosing(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_IsClosed(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_GetLastErrorCode(*connection.JSONRPC_Connection)
Declare.s JSONRPC_Connection_GetLastErrorMessage(*connection.JSONRPC_Connection)
Declare JSONRPC_Connection_SetEventHandler(*connection.JSONRPC_Connection, handler.JSONRPC_ConnectionEventHandler)
Declare JSONRPC_Connection_EmitEvent(*connection.JSONRPC_Connection, eventCode.i, detail.s)
Declare.i JSONRPC_Connection_GetLastEventCode(*connection.JSONRPC_Connection)
Declare.s JSONRPC_Connection_GetLastEventDetail(*connection.JSONRPC_Connection)
Declare.q JSONRPC_Connection_GetEventCount(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_IsCancellationRequested(*connection.JSONRPC_Connection, idText.s)
Declare.i JSONRPC_Connection_ClearCancellation(*connection.JSONRPC_Connection, idText.s)
Declare JSONRPC_Trace_Set(*connection.JSONRPC_Connection, traceLevel.i, includePayloads.i = #False)
Declare JSONRPC_Trace_SetLogger(*connection.JSONRPC_Connection, logger.JSONRPC_TraceLogger)
Declare JSONRPC_Trace_Log(*connection.JSONRPC_Connection, traceLevel.i, message.s)
Declare.s JSONRPC_Trace_GetCaptured(*connection.JSONRPC_Connection)
Declare JSONRPC_Trace_Clear(*connection.JSONRPC_Connection)

Procedure JSONRPC_Trace_Set(*connection.JSONRPC_Connection, traceLevel.i, includePayloads.i = #False)
  If *connection = 0
    ProcedureReturn
  EndIf

  *connection\traceLevel = traceLevel
  *connection\tracePayloads = Bool(includePayloads)
EndProcedure

Procedure JSONRPC_Trace_SetLogger(*connection.JSONRPC_Connection, logger.JSONRPC_TraceLogger)
  If *connection <> 0
    *connection\traceLogger = logger
  EndIf
EndProcedure

Procedure JSONRPC_Trace_Log(*connection.JSONRPC_Connection, traceLevel.i, message.s)
  If *connection = 0 Or traceLevel <= #JSONRPC_Trace_Off Or *connection\traceLevel < traceLevel
    ProcedureReturn
  EndIf

  If *connection\traceCaptured <> ""
    *connection\traceCaptured + #LF$
  EndIf

  *connection\traceCaptured + message

  If *connection\traceLogger <> 0
    *connection\traceLogger(*connection, traceLevel, message)
  EndIf
EndProcedure

Procedure.s JSONRPC_Trace_GetCaptured(*connection.JSONRPC_Connection)
  If *connection = 0
    ProcedureReturn ""
  EndIf

  ProcedureReturn *connection\traceCaptured
EndProcedure

Procedure JSONRPC_Trace_Clear(*connection.JSONRPC_Connection)
  If *connection <> 0
    *connection\traceCaptured = ""
  EndIf
EndProcedure

Procedure JSONRPC_Connection_EmitEvent(*connection.JSONRPC_Connection, eventCode.i, detail.s)
  If *connection = 0 Or eventCode = #JSONRPC_Connection_EventNone
    ProcedureReturn
  EndIf

  *connection\lastEventCode = eventCode
  *connection\lastEventDetail = detail
  *connection\eventCount + 1

  If *connection\eventHandler <> 0
    *connection\eventHandler(*connection, eventCode, detail)
  EndIf
EndProcedure

Procedure JSONRPC_Connection_SetError(*connection.JSONRPC_Connection, code.i, message.s)
  *connection\lastErrorCode = code
  *connection\lastErrorMessage = message

  If code <> #JSONRPC_Connection_ErrorNone
    JSONRPC_Trace_Log(*connection, #JSONRPC_Trace_Errors, "error: " + message)
    JSONRPC_Connection_EmitEvent(*connection, #JSONRPC_Connection_EventError, message)
  EndIf
EndProcedure

Procedure.i JSONRPC_Connection_Init(*connection.JSONRPC_Connection, *writer.JSONRPC_Writer = 0)
  *connection\running = #False
  *connection\closing = #False
  *connection\closed = #False
  *connection\writerMutex = CreateMutex()
  *connection\writer = *writer
  *connection\nextId = 1
  ClearList(*connection\writeQueue())
  ClearMap(*connection\pending())
  ClearMap(*connection\cancellations())
  *connection\lastMatchedIdText = ""
  *connection\lastResponseBody = ""
  *connection\lastTimedOutIdText = ""
  *connection\lastCancelledIdText = ""
  *connection\diagnostics\receivedMessages = 0
  *connection\diagnostics\sentMessages = 0
  *connection\diagnostics\errors = 0
  *connection\diagnostics\timeouts = 0
  *connection\diagnostics\orphanResponses = 0
  *connection\diagnostics\batches = 0
  *connection\diagnostics\cancellations = 0
  *connection\diagnostics\queuedWrites = 0
  *connection\diagnostics\writeFailures = 0
  *connection\eventHandler = 0
  *connection\lastEventCode = #JSONRPC_Connection_EventNone
  *connection\lastEventDetail = ""
  *connection\eventCount = 0
  *connection\traceLevel = #JSONRPC_Trace_Off
  *connection\tracePayloads = #False
  *connection\traceLogger = 0
  *connection\traceCaptured = ""
  JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorNone, "")

  If *connection\writerMutex = 0
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorMutexCreateFailed, "Unable to create connection writer mutex.")
    ProcedureReturn #False
  EndIf

  *connection\running = #True
  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_Connection_Close(*connection.JSONRPC_Connection)
  If *connection\closed
    ProcedureReturn #True
  EndIf

  *connection\closing = #True
  *connection\running = #False

  If *connection\writer <> 0
    JSONRPC_Writer_Close(*connection\writer)
  EndIf

  ClearList(*connection\writeQueue())
  ClearMap(*connection\pending())
  ClearMap(*connection\cancellations())
  *connection\lastMatchedIdText = ""
  *connection\lastResponseBody = ""
  *connection\lastTimedOutIdText = ""
  *connection\lastCancelledIdText = ""

  If *connection\writerMutex <> 0
    FreeMutex(*connection\writerMutex)
    *connection\writerMutex = 0
  EndIf

  *connection\closed = #True
  *connection\closing = #False
  JSONRPC_Connection_EmitEvent(*connection, #JSONRPC_Connection_EventClose, "Connection closed.")

  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_Connection_QueueBody(*connection.JSONRPC_Connection, body.s)
  If *connection\closed Or *connection\closing
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorClosed, "Connection is closed.")
    ProcedureReturn #False
  EndIf

  AddElement(*connection\writeQueue())
  *connection\writeQueue() = body
  *connection\diagnostics\queuedWrites + 1
  JSONRPC_Trace_Log(*connection, #JSONRPC_Trace_Headers, "queued message bytes=" + Str(StringByteLength(body, #PB_UTF8)))
  JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorNone, "")
  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_Connection_FlushWrites(*connection.JSONRPC_Connection)
  Protected ok.i = #True

  If *connection\closed Or *connection\closing
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorClosed, "Connection is closed.")
    ProcedureReturn #False
  EndIf

  If *connection\writer = 0
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorNoWriter, "Connection has no writer.")
    *connection\diagnostics\writeFailures + ListSize(*connection\writeQueue())
    ClearList(*connection\writeQueue())
    ProcedureReturn #False
  EndIf

  If *connection\writerMutex <> 0
    LockMutex(*connection\writerMutex)
  EndIf

  While FirstElement(*connection\writeQueue())
    If JSONRPC_Writer_Write(*connection\writer, *connection\writeQueue())
      If *connection\tracePayloads
        JSONRPC_Trace_Log(*connection, #JSONRPC_Trace_Messages, "sent: " + *connection\writeQueue())
      Else
        JSONRPC_Trace_Log(*connection, #JSONRPC_Trace_Messages, "sent message bytes=" + Str(StringByteLength(*connection\writeQueue(), #PB_UTF8)))
      EndIf

      *connection\diagnostics\sentMessages + 1
      DeleteElement(*connection\writeQueue())
    Else
      *connection\diagnostics\writeFailures + 1
      DeleteElement(*connection\writeQueue())
      JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorWriteFailed, JSONRPC_Writer_GetLastErrorMessage(*connection\writer))
      ok = #False
      Break
    EndIf
  Wend

  If *connection\writerMutex <> 0
    UnlockMutex(*connection\writerMutex)
  EndIf

  If ok
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorNone, "")
  EndIf

  ProcedureReturn ok
EndProcedure

Procedure.i JSONRPC_Connection_PendingWriteCount(*connection.JSONRPC_Connection)
  If *connection = 0
    ProcedureReturn 0
  EndIf

  ProcedureReturn ListSize(*connection\writeQueue())
EndProcedure

Procedure.i JSONRPC_Connection_SendBody(*connection.JSONRPC_Connection, body.s)
  If JSONRPC_Connection_QueueBody(*connection, body) = #False
    ProcedureReturn #False
  EndIf

  ProcedureReturn JSONRPC_Connection_FlushWrites(*connection)
EndProcedure

Procedure.i JSONRPC_Connection_IsRunning(*connection.JSONRPC_Connection)
  ProcedureReturn *connection\running
EndProcedure

Procedure.i JSONRPC_Connection_IsClosing(*connection.JSONRPC_Connection)
  ProcedureReturn *connection\closing
EndProcedure

Procedure.i JSONRPC_Connection_IsClosed(*connection.JSONRPC_Connection)
  ProcedureReturn *connection\closed
EndProcedure

Procedure.i JSONRPC_Connection_GetLastErrorCode(*connection.JSONRPC_Connection)
  ProcedureReturn *connection\lastErrorCode
EndProcedure

Procedure.s JSONRPC_Connection_GetLastErrorMessage(*connection.JSONRPC_Connection)
  ProcedureReturn *connection\lastErrorMessage
EndProcedure

Procedure JSONRPC_Connection_SetEventHandler(*connection.JSONRPC_Connection, handler.JSONRPC_ConnectionEventHandler)
  If *connection <> 0
    *connection\eventHandler = handler
  EndIf
EndProcedure

Procedure.i JSONRPC_Connection_GetLastEventCode(*connection.JSONRPC_Connection)
  If *connection = 0
    ProcedureReturn #JSONRPC_Connection_EventNone
  EndIf

  ProcedureReturn *connection\lastEventCode
EndProcedure

Procedure.s JSONRPC_Connection_GetLastEventDetail(*connection.JSONRPC_Connection)
  If *connection = 0
    ProcedureReturn ""
  EndIf

  ProcedureReturn *connection\lastEventDetail
EndProcedure

Procedure.q JSONRPC_Connection_GetEventCount(*connection.JSONRPC_Connection)
  If *connection = 0
    ProcedureReturn 0
  EndIf

  ProcedureReturn *connection\eventCount
EndProcedure

Procedure.i JSONRPC_Connection_IsCancellationRequested(*connection.JSONRPC_Connection, idText.s)
  If *connection = 0 Or idText = ""
    ProcedureReturn #False
  EndIf

  If FindMapElement(*connection\cancellations(), idText)
    ProcedureReturn *connection\cancellations()\requested
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i JSONRPC_Connection_ClearCancellation(*connection.JSONRPC_Connection, idText.s)
  If *connection = 0 Or idText = ""
    ProcedureReturn #False
  EndIf

  If FindMapElement(*connection\cancellations(), idText)
    DeleteMapElement(*connection\cancellations())
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure
