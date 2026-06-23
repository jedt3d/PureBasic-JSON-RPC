EnableExplicit

XIncludeFile "protocol.pbi"

Declare.q JSONRPC_Connection_SendRequest(*connection.JSONRPC_Connection, method.s, paramsJson.s = "", timeoutMs.i = #JSONRPC_Connection_DefaultTimeoutMs)
Declare.i JSONRPC_Connection_SendNotification(*connection.JSONRPC_Connection, method.s, paramsJson.s = "")
Declare.i JSONRPC_Connection_MatchResponse(*connection.JSONRPC_Connection, body.s)
Declare.i JSONRPC_Connection_CleanupTimeouts(*connection.JSONRPC_Connection, nowMs.q)
Declare.i JSONRPC_Connection_PendingCount(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Connection_HasPending(*connection.JSONRPC_Connection, idText.s)
Declare.q JSONRPC_Connection_GetNextId(*connection.JSONRPC_Connection)
Declare.s JSONRPC_Connection_GetLastMatchedIdText(*connection.JSONRPC_Connection)
Declare.s JSONRPC_Connection_GetLastResponseBody(*connection.JSONRPC_Connection)
Declare.s JSONRPC_Connection_GetLastTimedOutIdText(*connection.JSONRPC_Connection)
Declare.q JSONRPC_Connection_PendingDeadline(*connection.JSONRPC_Connection, idText.s)

Procedure.i JSONRPC_Connection_ValidateOutbound(*connection.JSONRPC_Connection, method.s, paramsJson.s)
  If method = ""
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorInvalidMethod, "Method name is required.")
    ProcedureReturn #False
  EndIf

  If JSONRPC_Protocol_IsValidParamsJson(paramsJson) = #False
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorInvalidParams, "Params must be a JSON object or array.")
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.q JSONRPC_Connection_SendRequest(*connection.JSONRPC_Connection, method.s, paramsJson.s = "", timeoutMs.i = #JSONRPC_Connection_DefaultTimeoutMs)
  Protected id.q
  Protected idText.s
  Protected body.s
  Protected createdAtMs.q

  If JSONRPC_Connection_ValidateOutbound(*connection, method, paramsJson) = #False
    ProcedureReturn 0
  EndIf

  If timeoutMs <= 0
    timeoutMs = #JSONRPC_Connection_DefaultTimeoutMs
  EndIf

  id = *connection\nextId
  If id < 1
    id = 1
  EndIf

  idText = Str(id)
  body = JSONRPC_Protocol_BuildRequest(method, paramsJson, idText)

  AddMapElement(*connection\pending(), idText)
  *connection\pending()\idText = idText
  *connection\pending()\method = method
  createdAtMs = ElapsedMilliseconds()
  *connection\pending()\createdAtMs = createdAtMs
  *connection\pending()\timeoutMs = timeoutMs
  *connection\pending()\deadlineMs = createdAtMs + timeoutMs

  If JSONRPC_Connection_SendBody(*connection, body) = #False
    DeleteMapElement(*connection\pending())
    ProcedureReturn 0
  EndIf

  *connection\nextId = id + 1
  JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorNone, "")
  ProcedureReturn id
EndProcedure

Procedure.i JSONRPC_Connection_SendNotification(*connection.JSONRPC_Connection, method.s, paramsJson.s = "")
  Protected body.s

  If JSONRPC_Connection_ValidateOutbound(*connection, method, paramsJson) = #False
    ProcedureReturn #False
  EndIf

  body = JSONRPC_Protocol_BuildNotification(method, paramsJson)
  ProcedureReturn JSONRPC_Connection_SendBody(*connection, body)
EndProcedure

Procedure.i JSONRPC_Connection_MatchResponse(*connection.JSONRPC_Connection, body.s)
  Protected inspect.JSONRPC_ProtocolResult

  If JSONRPC_Protocol_Inspect(body, @inspect) = #False
    ProcedureReturn #False
  EndIf

  If inspect\messageType <> #JSONRPC_MessageTypeResponse
    ProcedureReturn #False
  EndIf

  If FindMapElement(*connection\pending(), inspect\idText) = #False
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorOrphanResponse, "Response did not match a pending request.")
    ProcedureReturn #False
  EndIf

  DeleteMapElement(*connection\pending())
  *connection\lastMatchedIdText = inspect\idText
  *connection\lastResponseBody = body
  JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorNone, "")
  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_Connection_CleanupTimeouts(*connection.JSONRPC_Connection, nowMs.q)
  Protected expired.i

  If nowMs <= 0
    nowMs = ElapsedMilliseconds()
  EndIf

  ForEach *connection\pending()
    If *connection\pending()\deadlineMs > 0 And nowMs >= *connection\pending()\deadlineMs
      *connection\lastTimedOutIdText = *connection\pending()\idText
      DeleteMapElement(*connection\pending())
      expired + 1
    EndIf
  Next

  If expired > 0
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorTimeout, "Pending request timed out.")
  Else
    JSONRPC_Connection_SetError(*connection, #JSONRPC_Connection_ErrorNone, "")
  EndIf

  ProcedureReturn expired
EndProcedure

Procedure.i JSONRPC_Connection_PendingCount(*connection.JSONRPC_Connection)
  ProcedureReturn MapSize(*connection\pending())
EndProcedure

Procedure.i JSONRPC_Connection_HasPending(*connection.JSONRPC_Connection, idText.s)
  ProcedureReturn FindMapElement(*connection\pending(), idText)
EndProcedure

Procedure.q JSONRPC_Connection_GetNextId(*connection.JSONRPC_Connection)
  ProcedureReturn *connection\nextId
EndProcedure

Procedure.s JSONRPC_Connection_GetLastMatchedIdText(*connection.JSONRPC_Connection)
  ProcedureReturn *connection\lastMatchedIdText
EndProcedure

Procedure.s JSONRPC_Connection_GetLastResponseBody(*connection.JSONRPC_Connection)
  ProcedureReturn *connection\lastResponseBody
EndProcedure

Procedure.s JSONRPC_Connection_GetLastTimedOutIdText(*connection.JSONRPC_Connection)
  ProcedureReturn *connection\lastTimedOutIdText
EndProcedure

Procedure.q JSONRPC_Connection_PendingDeadline(*connection.JSONRPC_Connection, idText.s)
  If FindMapElement(*connection\pending(), idText)
    ProcedureReturn *connection\pending()\deadlineMs
  EndIf

  ProcedureReturn 0
EndProcedure
