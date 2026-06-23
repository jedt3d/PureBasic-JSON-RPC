EnableExplicit

XIncludeFile "connection.pbi"

#JSONRPC_Protocol_Version$ = "2.0"

#JSONRPC_Error_Parse = -32700
#JSONRPC_Error_InvalidRequest = -32600
#JSONRPC_Error_MethodNotFound = -32601
#JSONRPC_Error_InvalidParams = -32602
#JSONRPC_Error_Internal = -32603

Enumeration
  #JSONRPC_MessageTypeUnknown = 0
  #JSONRPC_MessageTypeRequest
  #JSONRPC_MessageTypeNotification
  #JSONRPC_MessageTypeResponse
EndEnumeration

Structure JSONRPC_ProtocolResult
  valid.i
  messageType.i
  requiresResponse.i
  method.s
  idText.s
  hasId.i
  errorCode.i
  errorMessage.s
EndStructure

Declare JSONRPC_Protocol_ResetResult(*result.JSONRPC_ProtocolResult)
Declare.i JSONRPC_Protocol_Inspect(body.s, *result.JSONRPC_ProtocolResult)
Declare.i JSONRPC_Protocol_IsValidParamsJson(paramsJson.s)
Declare.s JSONRPC_Protocol_BuildRequest(method.s, paramsJson.s, idText.s)
Declare.s JSONRPC_Protocol_BuildNotification(method.s, paramsJson.s)
Declare.s JSONRPC_Protocol_BuildErrorResponse(errorCode.i, message.s, idText.s)
Declare.s JSONRPC_Protocol_BuildResultResponse(resultJson.s, idText.s)
Declare.s JSONRPC_Protocol_BuildMethodNotFoundResponse(idText.s)

