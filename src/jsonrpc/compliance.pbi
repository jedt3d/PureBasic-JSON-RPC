EnableExplicit

XIncludeFile "trace.pbi"

Structure JSONRPC_ComplianceReport
  passed.i
  failed.i
  lastFailure.s
EndStructure

Declare JSONRPC_Compliance_Reset(*report.JSONRPC_ComplianceReport)
Declare.i JSONRPC_Compliance_Assert(*report.JSONRPC_ComplianceReport, condition.i, failure.s)
Declare.i JSONRPC_Compliance_RunCore(*report.JSONRPC_ComplianceReport)
Declare.s JSONRPC_Compliance_Summary(*report.JSONRPC_ComplianceReport)

Procedure.i JSONRPC_Compliance_SubtractHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected leftValue
  Protected rightValue
  Protected left.q
  Protected right.q

  If paramsValue = 0 Or JSONType(paramsValue) <> #PB_JSON_Array Or JSONArraySize(paramsValue) <> 2
    *result\ok = #False
    *result\errorCode = #JSONRPC_Error_InvalidParams
    *result\errorMessage = "Expected two numeric params"
    ProcedureReturn #True
  EndIf

  leftValue = GetJSONElement(paramsValue, 0)
  rightValue = GetJSONElement(paramsValue, 1)
  If JSONType(leftValue) <> #PB_JSON_Number Or JSONType(rightValue) <> #PB_JSON_Number
    *result\ok = #False
    *result\errorCode = #JSONRPC_Error_InvalidParams
    *result\errorMessage = "Expected numeric params"
    ProcedureReturn #True
  EndIf

  left = GetJSONQuad(leftValue)
  right = GetJSONQuad(rightValue)
  *result\ok = #True
  *result\resultJson = Str(left - right)
  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_Compliance_UpdateHandler(paramsValue, *context.JSONRPC_RequestContext)
  ProcedureReturn #True
EndProcedure

Procedure JSONRPC_Compliance_Reset(*report.JSONRPC_ComplianceReport)
  *report\passed = 0
  *report\failed = 0
  *report\lastFailure = ""
EndProcedure

Procedure.i JSONRPC_Compliance_Assert(*report.JSONRPC_ComplianceReport, condition.i, failure.s)
  If condition
    *report\passed + 1
    ProcedureReturn #True
  EndIf

  *report\failed + 1
  *report\lastFailure = failure
  ProcedureReturn #False
EndProcedure

Procedure.i JSONRPC_Compliance_RunCore(*report.JSONRPC_ComplianceReport)
  Protected dispatcher.JSONRPC_Dispatcher
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection
  Protected response.s
  Protected id.q

  JSONRPC_Compliance_Reset(*report)
  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_RegisterRequest(@dispatcher, "subtract", @JSONRPC_Compliance_SubtractHandler())
  JSONRPC_RegisterNotification(@dispatcher, "update", @JSONRPC_Compliance_UpdateHandler())
  JSONRPC_Writer_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"subtract\",\"params\":[42,23],\"id\":1}")
  JSONRPC_Compliance_Assert(*report, Bool(FindString(response, ~"\"result\":19", 1) > 0), "official subtract example should return 19")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"subtract\",\"params\":[23,42],\"id\":2}")
  JSONRPC_Compliance_Assert(*report, Bool(FindString(response, ~"\"result\":-19", 1) > 0), "official subtract example should return -19")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"update\",\"params\":[1,2,3,4,5]}")
  JSONRPC_Compliance_Assert(*report, Bool(response = ""), "notification should produce no response")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"foobar\",\"id\":\"1\"}")
  JSONRPC_Compliance_Assert(*report, Bool(FindString(response, ~"\"code\":-32601", 1) > 0 And FindString(response, ~"\"id\":\"1\"", 1) > 0), "unknown request should return method not found with original id")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, @connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"foobar")
  JSONRPC_Compliance_Assert(*report, Bool(FindString(response, ~"\"code\":-32700", 1) > 0 And FindString(response, ~"\"id\":null", 1) > 0), "parse error should return null id")

  response = JSONRPC_Batch_Dispatch(@dispatcher, @connection, "[]")
  JSONRPC_Compliance_Assert(*report, Bool(FindString(response, ~"\"code\":-32600", 1) > 0), "empty batch should return invalid request")

  response = JSONRPC_Batch_Dispatch(@dispatcher, @connection, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"update\",\"params\":[1]}]")
  JSONRPC_Compliance_Assert(*report, Bool(response = ""), "notification-only batch should produce no response")

  response = JSONRPC_Batch_Dispatch(@dispatcher, @connection, ~"[{\"jsonrpc\":\"2.0\",\"method\":\"subtract\",\"params\":[5,3],\"id\":3},{\"jsonrpc\":\"2.0\",\"method\":\"update\",\"params\":[1]},{\"jsonrpc\":\"2.0\",\"method\":\"missing\",\"id\":4}]")
  JSONRPC_Compliance_Assert(*report, Bool(FindString(response, ~"\"result\":2", 1) > 0 And FindString(response, ~"\"code\":-32601", 1) > 0 And FindString(response, "update", 1) = 0), "mixed batch should include only required responses")

  id = JSONRPC_Connection_SendRequest(@connection, "subtract", ~"[10,3]")
  response = ~"{\"jsonrpc\":\"2.0\",\"result\":7,\"id\":" + Str(id) + "}"
  JSONRPC_Compliance_Assert(*report, JSONRPC_Connection_MatchResponse(@connection, response), "response should match pending request id")

  JSONRPC_Connection_Close(@connection)
  ProcedureReturn Bool(*report\failed = 0)
EndProcedure

Procedure.s JSONRPC_Compliance_Summary(*report.JSONRPC_ComplianceReport)
  ProcedureReturn ~"{\"passed\":" + Str(*report\passed) + ~",\"failed\":" + Str(*report\failed) + ~",\"lastFailure\":\"" + JSONRPC_Protocol_EscapeString(*report\lastFailure) + ~"\"}"
EndProcedure
