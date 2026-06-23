EnableExplicit

Structure JSONRPC_ByteBuffer
  text.s
  byteLength.i
  maxBytes.i
  overflow.i
EndStructure

Declare JSONRPC_ByteBuffer_Init(*buffer.JSONRPC_ByteBuffer, maxBytes.i = 0)
Declare JSONRPC_ByteBuffer_Clear(*buffer.JSONRPC_ByteBuffer)
Declare JSONRPC_ByteBuffer_SetText(*buffer.JSONRPC_ByteBuffer, text.s)
Declare.i JSONRPC_ByteBuffer_AppendUtf8(*buffer.JSONRPC_ByteBuffer, chunk.s)
Declare.s JSONRPC_ByteBuffer_AsText(*buffer.JSONRPC_ByteBuffer)
Declare.i JSONRPC_ByteBuffer_Length(*buffer.JSONRPC_ByteBuffer)
Declare.i JSONRPC_ByteBuffer_HasOverflow(*buffer.JSONRPC_ByteBuffer)

Procedure JSONRPC_ByteBuffer_UpdateLength(*buffer.JSONRPC_ByteBuffer)
  *buffer\byteLength = StringByteLength(*buffer\text, #PB_UTF8)
EndProcedure

Procedure JSONRPC_ByteBuffer_Init(*buffer.JSONRPC_ByteBuffer, maxBytes.i = 0)
  *buffer\text = ""
  *buffer\byteLength = 0
  *buffer\maxBytes = maxBytes
  *buffer\overflow = #False
EndProcedure

Procedure JSONRPC_ByteBuffer_Clear(*buffer.JSONRPC_ByteBuffer)
  JSONRPC_ByteBuffer_Init(*buffer, *buffer\maxBytes)
EndProcedure

Procedure JSONRPC_ByteBuffer_SetText(*buffer.JSONRPC_ByteBuffer, text.s)
  *buffer\text = text
  JSONRPC_ByteBuffer_UpdateLength(*buffer)
  *buffer\overflow = Bool(*buffer\maxBytes > 0 And *buffer\byteLength > *buffer\maxBytes)
EndProcedure

Procedure.i JSONRPC_ByteBuffer_AppendUtf8(*buffer.JSONRPC_ByteBuffer, chunk.s)
  Protected chunkBytes.i

  chunkBytes = StringByteLength(chunk, #PB_UTF8)
  If *buffer\maxBytes > 0 And *buffer\byteLength + chunkBytes > *buffer\maxBytes
    *buffer\overflow = #True
    ProcedureReturn #False
  EndIf

  *buffer\text + chunk
  *buffer\byteLength + chunkBytes
  ProcedureReturn #True
EndProcedure

Procedure.s JSONRPC_ByteBuffer_AsText(*buffer.JSONRPC_ByteBuffer)
  ProcedureReturn *buffer\text
EndProcedure

Procedure.i JSONRPC_ByteBuffer_Length(*buffer.JSONRPC_ByteBuffer)
  ProcedureReturn *buffer\byteLength
EndProcedure

Procedure.i JSONRPC_ByteBuffer_HasOverflow(*buffer.JSONRPC_ByteBuffer)
  ProcedureReturn *buffer\overflow
EndProcedure
