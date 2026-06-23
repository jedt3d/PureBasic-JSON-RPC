EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "outbound.pbi"

PureUnitOptions(Thread)

ProcedureUnit DefaultTimeoutSetsDeadline()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected id.q
  Protected deadline.q

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  id = JSONRPC_Connection_SendRequest(@connection, "tools/list", "")
  deadline = JSONRPC_Connection_PendingDeadline(@connection, Str(id))

  Assert(id = 1, "Request should be sent.")
  Assert(deadline > 0, "Request should record a deadline.")
  Assert(JSONRPC_Connection_CleanupTimeouts(@connection, deadline - 1) = 0, "Request should remain pending before deadline.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 1, "Request should still be pending.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit CustomTimeoutExpiresPendingRequest()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected id.q
  Protected deadline.q

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  id = JSONRPC_Connection_SendRequest(@connection, "tools/list", "", 25)
  deadline = JSONRPC_Connection_PendingDeadline(@connection, Str(id))

  Assert(JSONRPC_Connection_CleanupTimeouts(@connection, deadline) = 1, "Request should expire at deadline.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Expired request should be removed.")
  AssertString(JSONRPC_Connection_GetLastTimedOutIdText(@connection), "1", "Timeout cleanup should record id.")
  Assert(JSONRPC_Connection_GetLastErrorCode(@connection) = #JSONRPC_Connection_ErrorTimeout, "Timeout should set error state.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit TimeoutDoesNotRemoveFreshRequest()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected firstId.q
  Protected secondId.q
  Protected firstDeadline.q

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  firstId = JSONRPC_Connection_SendRequest(@connection, "tools/slow", "", 10)
  secondId = JSONRPC_Connection_SendRequest(@connection, "tools/fast", "", 60000)
  firstDeadline = JSONRPC_Connection_PendingDeadline(@connection, Str(firstId))

  Assert(JSONRPC_Connection_CleanupTimeouts(@connection, firstDeadline) = 1, "Only the first request should expire.")
  Assert(JSONRPC_Connection_HasPending(@connection, Str(secondId)), "Fresh request should remain pending.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 1, "One pending request should remain.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit MatchedResponseAvoidsTimeout()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected id.q
  Protected deadline.q

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  id = JSONRPC_Connection_SendRequest(@connection, "tools/echo", "", 10)
  deadline = JSONRPC_Connection_PendingDeadline(@connection, Str(id))

  Assert(JSONRPC_Connection_MatchResponse(@connection, ~"{\"jsonrpc\":\"2.0\",\"result\":true,\"id\":1}"), "Response should match.")
  Assert(JSONRPC_Connection_CleanupTimeouts(@connection, deadline) = 0, "Matched request should not time out.")
  AssertString(JSONRPC_Connection_GetLastMatchedIdText(@connection), "1", "Matched id should remain observable.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit
