# Building a PureBasic JSON-RPC 2.0 Framework Inspired by vscode-jsonrpc

This document describes how to build a practical JSON-RPC 2.0 framework in PureBasic. It is written as an engineering specification, but it also explains the background concepts so a reader who is new to stream protocols, JSON-RPC, or vscode-jsonrpc-style architecture can still understand why each pattern exists.

The design is inspired by the connection model used by Microsoft's `vscode-jsonrpc` package: a connection owns a message reader, a message writer, request and notification handlers, outbound request tracking, cancellation support, and structured error handling.

The goal is not to reproduce every feature of vscode-jsonrpc. The goal is to bring its most useful architectural ideas into a PureBasic implementation that is explicit, memory-conscious, and safe for long-running tools.

Primary references:

* JSON-RPC 2.0 Specification: https://www.jsonrpc.org/specification
* vscode-jsonrpc package and repository: https://github.com/microsoft/vscode-languageserver-node/tree/main/jsonrpc

------------------------------------------------------------
## 1. Goals, Non-Goals, and System Shape

### Basic idea

JSON-RPC is a lightweight protocol for calling methods across a boundary. One side sends a JSON object that says, for example, "call method `math/add` with these parameters." The other side either returns a `result` or an `error`.

In a real tool, the two sides may be:

* An editor talking to a language server.
* An AI agent talking to a local tool process.
* A desktop app talking to a background service.
* Two processes communicating over stdio, pipes, or TCP sockets.

The important point is that JSON-RPC defines the message shape, not the transport. This framework must therefore solve two different problems:

1. Transport framing: how raw bytes become complete JSON messages.
2. Protocol dispatch: how complete JSON messages become method calls and responses.

### Goals

* Provide a reusable JSON-RPC 2.0 connection abstraction for PureBasic.
* Support stream-based transports such as stdio, named pipes, and TCP sockets.
* Parse `Content-Length` framed messages safely across arbitrary chunk boundaries.
* Register request and notification handlers by method name.
* Dispatch inbound requests, notifications, responses, and batches.
* Track outbound requests until a response, timeout, or cancellation.
* Use JSON-RPC 2.0 error objects consistently.
* Keep JSON parsing and freeing localized so memory ownership is obvious.
* Make concurrency explicit with queues, mutexes, worker threads, and cooperative cancellation.

### Non-goals

* Do not promise complete parity with vscode-jsonrpc.
* Do not hide PureBasic memory ownership behind a complex abstraction.
* Do not embed Language Server Protocol behavior into the base JSON-RPC layer.
* Do not forcibly terminate worker threads for cancellation.
* Do not assume a single read operation contains a complete message.
* Do not optimize for benchmark numbers before correctness and leak safety are proven.

### CTO view

Purpose: create a small communication framework that can safely connect PureBasic tools to modern agent, editor, or service workflows.

Benefit: the team gets a reusable RPC foundation instead of one-off command parsers for every tool.

Risk: protocol bugs can create hard-to-debug failures such as lost responses, memory leaks, blocked pipes, or silent data corruption. The design must therefore prioritize correctness, observability, and test coverage before raw throughput.

------------------------------------------------------------
## 2. JSON-RPC 2.0 Protocol Compliance

### Basic idea

JSON-RPC 2.0 messages are ordinary JSON values with a few required fields. A request asks the remote side to do something. A response answers a request. A notification is like a request, but it does not ask for a response.

Example request:

```json
{"jsonrpc":"2.0","id":1,"method":"math/add","params":{"a":2,"b":3}}
```

Example response:

```json
{"jsonrpc":"2.0","id":1,"result":5}
```

Example notification:

```json
{"jsonrpc":"2.0","method":"window/logMessage","params":{"message":"Started"}}
```

### Required rules

* Every JSON-RPC 2.0 request or response must include `"jsonrpc": "2.0"`.
* A request must include a String `method`.
* `params`, when present, must be an Object or Array.
* `id`, when present, may be a String, Number, or Null. Null is valid but discouraged for requests because Null is also used when the server cannot determine an id.
* A notification is a request object without an `id` member.
* Notifications must not receive responses, including notifications inside batches.
* A response must include either `result` or `error`, never both.
* A response id must match the request id.
* If the request id cannot be determined, the response id must be Null.
* Batch requests are part of JSON-RPC 2.0.
* An empty batch is invalid.

