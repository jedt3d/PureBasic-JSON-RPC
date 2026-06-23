EnableExplicit

XIncludeFile "../../src/jsonrpc/jsonrpc.pbi"

Define writer.JSONRPC_Writer
Define connection.JSONRPC_Connection
Define trace.s
Define body.s = ~"{\"jsonrpc\":\"2.0\",\"method\":\"secret\",\"params\":{\"token\":\"hidden\"},\"id\":1}"

JSONRPC_Writer_Init(@writer)
JSONRPC_Connection_Init(@connection, @writer)
JSONRPC_Trace_Set(@connection, #JSONRPC_Trace_Messages)

JSONRPC_Connection_SendBody(@connection, body)
trace = JSONRPC_Trace_GetCaptured(@connection)

If FindString(trace, "hidden", 1) > 0
  PrintN("trace leaked payload without opt-in")
  End 1
EndIf

JSONRPC_Writer_FailNextWrite(@writer)
If JSONRPC_Connection_SendBody(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"fail\"}")
  PrintN("forced write failure was not reported")
  End 1
EndIf

If JSONRPC_Connection_PendingWriteCount(@connection) <> 0
  PrintN("failed write left queued body")
  End 1
EndIf

If JSONRPC_Connection_SendBody(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"recover\"}") = #False
  PrintN("writer did not recover after forced failure")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("security robustness scenario: OK")
End 0
