EnableExplicit

Enumeration
  #JSONRPC_IO_ErrorNone = 0
  #JSONRPC_IO_ErrorClosed
  #JSONRPC_IO_ErrorWriteFailed
EndEnumeration

Structure JSONRPC_Writer
  captured.s
  writeCount.i
  closed.i
  failNextWrite.i
  lastErrorCode.i
  lastErrorMessage.s
EndStructure

Structure JSONRPC_FakeWriter Extends JSONRPC_Writer
EndStructure

Structure JSONRPC_Reader
  buffer.s
  readCount.i
  closed.i
  lastErrorCode.i
  lastErrorMessage.s
EndStructure

Declare JSONRPC_Writer_Init(*writer.JSONRPC_Writer)
Declare.i JSONRPC_Writer_Write(*writer.JSONRPC_Writer, body.s)
Declare JSONRPC_Writer_Close(*writer.JSONRPC_Writer)
Declare.i JSONRPC_Writer_IsClosed(*writer.JSONRPC_Writer)
Declare.s JSONRPC_Writer_GetCaptured(*writer.JSONRPC_Writer)
Declare.i JSONRPC_Writer_GetWriteCount(*writer.JSONRPC_Writer)
Declare JSONRPC_Writer_FailNextWrite(*writer.JSONRPC_Writer)
Declare.i JSONRPC_Writer_GetLastErrorCode(*writer.JSONRPC_Writer)
Declare.s JSONRPC_Writer_GetLastErrorMessage(*writer.JSONRPC_Writer)

Declare JSONRPC_FakeWriter_Init(*writer.JSONRPC_FakeWriter)
Declare JSONRPC_FakeWriter_Close(*writer.JSONRPC_FakeWriter)

Declare JSONRPC_Reader_Init(*reader.JSONRPC_Reader)
Declare JSONRPC_Reader_PushBytes(*reader.JSONRPC_Reader, chunk.s)
Declare.s JSONRPC_Reader_ReadAvailable(*reader.JSONRPC_Reader)
Declare JSONRPC_Reader_Close(*reader.JSONRPC_Reader)
Declare.i JSONRPC_Reader_IsClosed(*reader.JSONRPC_Reader)

Procedure JSONRPC_Writer_SetError(*writer.JSONRPC_Writer, code.i, message.s)
  If *writer = 0
    ProcedureReturn
  EndIf

  *writer\lastErrorCode = code
  *writer\lastErrorMessage = message
EndProcedure

Procedure JSONRPC_Writer_Init(*writer.JSONRPC_Writer)
  *writer\captured = ""
  *writer\writeCount = 0
  *writer\closed = #False
  *writer\failNextWrite = #False
  JSONRPC_Writer_SetError(*writer, #JSONRPC_IO_ErrorNone, "")
EndProcedure

Procedure.i JSONRPC_Writer_Write(*writer.JSONRPC_Writer, body.s)
  If *writer = 0
    ProcedureReturn #False
  EndIf

  If *writer\closed
    JSONRPC_Writer_SetError(*writer, #JSONRPC_IO_ErrorClosed, "Writer is closed.")
    ProcedureReturn #False
  EndIf

  If *writer\failNextWrite
    *writer\failNextWrite = #False
    JSONRPC_Writer_SetError(*writer, #JSONRPC_IO_ErrorWriteFailed, "Writer rejected the message.")
    ProcedureReturn #False
  EndIf

  *writer\captured + body
  *writer\writeCount + 1
  JSONRPC_Writer_SetError(*writer, #JSONRPC_IO_ErrorNone, "")
  ProcedureReturn #True
EndProcedure

Procedure JSONRPC_Writer_Close(*writer.JSONRPC_Writer)
  If *writer <> 0
    *writer\closed = #True
  EndIf
EndProcedure

Procedure.i JSONRPC_Writer_IsClosed(*writer.JSONRPC_Writer)
  If *writer = 0
    ProcedureReturn #True
  EndIf

  ProcedureReturn *writer\closed
EndProcedure

Procedure.s JSONRPC_Writer_GetCaptured(*writer.JSONRPC_Writer)
  If *writer = 0
    ProcedureReturn ""
  EndIf

  ProcedureReturn *writer\captured
EndProcedure

Procedure.i JSONRPC_Writer_GetWriteCount(*writer.JSONRPC_Writer)
  If *writer = 0
    ProcedureReturn 0
  EndIf

  ProcedureReturn *writer\writeCount
EndProcedure

Procedure JSONRPC_Writer_FailNextWrite(*writer.JSONRPC_Writer)
  If *writer <> 0
    *writer\failNextWrite = #True
  EndIf
EndProcedure

Procedure.i JSONRPC_Writer_GetLastErrorCode(*writer.JSONRPC_Writer)
  If *writer = 0
    ProcedureReturn #JSONRPC_IO_ErrorWriteFailed
  EndIf

  ProcedureReturn *writer\lastErrorCode
EndProcedure

Procedure.s JSONRPC_Writer_GetLastErrorMessage(*writer.JSONRPC_Writer)
  If *writer = 0
    ProcedureReturn "Writer is not configured."
  EndIf

  ProcedureReturn *writer\lastErrorMessage
EndProcedure

Procedure JSONRPC_FakeWriter_Init(*writer.JSONRPC_FakeWriter)
  JSONRPC_Writer_Init(*writer)
EndProcedure

Procedure JSONRPC_FakeWriter_Close(*writer.JSONRPC_FakeWriter)
  JSONRPC_Writer_Close(*writer)
EndProcedure

Procedure JSONRPC_Reader_SetError(*reader.JSONRPC_Reader, code.i, message.s)
  If *reader = 0
    ProcedureReturn
  EndIf

  *reader\lastErrorCode = code
  *reader\lastErrorMessage = message
EndProcedure

Procedure JSONRPC_Reader_Init(*reader.JSONRPC_Reader)
  *reader\buffer = ""
  *reader\readCount = 0
  *reader\closed = #False
  JSONRPC_Reader_SetError(*reader, #JSONRPC_IO_ErrorNone, "")
EndProcedure

Procedure JSONRPC_Reader_PushBytes(*reader.JSONRPC_Reader, chunk.s)
  If *reader = 0 Or *reader\closed
    ProcedureReturn
  EndIf

  *reader\buffer + chunk
EndProcedure

Procedure.s JSONRPC_Reader_ReadAvailable(*reader.JSONRPC_Reader)
  Protected output.s

  If *reader = 0 Or *reader\closed
    ProcedureReturn ""
  EndIf

  output = *reader\buffer
  *reader\buffer = ""

  If output <> ""
    *reader\readCount + 1
  EndIf

  ProcedureReturn output
EndProcedure

Procedure JSONRPC_Reader_Close(*reader.JSONRPC_Reader)
  If *reader <> 0
    *reader\closed = #True
  EndIf
EndProcedure

Procedure.i JSONRPC_Reader_IsClosed(*reader.JSONRPC_Reader)
  If *reader = 0
    ProcedureReturn #True
  EndIf

  ProcedureReturn *reader\closed
EndProcedure
