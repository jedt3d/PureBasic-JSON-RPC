EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "dispatch.pbi"

PureUnitOptions(Thread)

Global LifecycleNotificationMethod.s

Procedure.i FirstLifecycleHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = #DQUOTE$ + "first" + #DQUOTE$
  ProcedureReturn #True
EndProcedure

Procedure.i SecondLifecycleHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = #DQUOTE$ + "second" + #DQUOTE$
  ProcedureReturn #True
EndProcedure

Procedure.i StarLifecycleRequestHandler(method.s, paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = #DQUOTE$ + JSONRPC_Protocol_EscapeString(method) + #DQUOTE$
  ProcedureReturn #True
EndProcedure

Procedure.i StarLifecycleNotificationHandler(method.s, paramsValue, *context.JSONRPC_RequestContext)
  LifecycleNotificationMethod = method
  ProcedureReturn #True
EndProcedure

ProcedureUnit DuplicateRegistrationReplacesByDefault()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  Assert(JSONRPC_RegisterRequest(@dispatcher, "demo/value", @FirstLifecycleHandler()), "First handler should register.")
  Assert(JSONRPC_RegisterRequest(@dispatcher, "demo/value", @SecondLifecycleHandler()), "Duplicate handler should replace by default.")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"demo/value\",\"id\":1}")
  Assert(FindString(response, ~"\"result\":\"second\"", 1) > 0, "Second handler should replace the first.")
EndProcedureUnit

ProcedureUnit DuplicateRegistrationCanBeRejected()
  Protected dispatcher.JSONRPC_Dispatcher

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_Dispatcher_SetReplaceHandlers(@dispatcher, #False)

  Assert(JSONRPC_RegisterRequest(@dispatcher, "demo/value", @FirstLifecycleHandler()), "First handler should register.")
  Assert(JSONRPC_RegisterRequest(@dispatcher, "demo/value", @SecondLifecycleHandler()) = #False, "Duplicate handler should be rejected when replacement is disabled.")
EndProcedureUnit

ProcedureUnit UnregisterRemovesRequestHandler()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  JSONRPC_RegisterRequest(@dispatcher, "demo/value", @FirstLifecycleHandler())

  Assert(JSONRPC_Dispatcher_HasRequest(@dispatcher, "demo/value"), "Request handler should be present.")
  Assert(JSONRPC_UnregisterRequest(@dispatcher, "demo/value"), "Unregister should remove handler.")
  Assert(JSONRPC_Dispatcher_HasRequest(@dispatcher, "demo/value") = #False, "Request handler should be absent.")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"demo/value\",\"id\":1}")
  Assert(FindString(response, ~"\"code\":-32601", 1) > 0, "Removed handler should fall back to method not found.")
EndProcedureUnit

ProcedureUnit StarRequestHandlesUnknownMethod()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  Assert(JSONRPC_RegisterStarRequest(@dispatcher, @StarLifecycleRequestHandler()), "Star request handler should register.")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"demo/star\",\"id\":7}")
  Assert(FindString(response, ~"\"result\":\"demo/star\"", 1) > 0, "Star request handler should receive method.")
EndProcedureUnit

ProcedureUnit StarNotificationHandlesUnknownMethod()
  Protected dispatcher.JSONRPC_Dispatcher

  LifecycleNotificationMethod = ""
  JSONRPC_Dispatcher_Init(@dispatcher)
  Assert(JSONRPC_RegisterStarNotification(@dispatcher, @StarLifecycleNotificationHandler()), "Star notification handler should register.")

  JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/star\"}")
  AssertString(LifecycleNotificationMethod, "notifications/star", "Star notification handler should receive method.")
EndProcedureUnit
