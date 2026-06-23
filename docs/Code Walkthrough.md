# คู่มือเดินโค้ดโครงการ PureBasic JSON-RPC 2.0

เอกสารฉบับนี้เขียนขึ้นเพื่อช่วยให้ผู้อ่านที่เข้ามารีวิวโครงการจากภายนอก
เข้าใจภาพรวมและโค้ดทีละชั้น ตั้งแต่เหตุผลของโครงการ รอบเริ่มต้น `000`
ตัวอย่างแรก ไล่ไปจนถึงตัวอย่างทั้งหมดและไฟล์ซอร์สที่เกี่ยวข้อง

เป้าหมายของเอกสารนี้ไม่ใช่การแทนที่ API reference ใน `API/` และไม่ใช่คู่มือ
MCP เชิงบทความแบบ `docs/mcp-for-purebasic.md` แต่เป็นแผนที่สำหรับเดินอ่านโค้ด:
เริ่มจาก "ทำไมต้องมีโครงการนี้" แล้วค่อยประกอบชิ้นส่วน JSON-RPC, transport,
connection, protocol, dispatch, lifecycle, testing, packaging และตัวอย่าง MCP
ให้เห็นเป็นระบบเดียวกัน

## 1. ทำไมโครงการนี้จึงมีอยู่

โครงการนี้สร้างไลบรารี JSON-RPC 2.0 ด้วยภาษา PureBasic โดยมีเป้าหมายหลักคือ
ทำให้การเขียน MCP server ด้วย PureBasic เป็นเรื่องปฏิบัติได้จริงในอนาคต

เหตุผลสำคัญมีอยู่สามชั้น:

1. JSON-RPC เป็นแกนกลางของการสื่อสารแบบ request, response, notification และ
   batch ที่ MCP ใช้เป็นฐาน
2. MCP server แบบ `stdio` ต้องมีวินัยเรื่องข้อความ, stdout, stderr, lifecycle
   และการเรียก tools ที่ชัดเจน
3. PureBasic เหมาะกับงาน local tool server เพราะคอมไพล์เป็น native executable
   ได้ ติดตั้งง่าย และควบคุมชนิด target ผ่าน `.pbp` ได้ชัดเจน

กล่าวอีกแบบหนึ่ง โครงการนี้ไม่ได้เริ่มจากการสร้าง MCP server สำเร็จรูปเพียงตัว
เดียว แต่เริ่มจากการสร้างฐาน JSON-RPC ที่มั่นคงก่อน แล้วจึงต่อ adapter และ
ตัวอย่าง MCP ขึ้นไปด้านบน

ภาพรวมชั้นสถาปัตยกรรม:

```text
MCP example servers
  purebasic/check
  sqlite-admin
        |
MCP adapter helpers
  mcp_lifecycle.pbi
  mcp_tools.pbi
        |
JSON-RPC runtime
  stdio_runtime.pbi
  dispatch.pbi
  batch.pbi
  outbound.pbi
  cancel.pbi
        |
Protocol and connection
  protocol.pbi
  connection.pbi
  io.pbi
        |
Transport and bytes
  codec.pbi
  framing.pbi
  byte_buffer.pbi
```

สิ่งที่ควรจำตั้งแต่ต้น:

- แกนกลางใช้ชื่อขึ้นต้นด้วย `JSONRPC_*`
- ส่วน MCP ใช้ชื่อขึ้นต้นด้วย `MCP_*`
- ตัวอย่างหลักแบบลำดับเลขอยู่ใน `examples/NNN-*`
- ตัวอย่าง MCP ที่เป็นโครงการจริงอยู่ใน `MCP/examples/*`
- การ build ใช้ `.pbp` เป็นแหล่งความจริงของ target ไม่ใช่ flag ชั่วคราว
- เอกสาร API ของแต่ละ milestone อยู่ใน `API/NNN-*.md`

## 2. จุดเริ่มต้น: รอบ 000 และตัวอย่างแรก

รอบ `000-project-foundation` เป็นการวางรากฐานก่อนเขียน JSON-RPC จริง

ไฟล์ที่ควรอ่าน:

- `examples/000-project-foundation/console_probe.pb`
- `examples/000-project-foundation/project_foundation.pbp`
- `tests/unit/000_project_foundation.pb`
- `API/000-project-foundation.md`
- `docs/harness.md`
- `tools/discover-purebasic.sh`
- `tools/test.sh`
- `tools/build.sh`
- `tools/check.sh`

แนวคิดของรอบนี้คือ "ก่อนเขียนไลบรารี เราต้องทำให้เครื่องมือเชื่อถือได้"

`console_probe.pb` เป็นตัวอย่างแรกสุด เป็น console application ขนาดเล็กที่
ยืนยันว่า:

- PureBasic compiler ทำงาน
- processor target อยู่ในกลุ่มที่รองรับ
- JSON library พื้นฐานของ PureBasic ใช้ได้
- โปรแกรมตัวอย่าง build และ run ผ่าน harness ได้จริง

สิ่งสำคัญสำหรับ reviewer:

- อย่ามอง `000` ว่าเป็นเพียง smoke test ธรรมดา เพราะมันพิสูจน์ว่าสภาพแวดล้อม
  build/test ถูกล็อกไว้ก่อนเริ่ม feature อื่น
- `.pbp` ของตัวอย่างบอกว่า target เป็น console ชัดเจน
- `tools/check.sh` ไม่ได้ทำแค่ test แต่เรียงลำดับ discovery, project metadata
  verification, docs verification, path verification, PureUnit, build, scenario
  run, docs build, packaging และ release artifact verification

เส้นทางจากรอบ 000 ไปยังรอบถัดไปคือ:

```text
เครื่องมือพร้อม
  -> อ่าน/เขียน frame ได้
  -> รับข้อความ stdio ได้
  -> มี connection state
  -> ตรวจ JSON-RPC protocol
  -> dispatch ไปหา handler
```

## 3. วิธีอ่าน repository โดยไม่หลงทาง

โครงการนี้มีหลายไฟล์ แต่ไม่ได้กระจายแบบสุ่ม ให้เริ่มจากกลุ่มนี้:

```text
src/jsonrpc/
  jsonrpc.pbi          จุดรวม include สำหรับผู้ใช้ทั่วไป
  version.pbi          metadata ของไลบรารี
  byte_buffer.pbi      buffer ที่นับ byte แบบ UTF-8
  framing.pbi          Content-Length framing
  codec.pbi            newline-delimited stdio codec
  io.pbi               reader/writer fake และ generic
  connection.pbi       lifecycle, write queue, diagnostics, trace state
  protocol.pbi         ตรวจรูป JSON-RPC และสร้าง response มาตรฐาน
  dispatch.pbi         register handler และ dispatch request/notification
  outbound.pbi         ส่ง request/notification ออกและ track pending response
  batch.pbi            batch dispatch
  cancel.pbi           cooperative cancellation
  diagnostics.pbi      counters และ summary
  stress.pbi           stress helper
  trace.pbi            trace/logging helper
  compliance.pbi       compliance runner
  stdio_runtime.pbi    runtime pump สำหรับ stdio
  mcp_lifecycle.pbi    initialize / notifications/initialized
  mcp_tools.pbi        tools/list และ tools/call
```

ให้เข้าใจว่า `jsonrpc.pbi` ดูสั้นมากโดยตั้งใจ:

```text
XIncludeFile "version.pbi"
XIncludeFile "trace.pbi"
XIncludeFile "compliance.pbi"
XIncludeFile "mcp_tools.pbi"
```

สาเหตุที่สั้นคือ include แต่ละตัวดึง dependency ของตัวเองต่อไปเป็นชั้น ๆ เช่น
`mcp_tools.pbi` ดึง `mcp_lifecycle.pbi`, `mcp_lifecycle.pbi` ดึง
`stdio_runtime.pbi`, และสุดท้ายลงไปถึง `framing.pbi` กับ `byte_buffer.pbi`

หากจะรีวิวเร็ว ให้ใช้ลำดับนี้:

1. อ่าน `src/jsonrpc/README.md` เพื่อดูบทบาทไฟล์
2. อ่าน `byte_buffer.pbi`, `framing.pbi`, `codec.pbi` เพื่อเข้าใจ transport
3. อ่าน `connection.pbi`, `io.pbi` เพื่อเข้าใจ lifecycle และ writer
4. อ่าน `protocol.pbi` เพื่อเข้าใจ JSON-RPC 2.0 validation
5. อ่าน `dispatch.pbi`, `batch.pbi`, `outbound.pbi`, `cancel.pbi`
6. อ่าน `stdio_runtime.pbi`
7. อ่าน `mcp_lifecycle.pbi` และ `mcp_tools.pbi`
8. อ่าน examples ตามลำดับเลข แล้วเทียบกับ tests/unit ที่เลขเดียวกัน

## 4. ชิ้นส่วน transport: bytes, frame, stdio

### 4.1 `byte_buffer.pbi`

ไฟล์นี้เป็นชั้นล่างสุดของการรับข้อความ มันไม่ได้รู้จัก JSON-RPC โดยตรง แต่รู้ว่า
ข้อความต้องถูกวัดเป็น byte แบบ UTF-8 ไม่ใช่จำนวน character อย่างเดียว

แนวคิดสำคัญ:

- `JSONRPC_ByteBuffer_AppendUtf8()` เพิ่มข้อความและอัปเดต byte length
- `maxBytes` ช่วยจำกัด buffer
- `overflow` ทำให้ชั้นบนตัดสินใจ reject ได้

ทำไมสำคัญ:

JSON-RPC และ MCP ใช้ UTF-8 ถ้าเราใช้จำนวนตัวอักษรแทน byte length จะพลาดทันที
เมื่อมีภาษาไทย ญี่ปุ่น emoji หรืออักขระ accent

### 4.2 `framing.pbi`

ไฟล์นี้รองรับ `Content-Length` framing แบบที่พบใน vscode-jsonrpc/LSP-style
transport

API สำคัญ:

- `JSONRPC_Framing_Init()`
- `JSONRPC_Framing_PushBytes()`
- `JSONRPC_Framing_NextMessage()`
- `JSONRPC_Framing_BuildFrame()`
- `JSONRPC_Framing_HasError()`

สิ่งที่ reviewer ควรดู:

- header จบด้วย `CRLF CRLF`
- `Content-Length` ต้องมีเพียงหนึ่งรายการ
- length ต้องเป็น unsigned decimal
- body ต้องไม่เกิน maximum
- ถ้า byte length ตัดกลาง UTF-8 character จะ reject
- หลังอ่านข้อความแรกแล้ว remainder ต้องยังอยู่ใน buffer เพื่ออ่านข้อความถัดไป

ตัวอย่างที่ใช้:

- `examples/001-framing/framing_probe.pb`
- `tests/unit/001_framing.pb`

ตัวอย่างนี้สร้าง stream ที่มีสอง JSON-RPC messages ต่อกัน แล้ว push เข้าไปเป็น
chunk เพื่อพิสูจน์ว่า reader ไม่ต้องได้ข้อมูลครบตั้งแต่ครั้งแรก

### 4.3 `codec.pbi`

ไฟล์นี้เพิ่ม MCP-compatible stdio codec:

- หนึ่ง JSON-RPC message ต่อหนึ่งบรรทัด
- UTF-8 text
- ไม่มี newline ฝังใน message body
- outbound message เติม newline ให้เอง
- partial line ต้องรอ ไม่รีบ dispatch
- multiple lines ใน chunk เดียวต้องแยกได้

API สำคัญ:

- `JSONRPC_Codec_StdioInit()`
- `JSONRPC_Codec_StdioPushBytes()`
- `JSONRPC_Codec_StdioNextMessage()`
- `JSONRPC_Codec_StdioBuildMessage()`

ตัวอย่างที่ใช้:

- `examples/002-transport-codecs/stdio_codec_probe.pb`
- `tests/unit/002_transport_codecs.pb`

สิ่งที่ต้องจับตามอง:

MCP stdio ต่างจาก `Content-Length` ตรงที่ delimiter คือ newline ดังนั้น
ข้อห้ามเรื่อง newline ภายใน JSON body สำคัญมาก ถ้าปล่อยให้มี newline ฝังอยู่
ตัวอ่านจะเข้าใจผิดว่าเป็นหลาย message

## 5. Connection, reader/writer และ lifecycle

### 5.1 `io.pbi`

ไฟล์นี้ให้ generic writer/reader สำหรับทดสอบและ runtime ชั้นบน:

- `JSONRPC_Writer`
- `JSONRPC_FakeWriter`
- `JSONRPC_Reader`

จุดสำคัญคือ fake writer ไม่ใช่ของเล่น แต่เป็นตัวทำให้ test deterministic:

- capture body ที่ส่งออก
- นับจำนวน write
- สั่งให้ write ถัดไป fail ได้
- ปิด writer แล้วต้อง reject write ใหม่

### 5.2 `connection.pbi`

`JSONRPC_Connection` เป็น state holder ของ runtime:

- running / closing / closed
- writer pointer
- pending requests
- cancellation tokens
- diagnostics counters
- event callback
- write queue
- trace capture

API สำคัญ:

- `JSONRPC_Connection_Init()`
- `JSONRPC_Connection_Close()`
- `JSONRPC_Connection_SendBody()`
- `JSONRPC_Connection_QueueBody()`
- `JSONRPC_Connection_FlushWrites()`
- `JSONRPC_Connection_PendingWriteCount()`

ตัวอย่างที่ใช้:

- `examples/003-connection-lifecycle/connection_probe.pb`
- `tests/unit/003_connection_lifecycle.pb`
- `examples/022-write-queue-close-semantics/write_queue_probe.pb`
- `tests/unit/022_write_queue_close_semantics.pb`

แนวคิดที่ reviewer ควรจับ:

- close ต้อง idempotent เรียกซ้ำได้อย่างปลอดภัย
- send หลัง close ต้อง fail
- write failure ต้องไม่ทิ้ง queued body ค้าง
- queued writes ต้อง flush ได้อย่างควบคุม
- connection ไม่ dispatch protocol เอง แต่เป็นที่เก็บ state ให้ dispatcher/runtime

## 6. Protocol: ตรวจ JSON-RPC ก่อนทำงานจริง

### 6.1 `protocol.pbi`

นี่คือไฟล์ที่ควรรีวิวอย่างละเอียดที่สุดตัวหนึ่ง เพราะเป็นด่านแรกของ JSON-RPC
2.0 semantics

API สำคัญ:

- `JSONRPC_Protocol_Inspect()`
- `JSONRPC_Protocol_IsValidParamsJson()`
- `JSONRPC_Protocol_BuildRequest()`
- `JSONRPC_Protocol_BuildNotification()`
- `JSONRPC_Protocol_BuildErrorResponse()`
- `JSONRPC_Protocol_BuildResultResponse()`
- `JSONRPC_Protocol_BuildMethodNotFoundResponse()`

สิ่งที่ `Inspect()` ตรวจ:

- body parse เป็น JSON ได้หรือไม่
- root เป็น object หรือไม่
- `jsonrpc` ต้องเป็น `"2.0"`
- `method` ถ้ามีต้องเป็น string
- ถ้ามี `method` และมี `id` ที่ valid แปลว่า request
- ถ้ามี `method` แต่ไม่มี `id` แปลว่า notification
- `params` ถ้ามีต้องเป็น object หรือ array
- response ต้องมี `result` หรือ `error` อย่างใดอย่างหนึ่งเท่านั้น
- `id` ต้องเป็น string, number หรือ null
- object, array หรือ boolean id เป็น invalid request และใช้ `id: null`

ตัวอย่างที่ใช้:

- `examples/004-protocol-errors/spec_examples_probe.pb`
- `tests/unit/004_protocol_errors.pb`
- `tests/unit/029_negative_tests.pb`

สิ่งที่ควรสังเกตใน PureBasic:

ทุก path ที่ `ParseJSON()` สำเร็จต้อง `FreeJSON()` เมื่อเลิกใช้ นี่เป็น rule
สำคัญของโครงการ และปรากฏซ้ำในเอกสาร agent/harness

## 7. Dispatch: จาก message ไปหา handler

### 7.1 `dispatch.pbi`

หลังจาก `protocol.pbi` บอกว่า message ถูกต้องและเป็น request/notification แล้ว
`dispatch.pbi` จะหา handler และสร้าง response

โครงสร้างสำคัญ:

- `JSONRPC_RequestContext`
- `JSONRPC_HandlerResult`
- `JSONRPC_Dispatcher`

API สำคัญ:

- `JSONRPC_Dispatcher_Init()`
- `JSONRPC_RegisterRequest()`
- `JSONRPC_RegisterNotification()`
- `JSONRPC_RegisterStarRequest()`
- `JSONRPC_RegisterStarNotification()`
- `JSONRPC_UnregisterRequest()`
- `JSONRPC_UnregisterNotification()`
- `JSONRPC_Dispatcher_Dispatch()`
- `JSONRPC_Dispatcher_DispatchToConnection()`

การไหลของ dispatch:

```text
JSON string
  -> JSONRPC_Protocol_Inspect()
  -> parse JSON อีกครั้งเพื่อเอา paramsValue
  -> เติม JSONRPC_RequestContext
  -> ถ้า notification: เรียก notification handler แล้วไม่ตอบ
  -> ถ้า request: เรียก request handler แล้วสร้าง result/error response
  -> ถ้าไม่รู้จัก method: -32601 Method not found
```

ตัวอย่างที่ใช้:

- `examples/005-dispatch/dispatch_probe.pb`
- `tests/unit/005_dispatch.pb`
- `examples/020-handler-registration-lifecycle/handler_lifecycle_probe.pb`
- `tests/unit/020_handler_registration_lifecycle.pb`

จุดสำคัญ:

- unknown request ต้องตอบ `-32601`
- unknown notification ต้องไม่ตอบ
- handler สามารถคืน `Invalid params` ได้
- star handler ช่วยรองรับ method ที่ไม่รู้ล่วงหน้า
- registration สามารถตั้ง policy ได้ว่าจะ replace handler ซ้ำหรือ reject

## 8. Outbound request, pending response และ timeout

### 8.1 `outbound.pbi`

ถึงจุดนี้ไลบรารีไม่ได้เป็นแค่ server-side dispatcher แล้ว แต่สามารถส่ง request
ออกไปและจับคู่ response กลับมาได้

API สำคัญ:

- `JSONRPC_Connection_SendRequest()`
- `JSONRPC_Connection_SendNotification()`
- `JSONRPC_Connection_MatchResponse()`
- `JSONRPC_Connection_CleanupTimeouts()`
- `JSONRPC_Connection_PendingCount()`
- `JSONRPC_Connection_HasPending()`
- `JSONRPC_Connection_PendingDeadline()`

ตัวอย่างที่ใช้:

- `examples/006-outbound-requests/outbound_probe.pb`
- `tests/unit/006_outbound_requests.pb`
- `examples/007-timeout-housekeeping/timeout_probe.pb`
- `tests/unit/007_timeout_housekeeping.pb`

แนวคิด:

- request ต้องมี id และถูกเก็บใน pending map
- notification ไม่มี response จึงไม่ถูกเก็บใน pending map
- response ที่ id ตรงกันจะ remove pending
- orphan response ต้องถูก ignore และนับเป็น diagnostics ได้
- timeout default คือ `30000` ms แต่ override ต่อ request ได้

สิ่งที่ reviewer ควรดู:

การ cleanup timeout เป็น cooperative housekeeping ไม่ใช่ thread ที่ไปฆ่างาน
กลางคัน โค้ดเลือกความเรียบง่ายและ deterministic test ก่อน

## 9. Batch, cancellation และ diagnostics

### 9.1 `batch.pbi`

JSON-RPC batch เป็น array ของ request/notification/invalid item

API สำคัญ:

- `JSONRPC_Batch_IsBatch()`
- `JSONRPC_Batch_Dispatch()`
- `JSONRPC_Batch_DispatchToConnection()`

ตัวอย่างที่ใช้:

- `examples/008-batch-handling/batch_probe.pb`
- `tests/unit/008_batch_handling.pb`

กติกา:

- empty batch ตอบ `-32600`
- notification-only batch ไม่ตอบ
- mixed batch ตอบเฉพาะ item ที่ต้องมี response
- invalid item ใน batch สร้าง error object ใน response array

### 9.2 `cancel.pbi`

รองรับ `$/cancelRequest` แบบ cooperative:

- mark id ว่าถูก cancel
- handler อ่านสถานะผ่าน context ได้
- ไม่ kill thread
- หลัง request จบควร clear token

API สำคัญ:

- `JSONRPC_Cancel_Request()`
- `JSONRPC_Cancel_IsRequested()`
- `JSONRPC_Cancel_Clear()`
- `JSONRPC_Cancel_ProcessNotification()`
- `JSONRPC_RequestContext_IsCancellationRequested()`

ตัวอย่างที่ใช้:

- `examples/009-cancellation/cancel_probe.pb`
- `tests/unit/009_cancellation.pb`
- `examples/021-handler-cancellation-tokens/cancellation_token_probe.pb`
- `tests/unit/021_handler_cancellation_tokens.pb`

### 9.3 `diagnostics.pbi`

Diagnostics เป็น counter เบา ๆ เพื่อให้ tests และ callers ตรวจพฤติกรรมได้:

- received messages
- sent messages
- errors
- timeouts
- orphan responses
- batches
- cancellations
- write failures

ตัวอย่างที่ใช้:

- `examples/010-diagnostics/diagnostics_probe.pb`
- `tests/unit/010_diagnostics.pb`

## 10. Stress, trace และ compliance

### 10.1 `stress.pbi`

ไฟล์นี้ให้ helper สำหรับวนซ้ำ parse/dispatch/cleanup เพื่อตรวจว่าระบบไม่ทิ้ง
state ค้าง

ตัวอย่างที่ใช้:

- `examples/011-stress-memory/stress_probe.pb`
- `tests/unit/011_stress_memory.pb`
- `examples/030-stress-lifecycle/stress_lifecycle_probe.pb`
- `tests/unit/030_stress_lifecycle.pb`

จุดสำคัญ:

- stress test ต้อง deterministic
- ไม่ใช่ benchmark performance
- เป้าหมายคือ memory lifecycle และ state cleanup

### 10.2 `trace.pbi` และ trace state ใน `connection.pbi`

Trace ใช้สำหรับ debug แต่ payload ถูกซ่อนไว้ตามค่า default

ตัวอย่างที่ใช้:

- `examples/023-trace-logger-hooks/trace_probe.pb`
- `tests/unit/023_trace_logger_hooks.pb`
- `examples/031-security-robustness/security_probe.pb`
- `tests/unit/031_security_robustness.pb`

เหตุผลด้าน security:

JSON-RPC payload อาจมี token, path, SQL, หรือข้อมูลส่วนตัว ดังนั้น trace
ควร log metadata เช่น byte count โดยไม่เปิด payload เว้นแต่ caller opt-in

### 10.3 `compliance.pbi`

Compliance runner เป็นชุดตรวจ JSON-RPC core behavior ที่เรียกซ้ำได้

ตัวอย่างที่ใช้:

- `examples/024-compliance-suite/compliance_probe.pb`
- `tests/unit/024_compliance_suite.pb`
- `examples/028-compliance-matrix/compliance_matrix_probe.pb`
- `tests/unit/028_compliance_matrix.pb`
- `docs/jsonrpc-compliance-matrix.md`

แนวคิด:

แทนที่จะปล่อยให้ compliance เป็นความรู้ในหัวคนเขียน โครงการทำให้มันเป็น
executable evidence ผ่าน PureUnit และ scenario

## 11. Stdio runtime pump

### 11.1 `stdio_runtime.pbi`

ไฟล์นี้ต่อ `codec.pbi`, `dispatch.pbi`, `batch.pbi`, `outbound.pbi` เข้าด้วยกัน
สำหรับ runtime แบบ stdio

API สำคัญ:

- `JSONRPC_StdioRuntime_Init()`
- `JSONRPC_StdioRuntime_Feed()`
- `JSONRPC_StdioRuntime_ProcessMessage()`

หน้าที่:

- รับ chunk จาก stdin หรือ source ที่ caller ส่งมา
- ใช้ stdio codec แยก message
- ถ้าเป็น response ให้ match pending
- ถ้าเป็น request/notification/batch ให้ dispatch
- ถ้ามี response ให้เขียนผ่าน connection writer

ตัวอย่างที่ใช้:

- `examples/012-stdio-runtime-pump/stdio_runtime_probe.pb`
- `tests/unit/012_stdio_runtime_pump.pb`

จุดสำคัญสำหรับ MCP:

ใน MCP stdio, stdout เป็น protocol-only และ stderr เป็นพื้นที่ของ log
ตัว runtime จึงต้องไม่ปนข้อความ debug ลง stdout

## 12. MCP adapter ชั้นต้น

แม้โครงการต้องรักษา core JSON-RPC ให้ reusable แต่มี adapter MCP เพื่อพิสูจน์
ทิศทางผลิตภัณฑ์

### 12.1 `mcp_lifecycle.pbi`

รองรับ:

- `initialize`
- `notifications/initialized`
- protocol version
- server info
- capability metadata

API สำคัญ:

- `MCP_ServerInfo_Init()`
- `MCP_BuildInitializeResult()`
- `MCP_RegisterLifecycle()`

ตัวอย่างที่ใช้:

- `examples/013-mcp-lifecycle/mcp_lifecycle_probe.pb`
- `tests/unit/013_mcp_lifecycle.pb`

### 12.2 `mcp_tools.pbi`

รองรับ:

- tool registry
- `tools/list`
- `notifications/tools/list_changed`
- `tools/call`
- text result helper

API สำคัญ:

- `MCP_ToolRegistry_Init()`
- `MCP_RegisterTool()`
- `MCP_RegisterToolHandler()`
- `MCP_RegisterToolsList()`
- `MCP_RegisterToolsCall()`
- `MCP_Tools_TextResult()`

ตัวอย่างที่ใช้:

- `examples/014-mcp-tools-registry/mcp_tools_list_probe.pb`
- `examples/015-mcp-tools-call/mcp_tools_call_probe.pb`
- `tests/unit/014_mcp_tools_registry.pb`
- `tests/unit/015_mcp_tools_call.pb`

สิ่งที่ reviewer ควรแยกให้ชัด:

`mcp_tools.pbi` เป็น adapter ที่มี MCP method names ส่วน core JSON-RPC เช่น
`dispatch.pbi` ไม่ควรรู้จักคำว่า `tools/list` โดยตรง

## 13. Packaging, project files และ public API review

### 13.1 รอบ 016 packaging docs

ไฟล์ที่ควรดู:

- `examples/016-packaging-docs/console_template.pb`
- `examples/016-packaging-docs/shared_library_template.pb`
- `examples/016-packaging-docs/app_template.pb`
- `examples/016-packaging-docs/packaging_docs.pbp`
- `tools/build-docs.sh`

รอบนี้พิสูจน์ว่า PureBasic build target ไม่เหมือนกัน:

- console application
- shared library
- GUI executable/application

ในโครงการนี้ `.pbp` คือแหล่งความจริงของ target type

### 13.2 รอบ 025 public API review

ตัวอย่าง:

- `examples/025-public-api-review/api_review_probe.pb`
- `tests/unit/025_public_api_review.pb`
- `docs/api-stability.md`

แนวคิด:

เมื่อ public surface เริ่มเยอะ ต้องแยกให้ชัดว่าอะไรเป็น stable-ish alpha
surface และอะไรยัง experimental โดยเฉพาะ structure fields ภายใน

### 13.3 รอบ 026 alpha release package

ตัวอย่าง:

- `examples/026-alpha-release-package/alpha_package_probe.pb`
- `tests/unit/026_alpha_release_package.pb`
- `tools/package-alpha.sh`

รอบนี้ทำให้ package ไม่ใช่แค่ tarball แต่มี:

- manifest
- checksum
- docs/PDF artifacts
- source tree ที่จัดชุดจาก current tree

## 14. Hardening track: 027 ถึง 032

หลังจากมี feature และตัวอย่าง MCP จำนวนมาก โครงการกลับมา focus ที่คุณภาพของ
JSON-RPC core

### 14.1 `027-release-quality-gates`

เอกสาร:

- `docs/release-quality-gates.md`
- `examples/027-release-quality-gates/release_quality_probe.pb`
- `tests/unit/027_release_quality_gates.pb`

สาระ:

- นิยาม alpha, beta, production candidate
- กำหนดว่า route ไม่จบจน docs/API/milestone/test/harness sync
- ทำให้คุณภาพเป็น gate ไม่ใช่ความรู้สึก

### 14.2 `028-compliance-matrix`

เอกสาร:

- `docs/jsonrpc-compliance-matrix.md`
- `examples/028-compliance-matrix/compliance_matrix_probe.pb`
- `tests/unit/028_compliance_matrix.pb`

สาระ:

- map JSON-RPC spec behavior กับ tests/source
- เพิ่ม compliance cases ที่ขาด
- ทำให้ reviewer เห็น gap ได้ทันที

### 14.3 `029-negative-tests`

ตัวอย่าง:

- `examples/029-negative-tests/negative_probe.pb`
- `tests/unit/029_negative_tests.pb`

สาระ:

- malformed JSON
- invalid id
- invalid batch item
- oversized message
- orphan response
- repeated malformed dispatch

การแก้สำคัญ:

invalid `id` แบบ object/array/boolean ต้องเป็น `-32600 Invalid Request`
พร้อม `id: null` ไม่ใช่ notification

### 14.4 `030-stress-lifecycle`

ตัวอย่าง:

- `examples/030-stress-lifecycle/stress_lifecycle_probe.pb`
- `tests/unit/030_stress_lifecycle.pb`

สาระ:

- stress lifecycle หลายส่วนพร้อมกัน
- queue, timeout, cancellation, trace, pending cleanup
- repeated create/close
- write failure recovery

### 14.5 `031-security-robustness`

เอกสาร:

- `docs/security-robustness.md`
- `tools/verify-paths.sh`
- `examples/031-security-robustness/security_probe.pb`
- `tests/unit/031_security_robustness.pb`

สาระ:

- trace payload opt-in
- malformed recovery
- write failure recovery
- size limits
- path hygiene ใน tracked files
- แยกว่า JSON-RPC core ไม่ใช่ sandbox ของ SQL, filesystem หรือ command

### 14.6 `032-release-automation-polish`

เอกสาร:

- `docs/release-checklist.md`
- `tools/verify-release-artifacts.sh`
- `examples/032-release-automation-polish/release_automation_probe.pb`
- `tests/unit/032_release_automation_polish.pb`

สาระ:

- หลัง `package-alpha.sh` ต้อง verify artifacts
- ตรวจ tarball, manifest, PDF, checksum
- manifest ต้องมี docs/API/examples/tests/tools ล่าสุด
- ลดโอกาสเอกสารหรือ release artifact เก่าเก็บหลุดออกไป

## 15. ตัวอย่าง MCP จริงใน `MCP/examples`

ตัวอย่าง MCP ไม่ได้อยู่ในลำดับเลขของ core examples เพราะเป็น application
dogfooding มากกว่ารอบของ JSON-RPC core

### 15.1 `MCP/examples/purebasic-check`

ไฟล์สำคัญ:

- `MCP/examples/purebasic-check/purebasic_check_server.pb`
- `MCP/examples/purebasic-check/purebasic_check_tool.pbi`
- `MCP/examples/purebasic-check/purebasic_check.pbp`
- `MCP/examples/purebasic-check/README.md`

หน้าที่:

- เป็น MCP stdio server แบบ console application
- register lifecycle
- register tool `purebasic/check`
- เมื่อถูกเรียก จะรัน workflow ตรวจโครงการ
- stdout ใช้ protocol เท่านั้น

สิ่งที่ reviewer ควรดู:

- server ใช้ `JSONRPC_Codec_StdioBuildMessage()` ตอนตอบกลับ
- input อ่านทีละ line ตาม stdio MCP convention
- diagnostics/log ไม่ควรปน stdout
- output จาก command ถูก bound ไม่ให้ตอบยาวเกินควบคุม

### 15.2 `MCP/examples/sqlite-admin`

ไฟล์สำคัญ:

- `MCP/examples/sqlite-admin/sqlite_admin_server.pb`
- `MCP/examples/sqlite-admin/sqlite_admin_tool.pbi`
- `MCP/examples/sqlite-admin/sqlite_admin_bootstrap.pb`
- `MCP/examples/sqlite-admin/sqlite_admin_probe.pb`
- `MCP/examples/sqlite-admin/sqlite_admin.pbp`
- `MCP/examples/sqlite-admin/README.md`
- `MCP/examples/sqlite-admin/TUTORIAL.md`

หน้าที่:

- เป็น MCP server สำหรับจัดการ SQLite file ในขอบเขต local macOS
- มี tools เช่น bootstrap, inspect, query, execute, backup, maintenance,
  recipe list/save/run/delete และ export
- รองรับ UTF-8 multilingual data แบบ exact round-trip
- มี CSV, ODS, XLSX export ใน example layer

สิ่งที่ reviewer ควรระวัง:

- `sqlite/execute` เป็น admin/developer tool ไม่ใช่ sandbox
- path ต้องอยู่ใน allowed root
- output ต้อง bounded
- no delete-file operation ใน v1
- Unicode exact match ทำได้ แต่ SQLite built-in `NOCASE`, `LIKE`,
  `upper()`, `lower()` ไม่ใช่ full Unicode case-folding โดยไม่มี ICU/custom
  collation

## 16. Walkthrough ทุกตัวอย่างแบบรวดเร็ว

ตารางนี้เป็นทางลัดสำหรับเดินตัวอย่างทั้งหมดโดยไม่เสียเวลาเปิดทุกไฟล์ก่อน

| ตัวอย่าง | ไฟล์หลัก | แนวคิดที่พิสูจน์ | ซอร์สที่เกี่ยวข้อง |
| --- | --- | --- | --- |
| `000-project-foundation` | `console_probe.pb` | toolchain และ console probe | `tools/*`, `version.pbi` |
| `001-framing` | `framing_probe.pb` | Content-Length framing | `framing.pbi`, `byte_buffer.pbi` |
| `002-transport-codecs` | `stdio_codec_probe.pb` | newline-delimited stdio codec | `codec.pbi` |
| `003-connection-lifecycle` | `connection_probe.pb` | init/send/close lifecycle | `connection.pbi`, `io.pbi` |
| `004-protocol-errors` | `spec_examples_probe.pb` | JSON-RPC validation/error | `protocol.pbi` |
| `005-dispatch` | `dispatch_probe.pb` | request/notification handler | `dispatch.pbi` |
| `006-outbound-requests` | `outbound_probe.pb` | outbound request/pending | `outbound.pbi` |
| `007-timeout-housekeeping` | `timeout_probe.pb` | pending timeout cleanup | `outbound.pbi` |
| `008-batch-handling` | `batch_probe.pb` | sequential batch dispatch | `batch.pbi` |
| `009-cancellation` | `cancel_probe.pb` | `$/cancelRequest` token | `cancel.pbi` |
| `010-diagnostics` | `diagnostics_probe.pb` | counters | `diagnostics.pbi` |
| `011-stress-memory` | `stress_probe.pb` | repeated cleanup | `stress.pbi` |
| `012-stdio-runtime-pump` | `stdio_runtime_probe.pb` | codec + dispatch runtime | `stdio_runtime.pbi` |
| `013-mcp-lifecycle` | `mcp_lifecycle_probe.pb` | initialize lifecycle | `mcp_lifecycle.pbi` |
| `014-mcp-tools-registry` | `mcp_tools_list_probe.pb` | tools/list registry | `mcp_tools.pbi` |
| `015-mcp-tools-call` | `mcp_tools_call_probe.pb` | tools/call dispatch | `mcp_tools.pbi` |
| `016-packaging-docs` | `package_probe.pb` | packaging/docs/templates | `jsonrpc.pbi`, `tools/build-docs.sh` |
| `017-reader-writer-interfaces` | `io_probe.pb` | generic reader/writer | `io.pbi` |
| `018-byte-buffer-framing` | `byte_buffer_probe.pb` | UTF-8 byte buffer | `byte_buffer.pbi`, `framing.pbi` |
| `019-connection-events` | `events_probe.pb` | connection events | `connection.pbi` |
| `020-handler-registration-lifecycle` | `handler_lifecycle_probe.pb` | unregister/star handlers | `dispatch.pbi` |
| `021-handler-cancellation-tokens` | `cancellation_token_probe.pb` | handler-visible cancel | `cancel.pbi`, `dispatch.pbi` |
| `022-write-queue-close-semantics` | `write_queue_probe.pb` | queued writes | `connection.pbi`, `diagnostics.pbi` |
| `023-trace-logger-hooks` | `trace_probe.pb` | trace/log hooks | `trace.pbi`, `connection.pbi` |
| `024-compliance-suite` | `compliance_probe.pb` | executable compliance | `compliance.pbi` |
| `025-public-api-review` | `api_review_probe.pb` | alpha API metadata | `version.pbi`, `jsonrpc.pbi` |
| `026-alpha-release-package` | `alpha_package_probe.pb` | alpha package readiness | `tools/package-alpha.sh` |
| `027-release-quality-gates` | `release_quality_probe.pb` | release gates | `docs/release-quality-gates.md` |
| `028-compliance-matrix` | `compliance_matrix_probe.pb` | spec-to-test matrix | `compliance.pbi` |
| `029-negative-tests` | `negative_probe.pb` | malformed/invalid cases | `protocol.pbi`, `codec.pbi` |
| `030-stress-lifecycle` | `stress_lifecycle_probe.pb` | lifecycle stress | `stress.pbi`, `connection.pbi` |
| `031-security-robustness` | `security_probe.pb` | robustness boundaries | `tools/verify-paths.sh`, `connection.pbi` |
| `032-release-automation-polish` | `release_automation_probe.pb` | artifact verification | `tools/verify-release-artifacts.sh` |

