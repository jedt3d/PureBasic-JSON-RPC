EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "mcp_tools.pbi"

PureUnitOptions(Thread)

Procedure.i EchoToolHandler(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  Protected textValue

  If argumentsValue <> 0 And JSONType(argumentsValue) = #PB_JSON_Object
    textValue = GetJSONMember(argumentsValue, "text")
    If textValue <> 0 And JSONType(textValue) = #PB_JSON_String
      *result\ok = #True
      *result\resultJson = MCP_Tools_TextResult(GetJSONString(textValue))
      ProcedureReturn #True
    EndIf
  EndIf

  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult("missing text", #True)
  ProcedureReturn #True
EndProcedure

Procedure PrepareToolCall(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)
  JSONRPC_Dispatcher_Init(*dispatcher)
  MCP_ToolRegistry_Init(*registry)
  MCP_RegisterTool(*registry, "echo", "Echo", "Echo text", ~"{\"type\":\"object\"}")
  MCP_RegisterToolHandler(*registry, "echo", @EchoToolHandler())
  MCP_RegisterToolsCall(*dispatcher, *registry)
EndProcedure

ProcedureUnit ToolsCallReturnsTextResult()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  PrepareToolCall(@dispatcher, @registry)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"echo\",\"arguments\":{\"text\":\"hello\"}},\"id\":1}")

  Assert(FindString(response, ~"\"type\":\"text\"", 1) > 0, "Tool response should include text content.")
  Assert(FindString(response, ~"\"text\":\"hello\"", 1) > 0, "Tool response should include handler text.")
  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "Successful tool response should not be an error.")
EndProcedureUnit

ProcedureUnit UnknownToolReturnsInvalidParams()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  PrepareToolCall(@dispatcher, @registry)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"missing\",\"arguments\":{}},\"id\":2}")

  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "Unknown tool should return invalid params.")
  Assert(FindString(response, "Unknown tool: missing", 1) > 0, "Unknown tool message should name tool.")
EndProcedureUnit

ProcedureUnit InvalidArgumentsReturnInvalidParams()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  PrepareToolCall(@dispatcher, @registry)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"echo\",\"arguments\":[]},\"id\":3}")

  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "Non-object arguments should return invalid params.")
EndProcedureUnit

ProcedureUnit ToolExecutionErrorCanUseResultErrorFlag()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  PrepareToolCall(@dispatcher, @registry)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"echo\",\"arguments\":{}},\"id\":4}")

  Assert(FindString(response, ~"\"isError\":true", 1) > 0, "Tool execution error should be represented in result.")
  Assert(FindString(response, ~"\"text\":\"missing text\"", 1) > 0, "Tool execution error should include text.")
EndProcedureUnit