### Standard error codes

* `-32700`: Parse error. The JSON text is invalid.
* `-32600`: Invalid Request. The JSON is valid, but the message is not a valid JSON-RPC request.
* `-32601`: Method not found. The method name is valid, but no handler is registered.
* `-32602`: Invalid params. The method exists, but the parameters are missing or wrong.
* `-32603`: Internal error. The handler failed unexpectedly.
* `-32000` to `-32099`: Implementation-defined server errors.

### Why strict validation matters

A JSON-RPC framework is often used between independently developed components. If this layer accepts malformed messages too loosely, invalid behavior spreads upward into business logic. If it rejects messages inconsistently, clients cannot recover predictably.

The dispatcher should therefore validate in this order:

1. Is the message valid JSON?
2. Is the root a valid JSON-RPC object or batch array?
3. Is the object a request, notification, or response?
4. Are the required fields valid?
5. Is the method registered?
6. Are the parameters valid for the handler?

### CTO view

Purpose: make the protocol behavior predictable and interoperable.

Benefit: clients can rely on standard JSON-RPC errors, which reduces integration cost and support burden.

Risk: under-validation can cause incorrect tool execution; over-validation can reject legitimate clients. The safest approach is to follow the JSON-RPC 2.0 specification exactly and keep any application-specific rules inside handlers.

------------------------------------------------------------
## 3. Transport and Content-Length Framing

### Basic idea

Streams do not preserve message boundaries. A call to read from stdin or a socket may return:

* Half of a header.
* One full message.
* One message plus the start of the next message.
* Several messages at once.

That means the framework cannot call `Input()` or read from a socket and assume it has exactly one JSON message.

vscode-jsonrpc-style transports commonly use headers like this:

```text
Content-Length: 58

{"jsonrpc":"2.0","id":1,"method":"ping","params":{}}
```

The blank line after the header is represented as `#CRLF$ + #CRLF$`. The body length is measured in bytes, not characters.

### Responsibilities

The framing layer reads bytes and emits complete JSON body strings. It must not parse JSON or dispatch methods. Its only job is to turn a byte stream into complete message bodies.

### PureBasic-style state

```purebasic
Structure JSONRPC_FrameState
  *buffer
  bufferSize.i
  readOffset.i
  writeOffset.i
  expectedBodyLength.i
  headerComplete.i
  maxHeaderBytes.i
  maxBodyBytes.i
EndStructure

Structure JSONRPC_Message
  body.s
  byteLength.i
EndStructure
```

### Framing flow

1. Append incoming bytes to a reusable buffer.
2. Search for the header terminator: `#CRLF$ + #CRLF$`.
3. Parse `Content-Length`.
4. Validate that the length is numeric, positive or zero, and below the configured maximum body size.
5. Wait until the buffer contains exactly enough body bytes.
6. Extract the body.
7. Preserve any bytes after the body because they may belong to the next message.
8. Push the body string into the message queue.

Pseudocode:

```purebasic
Procedure JSONRPC_PushBytes(*state.JSONRPC_FrameState, *chunk, chunkLength.i)
  AppendBytesToRingBuffer(*state, *chunk, chunkLength)

  While HeaderAndBodyAvailable(*state)
    header.s = ReadHeaderBlock(*state)
    bodyLength.i = ParseContentLength(header)

    If bodyLength < 0
      SignalTransportError("Missing or invalid Content-Length")
      Break
    EndIf

    If bodyLength > *state\maxBodyBytes
      SignalTransportError("Message body exceeds configured maximum")
      Break
    EndIf

    If AvailableBodyBytes(*state) < bodyLength
      RestoreHeaderState(*state, header, bodyLength)
      Break
    EndIf

    body.s = ReadBodyAsUTF8String(*state, bodyLength)
    EnqueueCompleteMessage(body)
  Wend
EndProcedure
```