## 17. วิธีประกอบจิ๊กซอว์ตอนรีวิวโค้ด

ถ้าต้องรีวิว behavior ใหม่ ให้ถามเป็นลำดับ:

1. ข้อมูลเข้ามาจาก transport แบบไหน
2. byte length ถูกนับถูกต้องหรือไม่
3. message boundary ถูกต้องหรือไม่
4. JSON parse แล้วถูก free หรือไม่
5. JSON-RPC shape ถูกตรวจที่ `protocol.pbi` หรือไม่
6. request/notification/response แยกถูกหรือไม่
7. notification เงียบจริงหรือไม่
8. request ที่ผิดพลาดคืน error code ถูกหรือไม่
9. handler ได้ params และ context อย่างไร
10. response ถูกส่งผ่าน connection writer หรือไม่
11. diagnostics/event/trace ถูกนับหรือ log ถูกที่หรือไม่
12. cleanup state หลังจบหรือ close ครบหรือไม่
13. docs/API/tests/examples update ตาม route หรือไม่
14. `.pbp` target metadata ถูกต้องหรือไม่
15. `./tools/check.sh` ผ่านจริงหรือไม่

ภาพ mental model:

```text
input bytes
  -> byte buffer
  -> transport reader
       Content-Length หรือ stdio newline
  -> message body
  -> protocol inspect
  -> response matching หรือ dispatch
  -> handler result
  -> JSON-RPC response
  -> connection writer
  -> stdout / test fake writer / caller-provided writer
```

## 18. จุดที่ควรตรวจลึกเป็นพิเศษ

### 18.1 UTF-8 และ byte length

ตรวจ:

- `byte_buffer.pbi`
- `framing.pbi`
- tests ของ Unicode และ oversized message

เหตุผล:

ภาษาไทยและภาษาอื่น ๆ ไม่ใช่หนึ่ง character เท่ากับหนึ่ง byte เสมอไป

### 18.2 JSON ownership

ตรวจ:

- `protocol.pbi`
- `dispatch.pbi`
- `batch.pbi`
- `mcp_tools.pbi`
- MCP example tools

เหตุผล:

PureBasic JSON handle ต้องถูก free เมื่อไม่ใช้แล้ว

### 18.3 Notification semantics

ตรวจ:

- `protocol.pbi`
- `dispatch.pbi`
- `batch.pbi`
- tests `004`, `005`, `008`

เหตุผล:

JSON-RPC notification ต้องไม่มี response แม้ handler ทำงานแล้ว

### 18.4 Error id preservation

ตรวจ:

- `JSONRPC_Protocol_IdText()`
- invalid id tests
- parse error tests

เหตุผล:

บาง error ต้อง preserve id ถ้า detect ได้ บางกรณีต้องใช้ `null`

### 18.5 Trace payloads

ตรวจ:

- `connection.pbi`
- `trace.pbi`
- `031_security_robustness.pb`

เหตุผล:

payload อาจมีข้อมูลลับ ต้อง opt-in ก่อน log payload

### 18.6 Release artifact freshness

ตรวจ:

- `tools/package-alpha.sh`
- `tools/verify-release-artifacts.sh`
- `docs/release-checklist.md`

เหตุผล:

โครงการเคยเจอปัญหาเอกสาร/เส้นทางไม่ sync ดังนั้น release ต้อง verify ไม่ใช่
แค่ generate

## 19. Harness ที่ต้องเชื่อ ไม่ใช่เดา

คำสั่งหลัก:

```sh
./tools/discover-purebasic.sh
./tools/verify-projects.sh
./tools/verify-docs.sh
./tools/verify-paths.sh
./tools/test.sh
./tools/build.sh
./tools/build-docs.sh
./tools/package-alpha.sh
./tools/verify-release-artifacts.sh
./tools/check.sh
```

สิ่งที่แต่ละคำสั่งยืนยัน:

- `discover-purebasic.sh` เตรียม `.local/` และยืนยัน PureBasic 6.40/PureUnit
- `verify-projects.sh` ตรวจ `.pbp` metadata และ target type
- `verify-docs.sh` ตรวจ route docs/API/examples/milestones/indexes
- `verify-paths.sh` กัน absolute path เฉพาะเครื่องใน tracked files
- `test.sh` รัน PureUnit ทุกไฟล์ใน `tests/unit/`
- `build.sh` build target ผ่าน `.pbp`
- `build-docs.sh` สร้าง Sphinx HTML และ PDF สองไฟล์
- `package-alpha.sh` สร้าง package, manifest, checksum และ PDF artifacts
- `verify-release-artifacts.sh` ตรวจ package artifacts หลังสร้าง
- `check.sh` รวมทุกอย่างเป็น final gate

