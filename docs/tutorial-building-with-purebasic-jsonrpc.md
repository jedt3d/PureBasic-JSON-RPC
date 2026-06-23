# Building With PureBasic JSON-RPC

## A tutorial from first byte to MCP tool

This tutorial is the narrative companion to the API reference. The reference
pages tell you what each public procedure does. This document explains how the
pieces work together, why the examples are ordered the way they are, and how to
turn the library into a practical MCP stdio server.

The intended reader knows AI tooling or MCP concepts, but may be new to
PureBasic. The tutorial therefore spends time on the project harness, `.pbp`
project files, and the difference between a console executable, a shared
library, and an application target.

## 1. The project shape

The repository is organized around a layered JSON-RPC library:

```text
src/jsonrpc/
  byte_buffer.pbi
  framing.pbi
  codec.pbi
  io.pbi
  connection.pbi
  protocol.pbi
  dispatch.pbi
  outbound.pbi
  batch.pbi
  cancel.pbi
  diagnostics.pbi
  trace.pbi
  compliance.pbi
  stdio_runtime.pbi
  mcp_lifecycle.pbi
  mcp_tools.pbi
  jsonrpc.pbi
```

The numbered `examples/` folders are not random demos. They are the project
history expressed as runnable scenarios. Each one teaches a single layer. The
`MCP/examples/` folder is for MCP-focused projects without numeric milestone
prefixes.

The source package is designed around PureBasic 6.40 and the SDK PureUnit
runner. The local harness discovers the installed compiler, creates ignored
project-local homes under `.local/`, builds into `.build/`, and writes reports
under `.reports/`.

Start with:

```sh
./tools/discover-purebasic.sh
./tools/verify-projects.sh
./tools/test.sh
./tools/build.sh
```

Or run the full gate:

```sh
./tools/check.sh
```

`./tools/check.sh` is the confidence command. It verifies toolchain discovery,
project metadata, PureUnit tests, example builds, scenario probes, the MCP
example, and alpha package generation.

## 2. PureBasic project files are part of the design

Every buildable target has a `.pbp` project file. This includes the root
library workspace, every numbered example folder, and the MCP example. The
project file records the source file, output path, target format, thread mode,
and CPU target.

For MCP stdio servers, the target format must be console. The protocol depends
on stdin and stdout behaving like byte streams. A GUI application target is the
wrong shape for a stdio MCP server even if the source code compiles.

The harness builds project targets with the PureBasic IDE command-line builder:

```sh
PureBasic --build path/to/project.pbp --target target-name --readonly --quiet
```

The `/READONLY` option matters because it avoids build counters and access
metadata changing the project file during automation.

The rule of thumb is:

```text
library include      -> .pbi file in src/jsonrpc/
scenario program     -> .pb file plus .pbp target in examples/NNN-name/
MCP example server   -> .pb file plus .pbp console target in MCP/examples/name/
release build output -> .build/
```

## 3. The runtime layers

PureBasic JSON-RPC is easier to understand as a vertical stack. Data flows from
bytes to messages, from messages to protocol objects, and from protocol objects
to handlers.

```text
raw transport bytes
  |
  v
byte buffer and framing/codec
  |
  v
complete JSON-RPC message body
  |
  v
protocol validation
  |
  v
dispatcher
  |
  v
registered request or notification handler
  |
  v
JSON-RPC response or no response
  |
  v
writer / transport
```

The layers are separate so each one can be tested:

- `byte_buffer.pbi` keeps bounded byte-counted state.
- `framing.pbi` handles `Content-Length` style messages.
- `codec.pbi` handles MCP stdio newline-delimited messages.
- `io.pbi` defines small reader and writer structures.
- `connection.pbi` owns lifecycle, close behavior, queued writes, and events.
- `protocol.pbi` validates JSON-RPC shapes and builds standard errors.
- `dispatch.pbi` maps method names to handlers.
- `outbound.pbi` tracks requests sent by this side.
- `batch.pbi` dispatches JSON-RPC batches.
- `cancel.pbi` records cooperative cancellation state.
- `diagnostics.pbi` counts important runtime events.
- `trace.pbi` lets callers observe behavior without dumping protocol data.
- `compliance.pbi` runs core JSON-RPC compliance checks.
- `stdio_runtime.pbi` wires codec, dispatcher, pending responses, and writer.
- `mcp_lifecycle.pbi` registers `initialize` and `notifications/initialized`.
- `mcp_tools.pbi` registers tools, `tools/list`, `tools/call`, and text
  results.
- `jsonrpc.pbi` includes the complete stack.

## 4. Framing and codecs

JSON-RPC is transport-agnostic. That means the JSON-RPC object does not say how
many bytes belong to the current message. A transport has to answer that
question.

The library supports two message boundaries:

