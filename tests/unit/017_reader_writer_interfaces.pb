EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "connection.pbi"

PureUnitOptions(Thread)

ProcedureUnit GenericWriterCapturesAndCountsWrites()
  Protected writer.JSONRPC_Writer

  JSONRPC_Writer_Init(@writer)

  Assert(JSONRPC_Writer_Write(@writer, "one"), "Generic writer should accept first write.")
  Assert(JSONRPC_Writer_Write(@writer, "two"), "Generic writer should accept second write.")
  AssertString(JSONRPC_Writer_GetCaptured(@writer), "onetwo", "Generic writer should capture payloads.")
  Assert(JSONRPC_Writer_GetWriteCount(@writer) = 2, "Generic writer should count writes.")
EndProcedureUnit

ProcedureUnit GenericWriterRejectsClosedOrFailedWrite()
  Protected writer.JSONRPC_Writer

  JSONRPC_Writer_Init(@writer)
  JSONRPC_Writer_FailNextWrite(@writer)

  Assert(JSONRPC_Writer_Write(@writer, "nope") = #False, "Configured write failure should reject one write.")
  Assert(JSONRPC_Writer_GetLastErrorCode(@writer) = #JSONRPC_IO_ErrorWriteFailed, "Failed write should expose IO error.")
  Assert(JSONRPC_Writer_Write(@writer, "ok"), "Writer should recover after fail-next-write.")

  JSONRPC_Writer_Close(@writer)
  Assert(JSONRPC_Writer_Write(@writer, "closed") = #False, "Closed writer should reject writes.")
  Assert(JSONRPC_Writer_GetLastErrorCode(@writer) = #JSONRPC_IO_ErrorClosed, "Closed writer should expose closed error.")
EndProcedureUnit

ProcedureUnit GenericReaderBuffersUntilRead()
  Protected reader.JSONRPC_Reader

  JSONRPC_Reader_Init(@reader)
  JSONRPC_Reader_PushBytes(@reader, "alpha")
  JSONRPC_Reader_PushBytes(@reader, "beta")

  AssertString(JSONRPC_Reader_ReadAvailable(@reader), "alphabeta", "Reader should return all available bytes.")
  AssertString(JSONRPC_Reader_ReadAvailable(@reader), "", "Reader should clear data after read.")
  Assert(reader\readCount = 1, "Reader should count non-empty reads.")
EndProcedureUnit

ProcedureUnit ConnectionUsesGenericWriterShape()
  Protected writer.JSONRPC_Writer
  Protected connection.JSONRPC_Connection

  JSONRPC_Writer_Init(@writer)
  Assert(JSONRPC_Connection_Init(@connection, @writer), "Connection should accept generic writer.")
  Assert(JSONRPC_Connection_SendBody(@connection, "{}"), "Connection should send through generic writer.")
  AssertString(writer\captured, "{}", "Generic writer should receive connection body.")

  JSONRPC_Connection_Close(@connection)
  Assert(JSONRPC_Writer_IsClosed(@writer), "Connection close should close generic writer.")
EndProcedureUnit

ProcedureUnit FakeWriterRemainsCompatibilityAlias()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  Assert(JSONRPC_Connection_Init(@connection, @writer), "Connection should keep accepting fake writer.")
  Assert(JSONRPC_Connection_SendBody(@connection, "compat"), "Fake writer should still work.")
  AssertString(writer\captured, "compat", "Fake writer should preserve captured field.")
  Assert(writer\writeCount = 1, "Fake writer should preserve writeCount field.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
