EnableExplicit

XIncludeFile "../../MCP/examples/purebasic-check/purebasic_check_tool.pbi"

PureUnitOptions(Thread)

Procedure PrepareCheckTool(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry, command.s, maxOutputChars.i = 8000)
  JSONRPC_Dispatcher_Init(*dispatcher)
  MCP_ToolRegistry_Init(*registry)
  MCP_CheckTool_SetConfig(GetCurrentDirectory(), command, maxOutputChars)
  MCP_CheckTool_Register(*dispatcher, *registry)
EndProcedure

ProcedureUnit ToolNameAllowsSlash()
  Assert(MCP_ToolNameIsValid("purebasic/check"), "MCP tool names should allow slash-separated names.")
EndProcedureUnit

ProcedureUnit ToolsListIncludesPureBasicCheck()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  PrepareCheckTool(@dispatcher, @registry, "printf list-ok")
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"params\":{},\"id\":1}")

  Assert(FindString(response, ~"\"name\":\"purebasic/check\"", 1) > 0, "tools/list should expose purebasic/check.")
  Assert(FindString(response, ~"\"title\":\"PureBasic Check\"", 1) > 0, "tools/list should expose the tool title.")
  Assert(FindString(response, ~"\"additionalProperties\":false", 1) > 0, "tools/list should expose the empty object schema.")
EndProcedureUnit

ProcedureUnit ToolsCallReturnsTextContent()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  PrepareCheckTool(@dispatcher, @registry, "printf check-ok")
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/check\",\"arguments\":{}},\"id\":2}")

  Assert(FindString(response, ~"\"isError\":false", 1) > 0, "Successful check should not be an MCP tool error.")
  Assert(FindString(response, "purebasic/check passed with exit code 0", 1) > 0, "Successful check should include a pass summary.")
  Assert(FindString(response, "check-ok", 1) > 0, "Successful check should include command output.")
EndProcedureUnit

ProcedureUnit FailedCommandReturnsToolError()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  PrepareCheckTool(@dispatcher, @registry, "printf check-failed; exit 7")
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/check\",\"arguments\":{}},\"id\":3}")

  Assert(FindString(response, ~"\"isError\":true", 1) > 0, "Failed command should be represented as an MCP tool error.")
  Assert(FindString(response, "exit code 7", 1) > 0, "Failed command should include exit code.")
  Assert(FindString(response, "check-failed", 1) > 0, "Failed command should include command output.")
EndProcedureUnit

ProcedureUnit OutputIsBounded()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  PrepareCheckTool(@dispatcher, @registry, "printf 1234567890", 5)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/check\",\"arguments\":{}},\"id\":4}")

  Assert(FindString(response, "12345", 1) > 0, "Bounded output should include the allowed prefix.")
  Assert(FindString(response, "67890", 1) = 0, "Bounded output should omit content beyond the limit.")
  Assert(FindString(response, "output truncated", 1) > 0, "Bounded output should mark truncation.")
EndProcedureUnit