```text
Content-Length framing
  Header: Content-Length: 42
  Blank line
  Body: JSON text

MCP stdio codec
  One UTF-8 JSON-RPC message per line
  Newline delimiter
  No embedded newline inside a message
```

Use Content-Length framing when you are building a vscode-jsonrpc or
LSP-style stream. Use the stdio codec when you are building a local MCP server.

Conceptual PureBasic usage:

```text
Define state.JSONRPC_StdioCodecState
Define message.JSONRPC_Message

JSONRPC_Codec_StdioInit(@state, 1048576)
JSONRPC_Codec_StdioPushBytes(@state, chunk)

If JSONRPC_Codec_StdioNextMessage(@state, @message)
  ; message\body is one complete JSON-RPC body
EndIf
```

The codec does not dispatch anything. It only decides whether a complete body
has arrived. That keeps malformed transport data out of the protocol layer.

## 5. Protocol validation

Once a body is complete, the protocol layer asks: is this valid JSON-RPC 2.0?

The JSON-RPC 2.0 specification defines requests, notifications, responses,
errors, and batches. The library enforces the important shape rules:

- `jsonrpc` must be `"2.0"`.
- Requests and notifications need a method string.
- Requests have an id; notifications do not.
- Responses have exactly one of `result` or `error`.
- Parse errors return `-32700`.
- Invalid requests return `-32600`.
- Unknown methods return `-32601`.
- Invalid parameters return `-32602`.

The protocol layer is also where JSON ownership matters. PureBasic JSON handles
created by `ParseJSON()` or `CreateJSON()` must be released with `FreeJSON()`
when no longer needed. The library keeps those paths localized so examples and
handlers can stay readable.

## 6. Dispatching requests and notifications

The dispatcher maps method names to PureBasic handler procedures.

```text
JSON-RPC request:
  {"jsonrpc":"2.0","id":1,"method":"tools/echo","params":{"text":"hello"}}

Dispatcher:
  method "tools/echo" -> EchoHandler()

JSON-RPC response:
  {"jsonrpc":"2.0","id":1,"result":...}
```

Requests return responses. Notifications do not. That distinction is easy to
miss and important to preserve. If a server responds to a notification, it is
speaking a different protocol than the client expects.

Handlers receive a context and produce a result. The pattern is:

```text
Procedure.i MyHandler(paramsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  ; validate paramsValue
  ; set *result\resultJson or *result\errorCode and *result\errorMessage
  ProcedureReturn #True
EndProcedure
```

The examples use MCP-flavored method names early, such as `tools/echo`, but the
core dispatcher remains generic JSON-RPC. MCP-specific method semantics arrive
later in the `MCP_*` adapter layer.

## 7. Outbound requests, batches, and cancellation

Servers sometimes need to send requests to clients. The outbound layer assigns
ids, writes request bodies, and tracks pending responses until a match,
timeout, or close.

Batch handling is sequential. A batch may contain requests, notifications, or
responses. Notification-only batches produce no response. Mixed batches return
only the responses required by the request items.

Cancellation is cooperative. The `$/cancelRequest` notification marks a token
as cancelled; it does not kill a thread. A handler can inspect cancellation
state and decide how to stop safely.

That design choice is intentional. Forced thread termination is tempting, but
it is hostile to memory ownership and cleanup. Cooperative cancellation keeps
the library honest.

## 8. Diagnostics and trace

Protocol code fails in quiet ways if you cannot see it. A malformed message
might become a parse error. A response might arrive after its request timed
out. A write might fail because the peer closed the pipe.

The diagnostics layer counts important events:

- received messages
- sent messages
- protocol errors
- timeouts
- orphan responses
- batches
- cancellations

Trace hooks are for observing behavior while keeping payload logging opt-in.
That matters for MCP servers because payloads can contain private user data,
source code, paths, or command output.

For stdio MCP servers, never use stdout for traces. stdout is the protocol
channel. Use stderr or a file.

## 9. MCP lifecycle

MCP lifecycle starts with initialization. The client sends `initialize`; the
server responds with its protocol version, capabilities, server info, and
optional instructions. After that, the client sends
`notifications/initialized`.

The simplified flow:

```text
Client                         Server
  | initialize                   |
  |----------------------------->|
  | InitializeResult             |
  |<-----------------------------|
  | notifications/initialized    |
  |----------------------------->|
  | normal operation             |
```

The library provides:

```text
MCP_ServerInfo_Init(*server, name, version, title, instructions)
MCP_RegisterLifecycle(*dispatcher, *server)
MCP_BuildInitializeResult(*server)
```

The current adapter responds with protocol version `2025-11-25`, matching the
spec version targeted by this alpha.

## 10. MCP tools

Tools are the first server feature implemented by the MCP adapter. A tool has
metadata and, optionally, a handler.