### Implementation notes

* Use byte counts for `Content-Length`; do not use character counts.
* Keep a maximum header size to avoid unbounded memory growth.
* Keep a maximum body size to avoid accidental or malicious oversized messages.
* Treat malformed headers as transport errors, not JSON-RPC method errors.
* Treat disconnects as connection close events, not parser crashes.

### CTO view

Purpose: prevent stream boundary bugs from corrupting protocol messages.

Benefit: the framework can safely handle real transports where message chunks arrive unpredictably.

Risk: incorrect byte counting is one of the most dangerous defects in this layer. It can break Unicode messages, merge two requests, truncate JSON, or block forever waiting for bytes that will never arrive.

------------------------------------------------------------
## 4. Message Reader and Writer Model

### Basic idea

The connection should not care whether bytes come from stdio, TCP, a named pipe, or a test fixture. This is why vscode-jsonrpc separates message readers and message writers from the connection itself.

In this PureBasic design:

* A reader turns transport bytes into JSON body strings.
* A writer turns JSON body strings into framed transport bytes.
* A connection owns protocol state and dispatches messages.

This separation makes the framework easier to test because a fake reader and fake writer can be used without opening sockets or processes.

### Public interface

```purebasic
JSONRPC_CreateConnection(*reader, *writer)
JSONRPC_Listen(*connection)
JSONRPC_Close(*connection)
```

### Reader responsibilities

* Own the transport-specific read loop.
* Feed raw bytes into the framing layer.
* Push complete JSON body strings to the connection queue.
* Signal transport close or transport failure.

### Writer responsibilities

* Serialize outbound JSON strings into framed messages.
* Prefix each body with `Content-Length: <bytes>` and a blank line.
* Write bytes under a writer mutex so concurrent sends cannot interleave.
* Report write failure to the connection.

Writer pseudocode:

```purebasic
Procedure JSONRPC_WriteMessage(*writer.JSONRPC_Writer, body.s)
  bodyLength.i = UTF8ByteLength(body)
  header.s = "Content-Length: " + Str(bodyLength) + #CRLF$ + #CRLF$

  LockMutex(*writer\mutex)
  WriteTransportBytes(*writer, header)
  WriteTransportBytes(*writer, body)
  UnlockMutex(*writer\mutex)
EndProcedure
```

### CTO view

Purpose: decouple protocol logic from operating-system I/O details.

Benefit: the same protocol engine can work over multiple transports and can be tested without live networking.

Risk: too much abstraction can make a small PureBasic project harder to follow. Keep the reader and writer interfaces narrow: read complete message bodies, write complete message bodies, report close and failure.

------------------------------------------------------------
## 5. Connection Lifecycle

### Basic idea

The connection is the main runtime object. It owns the protocol state for one peer relationship. A process may have one connection or many, depending on the application.

The connection should know:

* Which methods are registered.
* Which outbound requests are waiting for responses.
* Which inbound long-running requests may be cancelled.
* Whether the connection is running or closing.
* How to write responses and notifications.

### PureBasic-style structure

```purebasic
Structure JSONRPC_Connection
  *reader.JSONRPC_Reader
  *writer.JSONRPC_Writer
  Map requestHandlers.i()
  Map notificationHandlers.i()
  Map pending.JSONRPC_PendingRequest()
  Map cancellations.JSONRPC_CancellationToken()
  mutex.i
  writerMutex.i
  running.i
  closing.i
  nextId.q
EndStructure
```

### Lifecycle phases

1. Create: allocate maps, queues, mutexes, and counters.
2. Register: attach request and notification handlers.
3. Listen: start reader processing and dispatch inbound messages.
4. Run: process requests, notifications, responses, batches, timeouts, and cancellation.
5. Close: stop reading, reject pending requests, flush or close writer, free memory.

Pseudocode:

```purebasic
Procedure JSONRPC_Listen(*connection.JSONRPC_Connection)
  *connection\running = #True
  StartReader(*connection\reader)

  While *connection\running
    message.s = DequeueMessageOrWait()

    If message <> ""
      JSONRPC_ProcessRawMessage(*connection, message)
    EndIf

    JSONRPC_CheckPendingTimeouts(*connection)
  Wend
EndProcedure
```