สิ่งที่ควรจำ:

ห้ามสรุปว่า "น่าจะผ่าน" ถ้ายังไม่ได้รัน harness ที่เกี่ยวข้อง

## 20. การอ่าน tests ให้เร็ว

ชื่อ test file ตามเลข milestone:

```text
tests/unit/001_framing.pb
tests/unit/002_transport_codecs.pb
...
tests/unit/032_release_automation_polish.pb
```

วิธีอ่าน:

1. เปิด example ของเลขนั้นก่อน
2. เปิด test file เลขเดียวกัน
3. เปิด API page เลขเดียวกัน
4. ค่อยเปิด source `.pbi` ที่ example include

ตัวอย่าง:

ถ้าจะเข้าใจ batch:

```text
examples/008-batch-handling/batch_probe.pb
tests/unit/008_batch_handling.pb
API/008-batch-handling.md
src/jsonrpc/batch.pbi
src/jsonrpc/dispatch.pbi
```

ถ้าจะเข้าใจ release automation:

```text
examples/032-release-automation-polish/release_automation_probe.pb
tests/unit/032_release_automation_polish.pb
API/032-release-automation-polish.md
tools/package-alpha.sh
tools/verify-release-artifacts.sh
docs/release-checklist.md
```

## 21. สรุปเส้นทางตั้งแต่ต้นจนเป็น alpha foundation

โครงการนี้เดินจากชั้นล่างขึ้นชั้นบนอย่างตั้งใจ:

```text
000 toolchain foundation
001-002 message transport
003 connection lifecycle
004 protocol validation
005 dispatch
006-007 outbound and timeout
008 batch
009 cancellation
010 diagnostics
011 stress
012 stdio runtime
013-015 MCP adapter preview
016 packaging/docs/templates
017-023 runtime hardening
024 compliance suite
025 public API review
026 alpha package
027-032 release hardening
MCP examples as dogfooding
```

จุดสำคัญคือแต่ละรอบไม่ได้อยู่โดด ๆ:

- `001` และ `002` ทำให้มี message body ที่ถูกต้อง
- `003` ทำให้มีที่เก็บ state และ writer
- `004` ทำให้รู้ว่า body เป็น JSON-RPC อะไร
- `005` ทำให้เรียก handler ได้
- `006` ถึง `012` ทำให้ runtime ใช้งานจริงมากขึ้น
- `013` ถึง `015` วางสะพานไป MCP
- `016` ถึง `032` ทำให้ build, docs, tests, package และ quality gate เชื่อถือได้

## 22. คำแนะนำสำหรับ external reviewer

เมื่อรีวิวโครงการนี้ ให้หลีกเลี่ยงการดูเฉพาะตัวอย่าง MCP แล้วสรุปทั้งไลบรารี
เพราะ MCP example เป็น application layer ส่วนแกนจริงอยู่ใน `src/jsonrpc/`

ให้ใช้ checklist นี้:

- Core JSON-RPC ถูกต้องตาม specification หรือไม่
- Transport แยก `Content-Length` กับ stdio ชัดหรือไม่
- UTF-8 byte length ถูกต้องหรือไม่
- Request/notification/response semantics ถูกต้องหรือไม่
- Batch edge cases มี test หรือไม่
- Error code และ id preservation ถูกต้องหรือไม่
- JSON handles ถูก free หรือไม่
- Connection close/cleanup ปลอดภัยหรือไม่
- Cancellation เป็น cooperative จริงหรือไม่
- Trace payload ไม่รั่วโดย default หรือไม่
- MCP adapter ไม่ทำให้ core ผูกกับ MCP เกินจำเป็นหรือไม่
- `.pbp` target type ถูกต้องหรือไม่
- เอกสาร milestone/API/example/test sync หรือไม่
- ไม่มี absolute path เฉพาะเครื่องใน tracked files หรือไม่
- Release artifacts ถูก verify หลัง package หรือไม่

## 23. อ่านต่อที่ไหน

เอกสารประกอบที่ควรอ่านคู่กัน:

- `docs/project-request.md` - คำขอโครงการที่ถูกจัดรูป
- `docs/guideline.md` - guideline ต้นทาง
- `docs/harness.md` - harness และคำสั่งตรวจ
- `docs/milestones.md` - ประวัติรอบ implementation
- `docs/release-hardening-plan.md` - เหตุผลของรอบ 027-032
- `docs/release-quality-gates.md` - เกณฑ์ alpha/beta/production candidate
- `docs/jsonrpc-compliance-matrix.md` - mapping spec กับ test/source
- `docs/security-robustness.md` - ขอบเขตด้าน security และ robustness
- `docs/release-checklist.md` - ขั้นตอน release
- `docs/mcp-for-purebasic.md` - ภาพรวม MCP/PureBasic
- `docs/tutorial-building-with-purebasic-jsonrpc.md` - tutorial เชิงปฏิบัติ
- `MCP/examples/sqlite-admin/TUTORIAL.md` - guide ของ SQLite MCP example

## 24. บทส่งท้าย

ถ้ามองแบบเร็ว โครงการนี้คือไลบรารี JSON-RPC สำหรับ PureBasic

ถ้ามองแบบ code-level โครงการนี้คือชุดของ decision ที่ค่อย ๆ ปิดความเสี่ยง:

- เริ่มจาก toolchain
- คุม byte/transport ให้ถูก
- ตรวจ protocol ก่อนทำงาน
- dispatch อย่างแยก request/notification ชัดเจน
- track state อย่างทดสอบได้
- เพิ่ม MCP เฉพาะที่เป็น adapter
- ใช้ examples และ PureUnit เป็นหลักฐาน
- ใช้ harness กันเอกสารหลุด, path หลุด, package stale และ release artifact เก่า

นี่คือวิธีที่ชิ้นส่วนทั้งหมดต่อกันเป็น foundation สำหรับอนาคต: วันนี้เป็น
JSON-RPC alpha library ที่ทดสอบได้ และวันต่อไปสามารถต่อ MCP server จริงเพิ่ม
ได้โดยไม่ต้องรื้อแกนกลางใหม่
