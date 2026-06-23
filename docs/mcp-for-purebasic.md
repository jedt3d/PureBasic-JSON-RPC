# MCP for PureBasic

## A native path for local AI tools

AI tools are becoming less like isolated chat boxes and more like workbenches.
They read source trees, inspect tickets, query services, call local programs,
and turn a conversation into a sequence of deliberate actions. The missing
piece is not intelligence alone. The missing piece is a dependable way for an
AI application to talk to the software that already knows how work gets done.

The Model Context Protocol, or MCP, is one answer to that problem. The official
MCP documentation describes MCP as an open standard for connecting AI
applications to external systems such as data sources, tools, and workflows.
The protocol gives an AI application a common way to discover what a server can
do and ask that server to perform an operation. See the official
[MCP introduction](https://modelcontextprotocol.io/docs/getting-started/intro)
for the high-level framing.

This project asks a focused question:

> What would it take to make PureBasic a practical language for writing MCP
> servers?

That question is narrower than "can PureBasic parse JSON?" and broader than
"can one example program print one valid response?" A useful MCP server must
survive malformed input, keep stdout clean, build predictably, expose tools
with clear schemas, and remain understandable to a developer who comes back to
the code six months later. PureBasic JSON-RPC 2.0 is the foundation for that
kind of server.

## The mental model

MCP uses a host, client, and server architecture. The host is the AI
application the user experiences. The client is the protocol-side connection
manager that the host creates for a specific server. The server is the program
that exposes context and actions. The official architecture guide explains that
a host can manage multiple clients, with each client maintaining a dedicated
connection to one MCP server; see
[MCP architecture](https://modelcontextprotocol.io/docs/learn/architecture).

The relationship is easier to see as a small diagram:

```text
User
  |
  v
MCP Host
  |
  +-- MCP Client for filesystem server ----> filesystem MCP server
  |
  +-- MCP Client for issue tracker server --> issue tracker MCP server
  |
  +-- MCP Client for PureBasic server ------> PureBasic MCP server
```

The important part is separation of responsibility. The host owns the user
experience. The client owns a connection. The server owns a capability. The
server does not need to know how the model reasons; it needs to advertise
capabilities and answer protocol messages correctly.

For local developer tools, the server is often just a process launched by the
host. That is where PureBasic becomes interesting. A PureBasic MCP server can
compile into a small native executable with a predictable console target. It
can run locally, use stdin and stdout for the protocol, use stderr for logs, and
wrap existing project workflows without forcing the user to install a language
runtime.

## What MCP asks a server to do

At the wire level, MCP builds on JSON-RPC. The JSON-RPC 2.0 specification calls
JSON-RPC a lightweight, transport-agnostic remote procedure call protocol. It
defines requests, responses, notifications, error objects, and batches; see the
[JSON-RPC 2.0 specification](https://www.jsonrpc.org/specification).

MCP adds a product contract around that generic RPC shape:

- The server and client initialize the connection.
- They negotiate protocol version and capabilities.
- The client discovers available server features.
- The client can ask the server to perform model-visible operations, such as
  calling a tool.
- The server responds with structured results or protocol errors.

For this project's first MCP-ready path, the most important server feature is
tools. The MCP tools specification says tools let servers expose operations that
language models can invoke against external systems. Each tool has a name,
metadata, and an input schema; clients use `tools/list` to discover tools and
`tools/call` to invoke one. See
[MCP tools](https://modelcontextprotocol.io/specification/2025-11-25/server/tools).

In practice, an MCP tool is a careful bridge:

```text
AI model intent
  |
  v
MCP tool call request
  |
  v
PureBasic handler
  |
  v
Local command, file, API, database, or library function
  |
  v
MCP tool result
```

The bridge must be narrow enough to reason about. A tool should describe its
input, bound its output, report errors clearly, and avoid surprising side
effects. MCP makes the call possible; the server author is still responsible
for designing a safe action surface.

## Why stdio matters first

MCP defines standard transports. In the 2025-11-25 specification, the transport
page says MCP messages use JSON-RPC, must be UTF-8 encoded, and are carried by
stdio or Streamable HTTP. For stdio, the client launches the server as a
subprocess; the server reads JSON-RPC messages from stdin and writes protocol
messages to stdout. Messages are newline-delimited and must not contain
embedded newlines. Logs belong on stderr, and stdout must contain only valid MCP
messages. See
[MCP transports](https://modelcontextprotocol.io/specification/2025-11-25/basic/transports).

That one rule, "stdout is protocol only", is the difference between a working
local server and a mysterious broken pipe. A stray `PrintN("debug")` can corrupt
the next JSON-RPC message. A server that logs to stdout might work in a manual
terminal probe and fail inside a real MCP host.

PureBasic JSON-RPC treats stdio as a first-class path:

```text
stdin bytes
  |
  v
newline-delimited UTF-8 message codec
  |
  v
JSON-RPC parse and validation
  |
  v
dispatcher and MCP adapter
  |
  v
handler
  |
  v
JSON-RPC response
  |
  v
stdout protocol message
```

Streamable HTTP is important for remote and multi-client servers, but it is not
the right first foundation for this project. The immediate product goal is
local MCP server development in PureBasic: command-line tools, project
automation, native executables, and developer workflows. Stdio is the shortest
honest path from an MCP host to a local PureBasic program.

## Why PureBasic is a good fit

PureBasic has a quality that is easy to overlook in modern AI tooling: it can
produce simple native artifacts. A small MCP server can be compiled, copied,
and launched as a local process. That makes it a serious candidate for
developer-facing tools where distribution and startup cost matter.

PureBasic also makes target type explicit. A server intended for stdio should
be a console executable. A shared library has a different purpose. A GUI
application has a different contract with the operating system. This project
therefore treats PureBasic project files (`.pbp`) as source-of-truth build
metadata. The harness builds targets with the PureBasic IDE command-line
project builder, whose documentation includes `/BUILD`, `/TARGET`, `/QUIET`,
and `/READONLY` options. See
[PureBasic IDE command-line options](https://www.purebasic.com/documentation/reference/ide_commandline.html).

The command-line compiler still matters. It is how PureBasic source becomes a
native program, and the official compiler documentation describes the
`pbcompiler` workflow and examples. See
[PureBasic command-line compiler](https://www.purebasic.com/documentation/reference/cli_compiler.html).
But for this repository, `.pbp` files record the target intent so a developer,
the IDE, and the automation all agree.

This gives an MCP server author a stable development loop:

```text
write PureBasic code
  |
  v
update .pbp target metadata
  |
  v
run PureUnit tests
  |
  v
build with PureBasic --build project.pbp --target ...
  |
  v
run MCP probe or client
```

For AI/MCP developers who do not know PureBasic yet, the practical selling
point is not nostalgia or syntax preference. It is native local tool delivery:
a console executable that can sit behind an MCP host with a small operational
surface.

## How this project was developed

PureBasic JSON-RPC 2.0 was built in small rounds, each adding one layer of the
runtime. The early rounds stayed generic: framing, transport codecs,
connection lifecycle, protocol validation, dispatch, outbound requests, batch
handling, cancellation, diagnostics, trace hooks, and compliance checks. The
MCP-specific layer arrived only after the JSON-RPC foundation could stand on
its own.

That sequencing matters. MCP is built on JSON-RPC, but not every JSON-RPC
library is a useful MCP foundation. An MCP server needs:

- A transport codec that matches the selected MCP transport.
- JSON-RPC shape validation and standard errors.
- Request and notification dispatch.
- Handler registration.
- Cooperative cancellation and timeout housekeeping.
- Diagnostics that can be inspected without polluting stdout.
- A lifecycle adapter for `initialize` and `notifications/initialized`.
- Tool metadata and `tools/list`.
- Tool invocation and result helpers.

The project deliberately kept the generic layer reusable. The `JSONRPC_*`
symbols form the protocol foundation. The `MCP_*` symbols sit above them. That
means the library can support MCP server development without becoming useful
only for MCP.

## The current MCP proof point: `purebasic/check`

The first MCP-focused example lives under `MCP/examples/purebasic-check/`. It
builds a stdio MCP server exposing one tool:

```text
Tool name:        purebasic/check
Tool title:       PureBasic Check
Tool description: Run the project PureBasic verification script.
Input schema:     object with no properties
Effect:           runs ./tools/check.sh from the repository root
```

The server responds to the lifecycle methods, lists its tool, and handles
`tools/call`. The tool result is text content. If the verification command
passes, the result is a normal MCP tool result. If the command fails or cannot
launch, the tool result sets `isError: true`.

The message sequence is intentionally small:

```text
Client                         PureBasic MCP server
  | initialize request                  |
  |------------------------------------>|
  | initialize result                   |
  |<------------------------------------|
  | notifications/initialized           |
  |------------------------------------>|
  | tools/list request                  |
  |------------------------------------>|
  | list containing purebasic/check     |
  |<------------------------------------|
  | tools/call purebasic/check          |
  |------------------------------------>|
  | text result with bounded output     |
  |<------------------------------------|
```

This is not only a demonstration. It is a useful developer tool. Once
registered with an MCP host, an AI assistant can ask the repository itself to
run its PureBasic verification workflow. The result returns through the same
MCP channel the assistant already understands.

## What the library provides today

At alpha, the library provides enough pieces to build a small local MCP stdio
server:

- Content-Length framing helpers for JSON-RPC/LSP-style transports.
- Newline-delimited stdio codec for MCP.
- Connection state, queued writes, close behavior, and fake test writers.
- JSON-RPC validation and standard response builders.
- Request and notification dispatch.
- Outbound requests and pending response tracking.
- Batch handling.
- Cooperative cancellation state.
- Diagnostics counters and trace hooks.
- JSON-RPC compliance smoke coverage.
- MCP lifecycle helpers.
- MCP tool registry, `tools/list`, `tools/call`, and text result helpers.
- A `.pbp`-driven build harness and alpha package flow.

This is enough for the first generation of local tool servers. It is not yet a
complete MCP platform.

## What it does not provide yet

The project does not yet provide:

- Streamable HTTP transport.
- OAuth or hosted authorization flows.
- MCP resources.
- MCP prompts.
- Rich content rendering beyond basic tool result helpers.
- A production sandbox for arbitrary command execution.
- A schema generator.
- A multi-client server runtime.
- A long-term stable API promise.

Those omissions are deliberate. A small stdio server is easier to secure,
test, and explain than a network service. The alpha package should be judged as
a practical foundation, not as a finished ecosystem.

## Security posture

MCP makes capabilities discoverable to AI applications. That is powerful, and
powerful interfaces need boundaries. The MCP tools specification emphasizes
human visibility and approval for tool invocations. A server should make clear
what tools exist, what they can do, and when a model is asking to use them.

For PureBasic stdio servers, the most important boundaries are:

- Keep stdout protocol-only.
- Send diagnostic logs to stderr or a file.
- Treat input JSON as untrusted.
- Bound message sizes and command output.
- Do not execute arbitrary shell input from a model.
- Prefer small tools with clear schemas.
- Return errors as structured results instead of crashing.
- Use user approval in the host for operations that change files, run
  commands, call services, or expose sensitive data.

The `purebasic/check` example intentionally runs a repository-local command.
That is acceptable for a developer-facing example, but it is not a sandbox.
The safe production version of a command-running tool would narrow allowed
commands, validate paths, separate privileges, and document exactly what may be
read or changed.

## Why this matters

The most useful AI tools will not all be hosted web services. Many will be
small local programs that know a particular machine, codebase, compiler, or
workflow. PureBasic can be a strong language for those programs because it can
produce native executables and keep deployment simple.

MCP gives those executables a shared protocol. PureBasic JSON-RPC gives
PureBasic developers a tested path into that protocol.

The result is a practical loop:

```text
PureBasic codebase
  |
  v
native MCP stdio server
  |
  v
AI host with user approval
  |
  v
safer, more capable local automation
```

That is the purpose of this project: not to wrap every feature of MCP on day
one, but to make the first correct local server straightforward enough that
PureBasic becomes a credible option for MCP development.

## References

- [What is the Model Context Protocol?](https://modelcontextprotocol.io/docs/getting-started/intro)
- [MCP architecture](https://modelcontextprotocol.io/docs/learn/architecture)
- [MCP transports, 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/basic/transports)
- [MCP lifecycle, 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/basic/lifecycle)
- [MCP tools, 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/server/tools)
- [JSON-RPC 2.0 specification](https://www.jsonrpc.org/specification)
- [PureBasic command-line compiler](https://www.purebasic.com/documentation/reference/cli_compiler.html)
- [PureBasic IDE command-line options](https://www.purebasic.com/documentation/reference/ide_commandline.html)
