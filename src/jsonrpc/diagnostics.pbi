EnableExplicit

XIncludeFile "cancel.pbi"
XIncludeFile "outbound.pbi"

Declare JSONRPC_Diagnostics_Reset(*connection.JSONRPC_Connection)
Declare JSONRPC_Diagnostics_Copy(*connection.JSONRPC_Connection, *diagnostics.JSONRPC_Diagnostics)
Declare.s JSONRPC_Diagnostics_Summary(*connection.JSONRPC_Connection)

Procedure JSONRPC_Diagnostics_Reset(*connection.JSONRPC_Connection)
  If *connection = 0
    ProcedureReturn
  EndIf

  *connection\diagnostics\receivedMessages = 0
  *connection\diagnostics\sentMessages = 0
  *connection\diagnostics\errors = 0
  *connection\diagnostics\timeouts = 0
  *connection\diagnostics\orphanResponses = 0
  *connection\diagnostics\batches = 0
  *connection\diagnostics\cancellations = 0
EndProcedure

Procedure JSONRPC_Diagnostics_Copy(*connection.JSONRPC_Connection, *diagnostics.JSONRPC_Diagnostics)
  If *connection = 0 Or *diagnostics = 0
    ProcedureReturn
  EndIf

  *diagnostics\receivedMessages = *connection\diagnostics\receivedMessages
  *diagnostics\sentMessages = *connection\diagnostics\sentMessages
  *diagnostics\errors = *connection\diagnostics\errors
  *diagnostics\timeouts = *connection\diagnostics\timeouts
  *diagnostics\orphanResponses = *connection\diagnostics\orphanResponses
  *diagnostics\batches = *connection\diagnostics\batches
  *diagnostics\cancellations = *connection\diagnostics\cancellations
EndProcedure

Procedure.s JSONRPC_Diagnostics_Summary(*connection.JSONRPC_Connection)
  If *connection = 0
    ProcedureReturn "{}"
  EndIf

  ProcedureReturn ~"{\"receivedMessages\":" + Str(*connection\diagnostics\receivedMessages) +
                  ~",\"sentMessages\":" + Str(*connection\diagnostics\sentMessages) +
                  ~",\"errors\":" + Str(*connection\diagnostics\errors) +
                  ~",\"timeouts\":" + Str(*connection\diagnostics\timeouts) +
                  ~",\"orphanResponses\":" + Str(*connection\diagnostics\orphanResponses) +
                  ~",\"batches\":" + Str(*connection\diagnostics\batches) +
                  ~",\"cancellations\":" + Str(*connection\diagnostics\cancellations) + "}"
EndProcedure
