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

#JSONRPC_Connection_DefaultTimeoutMs = 30000

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
EndStructure

Declare.i JSONRPC_Connection_Init(*connection.JSONRPC_Connection, *writer.JSONRPC_Writer = 0)
Declare.i JSONRPC_Connection_Close(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_SendBody(*connection.JSONRPC_Connection, body.s)
Declare.i JSONRPC_Connection_IsRunning(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_IsClosing(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_IsClosed(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_GetLastErrorCode(*connection.JSONRPC_Connection)
Declare.s JSONRPC_Connection_GetLastErrorMessage(*connection.JSONRPC_Connection)

Procedure JSONRPC_Connection_SetError(*connection.JSONRPC_Connection, code.i, message.s)
  *connection\lastErrorCode = code
  *connection\lastErrorMessage = message
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
