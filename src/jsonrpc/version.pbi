EnableExplicit

#JSONRPC_Library_Name$ = "PureBasic JSON-RPC 2.0"
#JSONRPC_Library_Version$ = "0.1.0-alpha.1"
#JSONRPC_Library_Status$ = "alpha"

Declare.s JSONRPC_LibraryName()
Declare.s JSONRPC_LibraryVersion()
Declare.s JSONRPC_LibraryStatus()

Procedure.s JSONRPC_LibraryName()
  ProcedureReturn #JSONRPC_Library_Name$
EndProcedure

Procedure.s JSONRPC_LibraryVersion()
  ProcedureReturn #JSONRPC_Library_Version$
EndProcedure

Procedure.s JSONRPC_LibraryStatus()
  ProcedureReturn #JSONRPC_Library_Status$
EndProcedure
