EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "outbound.pbi"

PureUnitOptions(Thread)

ProcedureUnit SendRequestWritesBodyAndTracksPending()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected id.q

  JSONRPC_FakeWriter_Init(@writer)
  Assert(JSONRPC_Connection_Init(@connection, @writer), "Connection should initialize.")

  id = JSONRPC_Connection_SendRequest(@connection, "tools/list", ~"{\"cursor\":\"abc\"}")

  Assert(id = 1, "First outbound request id should be 1.")
  AssertString(writer\captured, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"params\":{\"cursor\":\"abc\"},\"id\":1}", "Request body should be compact JSON-RPC.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 1, "Request should create one pending entry.")
  Assert(JSONRPC_Connection_HasPending(@connection, "1"), "Pending map should contain the outbound id.")
  Assert(JSONRPC_Connection_GetNextId(@connection) = 2, "Next request id should advance.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit SendNotificationDoesNotTrackPending()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  Assert(JSONRPC_Connection_SendNotification(@connection, "notifications/log", ~"{\"message\":\"ready\"}"), "Notification should be sent.")
  AssertString(writer\captured, ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/log\",\"params\":{\"message\":\"ready\"}}", "Notification body should omit id.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Notification should not create pending state.")
  Assert(JSONRPC_Connection_GetNextId(@connection) = 1, "Notification should not consume request id.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit MatchingResponseRemovesPending()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected response.s

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Connection_SendRequest(@connection, "tools/echo", ~"{\"text\":\"hello\"}")

  response = ~"{\"jsonrpc\":\"2.0\",\"result\":{\"text\":\"hello\"},\"id\":1}"

  Assert(JSONRPC_Connection_MatchResponse(@connection, response), "Matching response should be accepted.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Matched response should remove pending state.")
  AssertString(JSONRPC_Connection_GetLastMatchedIdText(@connection), "1", "Matched id should be recorded.")
  AssertString(JSONRPC_Connection_GetLastResponseBody(@connection), response, "Raw response body should be recorded.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit OrphanResponseIsIgnored()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Connection_SendRequest(@connection, "tools/echo", ~"{\"text\":\"hello\"}")

  Assert(JSONRPC_Connection_MatchResponse(@connection, ~"{\"jsonrpc\":\"2.0\",\"result\":\"late\",\"id\":99}") = #False, "Orphan response should be ignored.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 1, "Orphan response should not remove another pending request.")
  Assert(JSONRPC_Connection_GetLastErrorCode(@connection) = #JSONRPC_Connection_ErrorOrphanResponse, "Orphan response should be observable.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit InvalidParamsRejectedBeforeWrite()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection
  Protected id.q

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)

  id = JSONRPC_Connection_SendRequest(@connection, "tools/bad", ~"\"scalar\"")

  Assert(id = 0, "Invalid params should reject the request.")
  Assert(writer\writeCount = 0, "Invalid params should not write to the connection.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Invalid params should not create pending state.")
  Assert(JSONRPC_Connection_GetLastErrorCode(@connection) = #JSONRPC_Connection_ErrorInvalidParams, "Invalid params should set expected error.")

  JSONRPC_Connection_Close(@connection)
EndProcedureUnit

ProcedureUnit CloseClearsPendingRequests()
  Protected writer.JSONRPC_FakeWriter
  Protected connection.JSONRPC_Connection

  JSONRPC_FakeWriter_Init(@writer)
  JSONRPC_Connection_Init(@connection, @writer)
  JSONRPC_Connection_SendRequest(@connection, "tools/list", "")

  Assert(JSONRPC_Connection_PendingCount(@connection) = 1, "Request should be pending before close.")
  Assert(JSONRPC_Connection_Close(@connection), "Close should succeed.")
  Assert(JSONRPC_Connection_PendingCount(@connection) = 0, "Close should clear pending state.")
EndProcedureUnit