Procedure.s JSONRPC_Protocol_EscapeString(text.s)
  Protected escaped.s

  escaped = ReplaceString(text, "\", "\\")
  escaped = ReplaceString(escaped, #DQUOTE$, "\" + #DQUOTE$)
  escaped = ReplaceString(escaped, #CR$, "\r")
  escaped = ReplaceString(escaped, #LF$, "\n")
  escaped = ReplaceString(escaped, #TAB$, "\t")

  ProcedureReturn escaped
EndProcedure

Procedure JSONRPC_Protocol_SetError(*result.JSONRPC_ProtocolResult, code.i, message.s, idText.s = "null")
  *result\valid = #False
  *result\messageType = #JSONRPC_MessageTypeUnknown
  *result\requiresResponse = #True
  *result\method = ""
  *result\idText = idText
  *result\errorCode = code
  *result\errorMessage = message
EndProcedure

Procedure.i JSONRPC_Protocol_IsValidIdValue(value)
  If value = 0
    ProcedureReturn #False
  EndIf

  Select JSONType(value)
    Case #PB_JSON_String, #PB_JSON_Number, #PB_JSON_Null
      ProcedureReturn #True
  EndSelect

  ProcedureReturn #False
EndProcedure

Procedure.s JSONRPC_Protocol_IdText(value)
  If value = 0
    ProcedureReturn "null"
  EndIf

  Select JSONType(value)
    Case #PB_JSON_String
      ProcedureReturn #DQUOTE$ + JSONRPC_Protocol_EscapeString(GetJSONString(value)) + #DQUOTE$
    Case #PB_JSON_Number
      ProcedureReturn Str(GetJSONQuad(value))
    Case #PB_JSON_Null
      ProcedureReturn "null"
  EndSelect

  ProcedureReturn "null"
EndProcedure

Procedure JSONRPC_Protocol_ResetResult(*result.JSONRPC_ProtocolResult)
  *result\valid = #False
  *result\messageType = #JSONRPC_MessageTypeUnknown
  *result\requiresResponse = #False
  *result\method = ""
  *result\idText = "null"
  *result\hasId = #False
  *result\errorCode = #JSONRPC_Error_InvalidRequest
  *result\errorMessage = ""
EndProcedure

Procedure.i JSONRPC_Protocol_Inspect(body.s, *result.JSONRPC_ProtocolResult)
  Protected json.i
  Protected root
  Protected version
  Protected method
  Protected params
  Protected id
  Protected resultValue
  Protected errorValue
  Protected hasResult.i
  Protected hasError.i
  Protected invalidId.i

  JSONRPC_Protocol_ResetResult(*result)

  json = ParseJSON(#PB_Any, body)
  If json = 0
    JSONRPC_Protocol_SetError(*result, #JSONRPC_Error_Parse, "Parse error", "null")
    ProcedureReturn #False
  EndIf

  root = JSONValue(json)

  If JSONType(root) <> #PB_JSON_Object
    JSONRPC_Protocol_SetError(*result, #JSONRPC_Error_InvalidRequest, "Invalid Request", "null")
    FreeJSON(json)
    ProcedureReturn #False
  EndIf

  id = GetJSONMember(root, "id")
  If id <> 0
    If JSONRPC_Protocol_IsValidIdValue(id)
      *result\hasId = #True
      *result\idText = JSONRPC_Protocol_IdText(id)
    Else
      invalidId = #True
      *result\hasId = #False
      *result\idText = "null"
    EndIf
  EndIf

  version = GetJSONMember(root, "jsonrpc")
  If version = 0 Or JSONType(version) <> #PB_JSON_String Or GetJSONString(version) <> #JSONRPC_Protocol_Version$
    JSONRPC_Protocol_SetError(*result, #JSONRPC_Error_InvalidRequest, "Invalid Request", *result\idText)
    FreeJSON(json)
    ProcedureReturn #False
  EndIf

  If invalidId
    JSONRPC_Protocol_SetError(*result, #JSONRPC_Error_InvalidRequest, "Invalid Request", "null")
    FreeJSON(json)
    ProcedureReturn #False
  EndIf

  method = GetJSONMember(root, "method")
  resultValue = GetJSONMember(root, "result")
  errorValue = GetJSONMember(root, "error")
  hasResult = Bool(resultValue <> 0)
  hasError = Bool(errorValue <> 0)

  If method <> 0
    If JSONType(method) <> #PB_JSON_String
      JSONRPC_Protocol_SetError(*result, #JSONRPC_Error_InvalidRequest, "Invalid Request", *result\idText)
      FreeJSON(json)
      ProcedureReturn #False
    EndIf

    params = GetJSONMember(root, "params")
    If params <> 0 And JSONType(params) <> #PB_JSON_Object And JSONType(params) <> #PB_JSON_Array
      JSONRPC_Protocol_SetError(*result, #JSONRPC_Error_InvalidParams, "Invalid params", *result\idText)
      FreeJSON(json)
      ProcedureReturn #False
    EndIf

    *result\valid = #True
    *result\method = GetJSONString(method)

    If *result\hasId
      *result\messageType = #JSONRPC_MessageTypeRequest
      *result\requiresResponse = #True
    Else
      *result\messageType = #JSONRPC_MessageTypeNotification
      *result\requiresResponse = #False
    EndIf

    *result\errorCode = #JSONRPC_Connection_ErrorNone
    *result\errorMessage = ""
    FreeJSON(json)
    ProcedureReturn #True
  EndIf

  If hasResult Or hasError
    If *result\hasId = #False Or hasResult = hasError
      JSONRPC_Protocol_SetError(*result, #JSONRPC_Error_InvalidRequest, "Invalid Request", "null")
      FreeJSON(json)
      ProcedureReturn #False
    EndIf

    If hasError And JSONType(errorValue) <> #PB_JSON_Object
      JSONRPC_Protocol_SetError(*result, #JSONRPC_Error_InvalidRequest, "Invalid Request", *result\idText)
      FreeJSON(json)
      ProcedureReturn #False
    EndIf

    *result\valid = #True
    *result\messageType = #JSONRPC_MessageTypeResponse
    *result\requiresResponse = #False
    *result\errorCode = #JSONRPC_Connection_ErrorNone
    *result\errorMessage = ""
    FreeJSON(json)
    ProcedureReturn #True
  EndIf

  JSONRPC_Protocol_SetError(*result, #JSONRPC_Error_InvalidRequest, "Invalid Request", *result\idText)
  FreeJSON(json)
  ProcedureReturn #False
EndProcedure

Procedure.i JSONRPC_Protocol_IsValidParamsJson(paramsJson.s)
  Protected json.i
  Protected root
  Protected valid.i

  If paramsJson = ""
    ProcedureReturn #True
  EndIf

  json = ParseJSON(#PB_Any, paramsJson)
  If json = 0
    ProcedureReturn #False
  EndIf

  root = JSONValue(json)
  valid = Bool(JSONType(root) = #PB_JSON_Object Or JSONType(root) = #PB_JSON_Array)
  FreeJSON(json)

  ProcedureReturn valid
EndProcedure

Procedure.s JSONRPC_Protocol_ParamsFragment(paramsJson.s)
  If paramsJson = ""
    ProcedureReturn ""
  EndIf

  ProcedureReturn ~",\"params\":" + paramsJson
EndProcedure

Procedure.s JSONRPC_Protocol_BuildRequest(method.s, paramsJson.s, idText.s)
  If idText = ""
    idText = "null"
  EndIf

  ProcedureReturn ~"{\"jsonrpc\":\"2.0\",\"method\":\"" + JSONRPC_Protocol_EscapeString(method) + ~"\"" + JSONRPC_Protocol_ParamsFragment(paramsJson) + ~",\"id\":" + idText + "}"
EndProcedure

Procedure.s JSONRPC_Protocol_BuildNotification(method.s, paramsJson.s)
  ProcedureReturn ~"{\"jsonrpc\":\"2.0\",\"method\":\"" + JSONRPC_Protocol_EscapeString(method) + ~"\"" + JSONRPC_Protocol_ParamsFragment(paramsJson) + "}"
EndProcedure

Procedure.s JSONRPC_Protocol_BuildErrorResponse(errorCode.i, message.s, idText.s)
  If idText = ""
    idText = "null"
  EndIf

  ProcedureReturn ~"{\"jsonrpc\":\"2.0\",\"error\":{\"code\":" + Str(errorCode) + ~",\"message\":\"" + JSONRPC_Protocol_EscapeString(message) + ~"\"},\"id\":" + idText + "}"
EndProcedure

Procedure.s JSONRPC_Protocol_BuildResultResponse(resultJson.s, idText.s)
  If idText = ""
    idText = "null"
  EndIf

  If resultJson = ""
    resultJson = "null"
  EndIf

  ProcedureReturn ~"{\"jsonrpc\":\"2.0\",\"result\":" + resultJson + ~",\"id\":" + idText + "}"
EndProcedure

Procedure.s JSONRPC_Protocol_BuildMethodNotFoundResponse(idText.s)
  ProcedureReturn JSONRPC_Protocol_BuildErrorResponse(#JSONRPC_Error_MethodNotFound, "Method not found", idText)
EndProcedure
