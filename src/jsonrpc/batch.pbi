EnableExplicit

XIncludeFile "dispatch.pbi"

Declare.s JSONRPC_Batch_Dispatch(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)
Declare.i JSONRPC_Batch_DispatchToConnection(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)
Declare.i JSONRPC_Batch_IsBatch(body.s)
Declare.s JSONRPC_Batch_SerializeValue(value)

Procedure.i JSONRPC_Batch_IsBatch(body.s)
  Protected json.i
  Protected root
  Protected isBatch.i

  json = ParseJSON(#PB_Any, body)
  If json = 0
    ProcedureReturn #False
  EndIf

  root = JSONValue(json)
  isBatch = Bool(JSONType(root) = #PB_JSON_Array)
  FreeJSON(json)

  ProcedureReturn isBatch
EndProcedure

Procedure.s JSONRPC_Batch_SerializeNumber(value)
  Protected number.d
  Protected integer.q

  number = GetJSONDouble(value)
  integer = GetJSONQuad(value)

  If number = integer
    ProcedureReturn Str(integer)
  EndIf

  ProcedureReturn StrD(number)
EndProcedure

Procedure.s JSONRPC_Batch_SerializeArray(value)
  Protected output.s
  Protected index.i
  Protected count.i

  count = JSONArraySize(value)
  If count = 0
    ProcedureReturn "[]"
  EndIf

  For index = 0 To count - 1
    If index > 0
      output + ","
    EndIf

    output + JSONRPC_Batch_SerializeValue(GetJSONElement(value, index))
  Next

  ProcedureReturn "[" + output + "]"
EndProcedure

Procedure.s JSONRPC_Batch_SerializeObject(value)
  Protected output.s
  Protected memberValue
  Protected count.i

  If ExamineJSONMembers(value)
    While NextJSONMember(value)
      memberValue = JSONMemberValue(value)
      If count > 0
        output + ","
      EndIf

      output + #DQUOTE$ + JSONRPC_Protocol_EscapeString(JSONMemberKey(value)) + ~"\":"
      output + JSONRPC_Batch_SerializeValue(memberValue)
      count + 1
    Wend
  EndIf

  ProcedureReturn "{" + output + "}"
EndProcedure

Procedure.s JSONRPC_Batch_SerializeValue(value)
  If value = 0
    ProcedureReturn "null"
  EndIf

  Select JSONType(value)
    Case #PB_JSON_Object
      ProcedureReturn JSONRPC_Batch_SerializeObject(value)
    Case #PB_JSON_Array
      ProcedureReturn JSONRPC_Batch_SerializeArray(value)
    Case #PB_JSON_String
      ProcedureReturn #DQUOTE$ + JSONRPC_Protocol_EscapeString(GetJSONString(value)) + #DQUOTE$
    Case #PB_JSON_Number
      ProcedureReturn JSONRPC_Batch_SerializeNumber(value)
    Case #PB_JSON_Boolean
      If GetJSONBoolean(value)
        ProcedureReturn "true"
      EndIf

      ProcedureReturn "false"
    Case #PB_JSON_Null
      ProcedureReturn "null"
  EndSelect

  ProcedureReturn "null"
EndProcedure

Procedure.s JSONRPC_Batch_Dispatch(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)
  Protected json.i
  Protected root
  Protected item
  Protected itemBody.s
  Protected response.s
  Protected responses.s
  Protected responseCount.i
  Protected index.i

  json = ParseJSON(#PB_Any, body)
  If json = 0
    ProcedureReturn JSONRPC_Protocol_BuildErrorResponse(#JSONRPC_Error_Parse, "Parse error", "null")
  EndIf

  root = JSONValue(json)
  If JSONType(root) <> #PB_JSON_Array
    FreeJSON(json)
    ProcedureReturn JSONRPC_Dispatcher_Dispatch(*dispatcher, *connection, body)
  EndIf

  If JSONArraySize(root) = 0
    FreeJSON(json)
    ProcedureReturn JSONRPC_Protocol_BuildErrorResponse(#JSONRPC_Error_InvalidRequest, "Invalid Request", "null")
  EndIf

  For index = 0 To JSONArraySize(root) - 1
    item = GetJSONElement(root, index)
    itemBody = JSONRPC_Batch_SerializeValue(item)
    response = JSONRPC_Dispatcher_Dispatch(*dispatcher, *connection, itemBody)

    If response <> ""
      If responseCount > 0
        responses + ","
      EndIf

      responses + response
      responseCount + 1
    EndIf
  Next

  FreeJSON(json)

  If responseCount = 0
    ProcedureReturn ""
  EndIf

  ProcedureReturn "[" + responses + "]"
EndProcedure

Procedure.i JSONRPC_Batch_DispatchToConnection(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)
  Protected response.s

  response = JSONRPC_Batch_Dispatch(*dispatcher, *connection, body)
  If response = ""
    ProcedureReturn #True
  EndIf

  ProcedureReturn JSONRPC_Connection_SendBody(*connection, response)
EndProcedure