### Shutdown rules

* Closing should be idempotent. Calling close twice should not crash.
* Pending outbound requests should complete with a connection-closed error.
* In-flight handlers should receive cancellation where possible.
* The writer should not accept new messages after close begins.
* Transport errors should be observable through logs or diagnostics.

### CTO view

Purpose: make the framework's runtime behavior explicit from startup to shutdown.

Benefit: predictable lifecycle management reduces leaks, stuck threads, and half-closed connections.

Risk: shutdown paths are often undertested. A framework that works during normal requests can still fail when the peer disconnects, the process exits, or a write fails during close.

------------------------------------------------------------
## 6. Dispatcher and Handler Registration

### Basic idea

The dispatcher is the routing layer. It receives a valid JSON-RPC request or notification, looks up the method name, and calls the registered PureBasic procedure.

Requests and notifications should be registered separately because they have different response behavior:

* Request: has an `id`, expects a response.
* Notification: has no `id`, must not receive a response.

### Public interface

```purebasic
JSONRPC_RegisterRequest(method.s, *handler)
JSONRPC_RegisterNotification(method.s, *handler)
```

### Handler structures

```purebasic
Prototype.i JSONRPC_RequestHandler(*params, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
Prototype.i JSONRPC_NotificationHandler(*params, *context.JSONRPC_RequestContext)

Structure JSONRPC_RequestContext
  method.s
  idText.s
  hasId.i
  isCancellationRequested.i
  *connection.JSONRPC_Connection
EndStructure

Structure JSONRPC_HandlerResult
  ok.i
  *jsonResult
  errorCode.i
  errorMessage.s
  *errorData
EndStructure
```

### Registration pseudocode

```purebasic
Procedure JSONRPC_RegisterRequest(*connection.JSONRPC_Connection, method.s, *handler)
  If method = ""
    ProcedureReturn #False
  EndIf

  LockMutex(*connection\mutex)
  *connection\requestHandlers(method) = *handler
  UnlockMutex(*connection\mutex)

  ProcedureReturn #True
EndProcedure
```

### Dispatch rules

* If an inbound object has `method` and `id`, treat it as a request.
* If an inbound object has `method` and no `id`, treat it as a notification.
* If an inbound object has no `method` but has `id` and `result` or `error`, treat it as a response.
* Unknown request method returns `-32601`.
* Unknown notification method may be logged, but must not produce a response.
* Handler parameter validation failures should return `-32602`.
* Unexpected handler failures should return `-32603`.

### Why a map-based dispatcher matters

A method map avoids a long chain of string comparisons such as:

```purebasic
If method = "a"
ElseIf method = "b"
ElseIf method = "c"
EndIf
```

A map also lets plugins or modules register their own methods without editing a central dispatch procedure.

### CTO view

Purpose: provide a stable extension point for tool capabilities.

Benefit: new methods can be added without changing the core protocol engine.

Risk: method naming and parameter validation become part of the public contract. The project should document method names, parameter schemas, and error behavior for every registered handler.

------------------------------------------------------------
## 7. Outbound Requests and Pending-Response Tracking

### Basic idea

JSON-RPC is bidirectional. Even if this framework is used in a "server" process, it may still need to send requests to the peer and wait for answers.

For example, a PureBasic tool may ask the editor:

* What workspace folder is open?
* What configuration value should I use?
* Should I continue a long-running operation?

When the framework sends an outbound request, it must remember the request id until a matching response arrives.

### Public interface

```purebasic
JSONRPC_SendRequest(method.s, *params, timeoutMs.i)
JSONRPC_SendNotification(method.s, *params)
```

### Pending request structure

```purebasic
Structure JSONRPC_PendingRequest
  idText.s
  method.s
  createdAt.q
  timeoutMs.i
  completed.i
  *callback
EndStructure
```

### Outbound request flow

1. Generate a unique id.
2. Build the JSON-RPC request object.
3. Insert a pending record before writing the message.
4. Write the framed message.
5. When a response arrives, look up the id.
6. Complete the caller or callback.
7. Remove the pending record.

Pseudocode:

```purebasic
Procedure.s JSONRPC_SendRequest(*connection.JSONRPC_Connection, method.s, *params, timeoutMs.i)
  idText.s = JSONRPC_NextRequestId(*connection)
  body.s = BuildRequestJSON(method, *params, idText)

  LockMutex(*connection\mutex)
  *connection\pending(idText)\idText = idText
  *connection\pending(idText)\method = method
  *connection\pending(idText)\createdAt = ElapsedMilliseconds()
  *connection\pending(idText)\timeoutMs = timeoutMs
  UnlockMutex(*connection\mutex)

  JSONRPC_WriteMessage(*connection\writer, body)
  ProcedureReturn idText
EndProcedure
```

### Timeout behavior

Timeouts prevent the pending map from growing forever when the peer never responds.

The timeout monitor should:

* Scan pending requests on a fixed interval.
* Mark expired requests as failed.
* Remove expired records.
* Notify the original caller or callback.
* Avoid holding the main connection mutex while executing user callbacks.

### CTO view

Purpose: support full bidirectional protocol workflows.

Benefit: the framework can participate in richer protocols instead of only passively receiving commands.

Risk: pending-request bugs cause memory leaks, duplicate completions, or responses being delivered to the wrong caller. The id generator, pending map, timeout monitor, and response handler must be tested together.

------------------------------------------------------------
## 8. Notifications and Cooperative Cancellation

### Basic idea

A notification is a one-way JSON-RPC message. It does not have an `id`, and the receiver must not send a response.

Notifications are useful for:

* Progress updates.
* Log messages.
* State changes.
* Fire-and-forget events.
* Cancellation signals.

Cancellation deserves special care. In LSP-style systems, cancellation is commonly expressed as a notification named `$/cancelRequest`. This is not part of base JSON-RPC 2.0, but it is a useful convention.

### Public interface

```purebasic
JSONRPC_SendNotification(method.s, *params)
JSONRPC_CancelRequest(id.s)
```

### Cancellation token

```purebasic
Structure JSONRPC_CancellationToken
  idText.s
  cancelled.i
  mutex.i
EndStructure
```

### Cancellation flow

1. A long-running request starts.
2. The connection creates a cancellation token for that request id.
3. The handler receives a context that can check the token.
4. The peer sends `$/cancelRequest` with the target request id.
5. The framework marks the token as cancelled.
6. The handler periodically checks the token.
7. The handler exits cleanly when cancellation is detected.

Pseudocode:

```purebasic
Procedure JSONRPC_CancelRequest(*connection.JSONRPC_Connection, idText.s)
  params = BuildCancelParams(idText)
  JSONRPC_SendNotification(*connection, "$/cancelRequest", params)
EndProcedure

Procedure.i JSONRPC_IsCancellationRequested(*context.JSONRPC_RequestContext)
  ProcedureReturn *context\isCancellationRequested
EndProcedure
```

### Important limitation

Cancellation should be cooperative. The framework should not forcibly kill a PureBasic thread that is executing a handler. Forced thread termination can leave mutexes locked, memory unfreed, files half-written, and application state corrupted.

### CTO view

Purpose: allow expensive operations to stop when their result is no longer needed.

Benefit: cancellation improves responsiveness and protects compute resources during AI or editor-driven workflows where plans change quickly.

Risk: cancellation only works if handlers check the token regularly. Long-running handlers that never check cancellation will still run to completion.

------------------------------------------------------------
## 9. Batch Handling

### Basic idea

JSON-RPC 2.0 allows a client to send an array of request objects in one message. This is called a batch.

Example:

```json
[
  {"jsonrpc":"2.0","id":1,"method":"math/add","params":{"a":1,"b":2}},
  {"jsonrpc":"2.0","method":"window/logMessage","params":{"message":"hello"}},
  {"jsonrpc":"2.0","id":2,"method":"math/subtract","params":{"a":5,"b":3}}
]
```

Only requests with ids produce responses. Notifications inside the batch do not.

### Batch rules

* An empty array is invalid and returns one `-32600` response.
* Each item is processed independently.
* Request items may produce response objects.
* Notification items must not produce response objects.
* Invalid items produce `-32600` response objects with `id: null`.
* If every item is a notification and no item requires a response, send nothing.
* Sequential execution is recommended for the first implementation.

### Why sequential first

The JSON-RPC specification permits batch items to be processed in any order. However, concurrent batch processing adds complexity:

* Shared handler state may need stronger locking.
* Response ordering may surprise clients.
* Cancellation and timeout behavior becomes harder to test.
* Memory ownership becomes more complex.

Sequential batch processing is easier to reason about and is usually sufficient for a first framework version.

Pseudocode:

```purebasic
Procedure JSONRPC_ProcessBatch(*connection.JSONRPC_Connection, jsonRoot)
  If JSONArraySize(jsonRoot) = 0
    JSONRPC_WriteMessage(*connection\writer, BuildError(-32600, "Invalid Request", #Null))
    ProcedureReturn
  EndIf

  responses = CreateJSONArray()

  ForEach item In jsonRoot
    response = JSONRPC_ProcessSingleValue(*connection, item)
    If response <> #Null
      AddJSONArrayElement(responses, response)
    EndIf
  Next

  If JSONArraySize(responses) > 0
    JSONRPC_WriteMessage(*connection\writer, SerializeJSON(responses))
  EndIf
EndProcedure
```

### CTO view

Purpose: support standard JSON-RPC batch messages without overcomplicating version 1.

Benefit: batch support improves interoperability with clients that group calls for efficiency.

Risk: concurrent batch execution may introduce race conditions. Start sequentially, then add worker-pool execution only when real workloads justify it.

------------------------------------------------------------
## 10. Memory Lifecycle and Diagnostics

### Basic idea

PureBasic's JSON library is useful, but JSON handles must be managed carefully. Every `ParseJSON()` must eventually have a matching `FreeJSON()`.

The safest ownership rule is:

* The connection parses a raw message.
* The connection dispatches it.
* Handlers copy only the data they need beyond the current call.
* The connection frees the parsed JSON root before returning.

This prevents long-lived business logic from accidentally holding references to JSON data that should already be gone.

### Processing pseudocode

```purebasic
Procedure JSONRPC_ProcessRawMessage(*connection.JSONRPC_Connection, body.s)
  jsonId.i = ParseJSON(#PB_Any, body)

  If jsonId = 0
    JSONRPC_WriteMessage(*connection\writer, BuildError(-32700, "Parse error", "null"))
    ProcedureReturn
  EndIf

  root = JSONValue(jsonId)

  If JSONType(root) = #PB_JSON_Array
    JSONRPC_ProcessBatch(*connection, root)
  Else
    response = JSONRPC_ProcessSingleValue(*connection, root)
    If response <> #Null
      JSONRPC_WriteMessage(*connection\writer, SerializeJSON(response))
    EndIf
  EndIf

  FreeJSON(jsonId)
EndProcedure
```

### Memory requirements

* Every `ParseJSON()` must be paired with `FreeJSON()`.
* Do not pass root JSON handles into long-lived business logic.
* Copy values needed by worker threads.
* Reuse static strings for common error messages where practical.
* Bound buffer sizes and message sizes.
* Avoid dynamic allocation inside tight loops where static buffers or reusable structures are practical.

### Diagnostics to collect

At minimum, the framework should count:

* Bytes read.
* Bytes written.
* Messages parsed.
* Parse errors.
* Invalid requests.
* Method-not-found errors.
* Handler errors.
* Notifications received.
* Requests completed.
* Pending request timeouts.
* Orphan responses.
* Transport closes.

Diagnostics should be visible enough that an operator can answer:

* Is the peer sending malformed JSON?
* Are requests timing out?
* Are unknown methods being called?
* Is the transport closing unexpectedly?
* Is memory usage stable during long runs?

### Benchmarking note

Do not claim a fixed memory footprint such as "always below 2MB-4MB" unless a repeatable benchmark proves it. A better target is:

* steady memory usage under a named stress test
* no increasing JSON handle count
* no increasing pending request count after timeouts
* no unbounded buffer growth

### CTO view

Purpose: make memory ownership and operational health measurable.

Benefit: predictable memory behavior is essential for long-running local services and AI tool processes.

Risk: memory leaks may not appear in small tests. Stress tests must include malformed input, high request volume, disconnects, timeouts, and cancellation.

------------------------------------------------------------
## 11. Acceptance Tests

### Protocol tests

* Invalid JSON returns `-32700` with `id: null`.
* Invalid request object returns `-32600`.
* Unknown method returns `-32601` only for requests, not notifications.
* Handler parameter validation returns `-32602`.
* Handler failure returns `-32603`.
* Notification produces no response.
* Response includes either `result` or `error`, never both.
* Response id matches request id.

### Framing tests

* Header split across multiple reads.
* Body split across multiple reads.
* Header and body delivered in one read.
* Multiple messages delivered in one read.
* Unicode body uses correct UTF-8 byte length.
* Invalid `Content-Length` is rejected.
* Oversized header is rejected.
* Oversized body is rejected.

### Batch tests

* Empty batch returns `-32600`.
* Batch with valid requests returns response array.
* Batch with mixed valid requests, invalid requests, and notifications returns only required responses.
* Batch containing only notifications produces no response.
* Invalid item inside batch produces `id: null`.

### Concurrency and lifecycle tests

* Outbound request timeout removes pending state safely.
* Orphan inbound response is logged and ignored.
* Writer mutex prevents interleaved framed messages.
* Connection close rejects pending outbound requests.
* Disconnect during partial message closes cleanly.
* Cancellation notification sets a cooperative cancellation flag without killing threads.

### Memory tests

* Repeated parse and dispatch does not leak JSON handles.
* Malformed messages do not leak parsed state.
* Batch processing frees all temporary JSON values.
* Timeout cleanup removes pending records.
* Long-running stress test shows bounded buffer growth.

### CTO view

Purpose: define what "done" means in a way that protects production use.

Benefit: tests cover the protocol edge cases most likely to break integrations.

Risk: tests that only cover happy-path method calls will miss the most expensive failures. The test suite must deliberately include malformed input, partial streams, disconnects, timeouts, and cancellation.

------------------------------------------------------------
## Recommended Build Order

1. Implement the framed message reader and writer.
2. Add connection creation, listen, and close lifecycle.
3. Add JSON parsing, single-message validation, and standard error generation.
4. Add request and notification registration.
5. Add inbound dispatch and response writing.
6. Add outbound request ids and pending-response tracking.
7. Add timeout housekeeping.
8. Add batch handling.
9. Add optional `$/cancelRequest` notification support.
10. Add diagnostics counters.
11. Add stress tests and memory lifecycle tests.

This order keeps the framework close to the vscode-jsonrpc mental model while staying realistic for PureBasic: transport first, protocol second, concurrency third, and optimization last.

------------------------------------------------------------
## Executive Summary for CTO Review

This framework is a reusable communication layer for PureBasic tools that need to interact with editors, agents, background services, or other processes through JSON-RPC 2.0.

The main architectural decision is to separate transport framing from protocol dispatch. This prevents stream parsing bugs from leaking into business logic and allows the same protocol engine to run over stdio, pipes, TCP, or test fixtures.

The main implementation benefit is maintainability. New methods can be registered as handlers instead of being hard-coded into a central parser. Outbound requests, pending responses, timeouts, and cancellation become reusable framework behavior rather than duplicated application code.

The main technical risks are stream boundary handling, JSON memory lifecycle, concurrency safety, and incomplete protocol validation. These risks are manageable if the first implementation is deliberately conservative: sequential batch processing, cooperative cancellation, mutex-protected writer and pending maps, strict error responses, bounded buffers, and stress tests before optimization.

The recommended version 1 should optimize for correctness and observability. Performance tuning, worker pools, and advanced scheduling should come after the protocol engine has proven stable under fragmented input, malformed messages, disconnects, timeouts, cancellation, and high-volume parse/free cycles.
