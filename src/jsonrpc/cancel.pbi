EnableExplicit

XIncludeFile "batch.pbi"

#JSONRPC_Cancel_Method$ = "$/cancelRequest"

Declare.i JSONRPC_Cancel_Request(*connection.JSONRPC_Connection, idText.s)
Declare.i JSONRPC_Cancel_IsRequested(*connection.JSONRPC_Connection, idText.s)
Declare.i JSONRPC_Cancel_Clear(*connection.JSONRPC_Connection, idText.s)
Declare.s JSONRPC_Cancel_GetLastCancelledIdText(*connection.JSONRPC_Connection)
Declare.i JSONRPC_Cancel_ProcessNotification(*connection.JSONRPC_Connection, body.s)

Procedure.i JSONRPC_Cancel_Request(*connection.JSONRPC_Connection, idText.s)
  If *connection = 0 Or idText = ""
    ProcedureReturn #False
  EndIf

  AddMapElement(*connection\cancellations(), idText)
  *connection\cancellations()\idText = idText
  *connection\cancellations()\requested = #True
  *connection\lastCancelledIdText = idText
  *connection\diagnostics\cancellations + 1

  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_Cancel_IsRequested(*connection.JSONRPC_Connection, idText.s)
  If *connection = 0 Or idText = ""
    ProcedureReturn #False
  EndIf

  If FindMapElement(*connection\cancellations(), idText)
    ProcedureReturn *connection\cancellations()\requested
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i JSONRPC_Cancel_Clear(*connection.JSONRPC_Connection, idText.s)
  If *connection = 0 Or idText = ""
    ProcedureReturn #False
  EndIf

  If FindMapElement(*connection\cancellations(), idText)
    DeleteMapElement(*connection\cancellations())
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.s JSONRPC_Cancel_GetLastCancelledIdText(*connection.JSONRPC_Connection)
  If *connection = 0
    ProcedureReturn ""
  EndIf

  ProcedureReturn *connection\lastCancelledIdText
EndProcedure

Procedure.s JSONRPC_Cancel_IdText(value)
  If value = 0
    ProcedureReturn ""
  EndIf

  If JSONRPC_Protocol_IsValidIdValue(value)
    ProcedureReturn JSONRPC_Protocol_IdText(value)
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.i JSONRPC_Cancel_ProcessNotification(*connection.JSONRPC_Connection, body.s)
  Protected inspect.JSONRPC_ProtocolResult
  Protected json.i
  Protected root
  Protected params
  Protected idValue
  Protected idText.s

  If JSONRPC_Protocol_Inspect(body, @inspect) = #False
    ProcedureReturn #False
  EndIf

  If inspect\messageType <> #JSONRPC_MessageTypeNotification Or inspect\method <> #JSONRPC_Cancel_Method$
    ProcedureReturn #False
  EndIf

  json = ParseJSON(#PB_Any, body)
  If json = 0
    ProcedureReturn #False
  EndIf

  root = JSONValue(json)
  params = GetJSONMember(root, "params")
  If params <> 0 And JSONType(params) = #PB_JSON_Object
    idValue = GetJSONMember(params, "id")
    idText = JSONRPC_Cancel_IdText(idValue)
  EndIf

  FreeJSON(json)

  If idText = ""
    ProcedureReturn #False
  EndIf

  ProcedureReturn JSONRPC_Cancel_Request(*connection, idText)
EndProcedure
