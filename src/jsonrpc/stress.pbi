EnableExplicit

XIncludeFile "diagnostics.pbi"

Declare.i JSONRPC_Stress_RunBasic(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, iterations.i)
Declare.i JSONRPC_Stress_RunLifecycle(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, iterations.i)

Procedure.i JSONRPC_Stress_RunBasic(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, iterations.i)
  Protected index.i
  Protected response.s
  Protected requestId.q
  Protected deadline.q

  If iterations <= 0
    iterations = 1
  EndIf

  For index = 1 To iterations
    response = JSONRPC_Dispatcher_Dispatch(*dispatcher, *connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/missing\",\"id\":" + Str(index) + "}")
    If FindString(response, ~"\"code\":-32601", 1) = 0
      ProcedureReturn #False
    EndIf

    response = JSONRPC_Dispatcher_Dispatch(*dispatcher, *connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"broken")
    If FindString(response, ~"\"code\":-32700", 1) = 0
      ProcedureReturn #False
    EndIf

    response = JSONRPC_Batch_Dispatch(*dispatcher, *connection, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"notifications/log\"}]")
    If response <> ""
      ProcedureReturn #False
    EndIf

    requestId = JSONRPC_Connection_SendRequest(*connection, "tools/wait", "", 1)
    deadline = JSONRPC_Connection_PendingDeadline(*connection, Str(requestId))
    JSONRPC_Connection_CleanupTimeouts(*connection, deadline)

    If JSONRPC_Connection_PendingCount(*connection) <> 0
      ProcedureReturn #False
    EndIf

    JSONRPC_Cancel_Request(*connection, Str(index))
    JSONRPC_Cancel_Clear(*connection, Str(index))
  Next

  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_Stress_RunLifecycle(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, iterations.i)
  Protected index.i
  Protected response.s
  Protected requestId.q
  Protected deadline.q
  Protected cancelId.s

  If *dispatcher = 0 Or *connection = 0
    ProcedureReturn #False
  EndIf

  If iterations <= 0
    iterations = 1
  EndIf

  JSONRPC_Trace_Set(*connection, #JSONRPC_Trace_Messages)

  For index = 1 To iterations
    response = JSONRPC_Dispatcher_Dispatch(*dispatcher, *connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"missing\",\"id\":" + Str(index) + "}")
    If FindString(response, ~"\"code\":-32601", 1) = 0
      ProcedureReturn #False
    EndIf

    response = JSONRPC_Batch_Dispatch(*dispatcher, *connection, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"notifications/stress\"}]")
    If response <> ""
      ProcedureReturn #False
    EndIf

    If JSONRPC_Connection_QueueBody(*connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"queued\",\"id\":" + Str(index) + "}") = #False
      ProcedureReturn #False
    EndIf

    If JSONRPC_Connection_FlushWrites(*connection) = #False
      ProcedureReturn #False
    EndIf

    If JSONRPC_Connection_PendingWriteCount(*connection) <> 0
      ProcedureReturn #False
    EndIf

    requestId = JSONRPC_Connection_SendRequest(*connection, "stress/wait", "", 1)
    If requestId = 0
      ProcedureReturn #False
    EndIf

    deadline = JSONRPC_Connection_PendingDeadline(*connection, Str(requestId))
    If JSONRPC_Connection_CleanupTimeouts(*connection, deadline) <> 1
      ProcedureReturn #False
    EndIf

    If JSONRPC_Connection_PendingCount(*connection) <> 0
      ProcedureReturn #False
    EndIf

    cancelId = Str(index)
    JSONRPC_Cancel_Request(*connection, cancelId)
    If JSONRPC_Connection_IsCancellationRequested(*connection, cancelId) = #False
      ProcedureReturn #False
    EndIf

    JSONRPC_Cancel_Clear(*connection, cancelId)
    If JSONRPC_Connection_IsCancellationRequested(*connection, cancelId)
      ProcedureReturn #False
    EndIf

    JSONRPC_Trace_Clear(*connection)
    If JSONRPC_Trace_GetCaptured(*connection) <> ""
      ProcedureReturn #False
    EndIf
  Next

  If JSONRPC_Connection_PendingCount(*connection) <> 0
    ProcedureReturn #False
  EndIf

  If JSONRPC_Connection_PendingWriteCount(*connection) <> 0
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure
