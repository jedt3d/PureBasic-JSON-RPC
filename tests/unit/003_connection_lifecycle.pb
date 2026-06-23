EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "connection.pbi"

PureUnitOptions(Thread)

ProcedureUnit ConnectionCreateStartsRunning()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)

  Assert(JSONRPC_Connection_Init(@connection, @writer), "Connection should initialize.")
  Assert(JSONRPC_Connection_IsRunning(@connection), "New connection should be running.")
  Assert(JSONRPC_Connection_IsClosed(@connection) = #False, "New connection should not be closed.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit ConnectionCloseIsIdempotent()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  Assert(JSONRPC_Connection_Init(@connection, @writer), "Connection should initialize.")

  Assert(JSONRPC_Connection_Close(@connection), "First close should succeed.")
  Assert(JSONRPC_Connection_Close(@connection), "Second close should also succeed.")
  Assert(JSONRPC_Connection_IsClosed(@connection), "Connection should be closed.")
  Assert(writer\closed, "Closing the connection should close the fake writer.")
EndProcedureUnit

ProcedureUnit ConnectionWriterCapturesOutboundBody()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected body.s

  body = ~"{\"jsonrpc\":\"2.0\",\"method\":\"ping\"}"

  JSONRPC_FakeWriter_Init(@writer)
  Assert(JSONRPC_Connection_Init(@connection, @writer), "Connection should initialize.")

  Assert(JSONRPC_Connection_SendBody(@connection, body), "Connection should send body to fake writer.")
  AssertString(writer\captured, body, "Fake writer should capture body exactly.")
  Assert(writer\writeCount = 1, "Fake writer should count writes.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit ConnectionRejectsWriteAfterClose()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  Assert(JSONRPC_Connection_Init(@connection, @writer), "Connection should initialize.")
  JSONRPC_Connection_Close(@connection)

  Assert(JSONRPC_Connection_SendBody(@connection, "{}") = #False, "Closed connection should reject writes.")
  Assert(JSONRPC_Connection_GetLastErrorCode(@connection) = #JSONRPC_Connection_ErrorClosed, "Closed write should set closed error.")
EndProcedureUnit

ProcedureUnit ConnectionRejectsMissingWriter()
  Protected connection.JSONRPC_Connection

  Assert(JSONRPC_Connection_Init(@connection), "Connection without writer should still initialize.")

  Assert(JSONRPC_Connection_SendBody(@connection, "{}") = #False, "Connection without writer should reject writes.")
  Assert(JSONRPC_Connection_GetLastErrorCode(@connection) = #JSONRPC_Connection_ErrorNoWriter, "Missing writer should set expected error.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