Registering a tool is a two-part operation:

```text
MCP_RegisterTool(*registry, name, title, description, inputSchemaJson)
MCP_RegisterToolHandler(*registry, name, @Handler())
```

Then register the protocol endpoints:

```text
MCP_RegisterToolsList(*dispatcher, *registry)
MCP_RegisterToolsCall(*dispatcher, *registry)
```

`tools/list` returns metadata. `tools/call` invokes the handler named by
`params.name`. Text results are built with:

```text
MCP_Tools_TextResult(text, isError)
```

Use `isError: true` for tool execution failures that are valid tool results:
the command ran and reported failure, a validation step rejected the operation,
or a local dependency was missing. Use JSON-RPC errors for protocol-level
problems such as an unknown tool name or invalid parameter shape.

## 11. The example ladder

The examples are best read in groups.

### Foundation and message boundaries

`000-project-foundation` proves the harness, compiler discovery, PureUnit, and
the first console program.

`001-framing` teaches Content-Length framing: incremental input, body length,
leftover bytes, and invalid header handling.

`002-transport-codecs` adds the MCP stdio codec: one UTF-8 JSON-RPC message per
line, multiple messages per chunk, partial line waits, and embedded-newline
rejection.

### Connection and protocol shape

`003-connection-lifecycle` adds create/close behavior, idempotent close,
writer state, and fake writers for tests.

`004-protocol-errors` validates JSON-RPC 2.0 objects and builds standard error
responses.

`005-dispatch` maps request and notification method names to handlers.

`006-outbound-requests` sends requests and notifications and tracks pending
responses.

### Runtime behavior

`007-timeout-housekeeping` expires pending requests.

`008-batch-handling` processes JSON-RPC batches.

`009-cancellation` records `$/cancelRequest` notifications.

`010-diagnostics` exposes counters for runtime behavior.

`011-stress-memory` repeats parse, dispatch, and cleanup paths to catch
unbounded state or missing frees.

`012-stdio-runtime-pump` connects stdio codec messages to dispatch and pending
response routing.

### MCP adapter

`013-mcp-lifecycle` registers `initialize` and `notifications/initialized`.

`014-mcp-tools-registry` registers tool metadata and implements `tools/list`.

`015-mcp-tools-call` registers tool handlers and implements `tools/call`.

### Packaging and hardening

`016-packaging-docs` adds the consolidated include and compile templates for
console, shared-library, and executable/application shapes.

`017-reader-writer-interfaces` tightens generic I/O abstractions.

`018-byte-buffer-framing` moves framing toward byte-aware buffering.

`019-connection-events` records lifecycle and error events.

`020-handler-registration-lifecycle` adds unregister and duplicate handler
behavior.

`021-handler-cancellation-tokens` lets handlers observe cancellation.

`022-write-queue-close-semantics` clarifies queued writes and close behavior.

`023-trace-logger-hooks` adds trace callbacks and payload privacy defaults.

`024-compliance-suite` adds reusable JSON-RPC compliance checks.

`025-public-api-review` records version metadata and API exposure.

`026-alpha-release-package` builds the alpha source package and release
artifacts.

## 12. Building your first MCP stdio server

The smallest useful server has four responsibilities:

1. Initialize a dispatcher and MCP server info.
2. Register lifecycle handlers.
3. Register one or more tools.
4. Run a stdio loop that reads requests and writes responses.

Conceptual server skeleton:

```text
EnableExplicit

XIncludeFile "../../../src/jsonrpc/jsonrpc.pbi"
XIncludeFile "my_tool.pbi"

Define dispatcher.JSONRPC_Dispatcher
Define registry.MCP_ToolRegistry
Define server.MCP_ServerInfo
Define line.s
Define response.s

JSONRPC_Dispatcher_Init(@dispatcher)
MCP_ToolRegistry_Init(@registry)
MCP_ServerInfo_Init(@server, "my-server", JSONRPC_LibraryVersion(),
                    "My Server", "Short instructions for the host.")

MCP_RegisterLifecycle(@dispatcher, @server)
MyTool_Register(@dispatcher, @registry)

Repeat
  line = Input()
  If line <> ""
    response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, line)
    If response <> ""
      PrintN(response)
    EndIf
  EndIf
Until line = ""
```

For a real stdio MCP server, keep diagnostic output away from `PrintN()` unless
you are printing a protocol message. Use stderr for logs.

## 13. Designing a tool

A tool should be boring in the best way. It should have a clear name, a short
description, an input schema, bounded output, and predictable failure behavior.

Example metadata:

```json
{
  "name": "purebasic/check",
  "title": "PureBasic Check",
  "description": "Run the project PureBasic verification script.",
  "inputSchema": {
    "type": "object",
    "properties": {},
    "additionalProperties": false
  }
}
```

A handler should:

- Treat arguments as untrusted JSON.
- Validate required fields before doing work.
- Copy values it needs after the handler returns.
- Return `isError: true` for tool-level failure.
- Bound command output or result text.
- Avoid shelling out with model-provided command strings.

The `purebasic/check` example follows that shape. It exposes one no-argument
tool, runs `./tools/check.sh`, captures bounded output, and returns a text
result.

## 14. Compiling and registering a server

The MCP example server builds through its `.pbp` file:

```text
MCP/examples/purebasic-check/purebasic_check.pbp
```

The target is a console executable because stdio servers must read stdin and
write protocol messages to stdout.

Build it with:

```sh
./tools/build.sh
```

Run a smoke probe:

```sh
./.build/MCP/examples/purebasic-check/purebasic_check_server \
  < MCP/examples/purebasic-check/probe_smoke_input.ndjson
```

A typical MCP host registration points to the compiled executable:

```json
{
  "mcpServers": {
    "purebasic-check": {
      "command": "/absolute/path/to/.build/MCP/examples/purebasic-check/purebasic_check_server"
    }
  }
}
```

Different hosts have different configuration files and UI, but the principle
is the same: the host launches the executable, sends MCP JSON-RPC messages to
stdin, and reads protocol messages from stdout.

## 15. Troubleshooting

If the host cannot see the server:

- Confirm the command path is absolute.
- Confirm the binary was built for the current platform.
- Confirm the `.pbp` target is console.
- Run the probe input manually.
- Check stderr logs, not stdout.

If the server appears but tools do not:

- Confirm `MCP_RegisterLifecycle()` was called.
- Confirm `MCP_RegisterToolsList()` was called.
- Confirm the server declares tool capability through the lifecycle response.
- Confirm the client sent `notifications/initialized`.

If `tools/call` fails:

- Check whether the tool name matches exactly.
- Validate `params.arguments`.
- Distinguish JSON-RPC errors from MCP tool results with `isError: true`.
- Bound output before returning it.

If the process hangs:

- Look for a partial stdio line without a newline delimiter.
- Confirm stdout has only protocol messages.
- Check whether a handler is waiting on a child process.
- Add trace hooks or diagnostics counters.

## 16. Testing strategy

A useful PureBasic MCP server should have four layers of tests:

```text
PureUnit unit tests
  validate procedures, parsing, handlers, result builders

Scenario probes
  compile and run focused example programs

Protocol probes
  feed newline-delimited initialize/tools/list/tools/call messages

Full check
  run ./tools/check.sh before release
```

The test harness already follows this model. New features should add PureUnit
coverage first or alongside implementation, then add a runnable scenario.

## 17. Packaging and PDFs

The alpha package is generated by:

```sh
./tools/package-alpha.sh
```

It stages source files under `.build/package/`, writes release artifacts under
`.build/dist/`, and records a manifest. The documentation package also builds
HTML and generated PDFs. PDFs are release artifacts, not source files; the
editable source of truth is Markdown.

## 18. Where to go after alpha

The alpha foundation makes local stdio tools practical. The natural next steps
are:

- MCP resources for file-like or queryable context.
- MCP prompts for reusable task templates.
- Richer JSON Schema handling for tool inputs.
- Streamable HTTP transport for remote and multi-client servers.
- Authorization and credential guidance.
- MCP Inspector-driven testing documentation.
- Production hardening for command execution and filesystem access.
- More example servers under `MCP/examples/`.

The important rule is to preserve the layering. Build generic JSON-RPC pieces
as `JSONRPC_*`. Build MCP adapter pieces as `MCP_*`. Keep transports explicit.
Keep stdout clean. Keep examples small enough to read.

## 19. Reading map

Use this order when learning the project:

1. Read `docs/mcp-for-purebasic.md` for the reason the project exists.
2. Read this tutorial for the system shape.
3. Open `API/index.md` when you need procedure-level details.
4. Run `./tools/check.sh` to see the full workflow.
5. Read `MCP/examples/purebasic-check/` when building your first tool server.

That path is intentionally slower than copying an example and changing names.
It gives you the mental model first. Once you have the model, the API reference
becomes a map instead of a wall of names.

## References

- [What is the Model Context Protocol?](https://modelcontextprotocol.io/docs/getting-started/intro)
- [MCP architecture](https://modelcontextprotocol.io/docs/learn/architecture)
- [MCP transports, 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/basic/transports)
- [MCP lifecycle, 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/basic/lifecycle)
- [MCP tools, 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/server/tools)
- [JSON-RPC 2.0 specification](https://www.jsonrpc.org/specification)
- [PureBasic command-line compiler](https://www.purebasic.com/documentation/reference/cli_compiler.html)
- [PureBasic IDE command-line options](https://www.purebasic.com/documentation/reference/ide_commandline.html)
