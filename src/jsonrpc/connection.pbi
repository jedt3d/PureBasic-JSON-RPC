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

#JSONRPC_Connection_DefaultTimeoutMs = 30000

Prototype JSONRPC_ConnectionEventHandler(*connection, eventCode.i, detail.s)

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
EndStructure

Structure JSONRPC_Connection
  running.i
  closing.i
  closed.i
  writerMutex.i
  *writer.JSONRPC_Writer
  nextId.q
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
EndStructure

Declare.i JSONRPC_Connection_Init(*connection.JSONRPC_Connection, *writer.JSONRPC_Writer = 0)
Declare.i JSONRPC_Connection_Close(*connection.JSONRPC_Connection)
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
  *connection\eventHandler = 0
  *connection\lastEventCode = #JSONRPC_Connection_EventNone
  *connection\lastEventDetail = ""
  *connection\eventCount = 0
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

Procedure.i JSONRPC_Connection_SendBody(*connection.JSONRPC_Connection, body.s)
  If *connection\closed Or *connection\closing
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorClosed, "Connection is closed.")
    ProcedureReturn #False
  EndIf

  If *connection\writer = 0
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorNoWriter, "Connection has no writer.")
    ProcedureReturn #False
  EndIf

  If *connection\writerMutex <> 0
    LockMutex(*connection\writerMutex)
  EndIf

  If JSONRPC_Writer_Write(*connection\writer, body)
    *connection\diagnostics\sentMessages + 1
  Else
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorNoWriter, JSONRPC_Writer_GetLastErrorMessage(*connection\writer))
    If *connection\writerMutex <> 0
      UnlockMutex(*connection\writerMutex)
    EndIf

    ProcedureReturn #False
  EndIf

  If *connection\writerMutex <> 0
    UnlockMutex(*connection\writerMutex)
  EndIf

  JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorNone, "")
  ProcedureReturn #True
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
