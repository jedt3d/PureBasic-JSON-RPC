EnableExplicit

XIncludeFile "../../src/jsonrpc/trace.pbi"

Define writer.JSONRPC_Writer
Define connection.JSONRPC_Connection
Define trace.s

JSONRPC_Writer_Init(@writer)
JSONRPC_Connection_Init(@connection, @writer)
JSONRPC_Trace_Set(@connection, #JSONRPC_Trace_Messages)

JSONRPC_Connection_SendBody(@connection, ~"{\"jsonrpc\":\"2.0\",\"method\":\"probe\"}")
trace = JSONRPC_Trace_GetCaptured(@connection)

If FindString(trace, "sent message bytes=", 1) = 0
  PrintN("trace metadata was not captured")
  End 1
EndIf

If FindString(trace, "probe", 1) > 0
  PrintN("trace included payload when payload tracing was disabled")
  End 1
EndIf

JSONRPC_Connection_Close(@connection)

PrintN("trace logger hooks scenario: OK")
End 0
