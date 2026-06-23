EnableExplicit

XIncludeFile "framing.pbi"

#JSONRPC_Codec_StdioDefaultMaxMessageBytes = 1048576

Enumeration
  #JSONRPC_Codec_ErrorNone = 0
  #JSONRPC_Codec_ErrorEmbeddedNewline
  #JSONRPC_Codec_ErrorMessageTooLarge
EndEnumeration

Structure JSONRPC_StdioCodecState
  buffer.s
  maxMessageBytes.i
  errorCode.i
  errorMessage.s
EndStructure

Declare JSONRPC_Codec_StdioInit(*state.JSONRPC_StdioCodecState, maxMessageBytes.i = #JSONRPC_Codec_StdioDefaultMaxMessageBytes)
Declare JSONRPC_Codec_StdioReset(*state.JSONRPC_StdioCodecState)
Declare JSONRPC_Codec_StdioPushBytes(*state.JSONRPC_StdioCodecState, chunk.s)
Declare.i JSONRPC_Codec_StdioNextMessage(*state.JSONRPC_StdioCodecState, *message.JSONRPC_Message)
Declare.i JSONRPC_Codec_StdioHasError(*state.JSONRPC_StdioCodecState)
Declare.i JSONRPC_Codec_StdioGetErrorCode(*state.JSONRPC_StdioCodecState)
Declare.s JSONRPC_Codec_StdioGetErrorMessage(*state.JSONRPC_StdioCodecState)
Declare.s JSONRPC_Codec_StdioBuildMessage(body.s)

Procedure JSONRPC_Codec_StdioSetError(*state.JSONRPC_StdioCodecState, code.i, message.s)
  If *state\errorCode = #JSONRPC_Codec_ErrorNone
    *state\errorCode = code
    *state\errorMessage = message
  EndIf
EndProcedure

Procedure.i JSONRPC_Codec_ContainsLineBreak(text.s)
  ProcedureReturn Bool(FindString(text, #LF$, 1) > 0 Or FindString(text, #CR$, 1) > 0)
EndProcedure

Procedure JSONRPC_Codec_StdioInit(*state.JSONRPC_StdioCodecState, maxMessageBytes.i = #JSONRPC_Codec_StdioDefaultMaxMessageBytes)
  *state\buffer = ""
  *state\maxMessageBytes = maxMessageBytes
  *state\errorCode = #JSONRPC_Codec_ErrorNone
  *state\errorMessage = ""
EndProcedure

Procedure JSONRPC_Codec_StdioReset(*state.JSONRPC_StdioCodecState)
  JSONRPC_Codec_StdioInit(*state, *state\maxMessageBytes)
EndProcedure

Procedure JSONRPC_Codec_StdioPushBytes(*state.JSONRPC_StdioCodecState, chunk.s)
  If *state\errorCode = #JSONRPC_Codec_ErrorNone
    *state\buffer + chunk

    If JSONRPC_Framing_Utf8ByteLength(*state\buffer) > *state\maxMessageBytes And FindString(*state\buffer, #LF$, 1) = 0
      JSONRPC_Codec_StdioSetError(*state, #JSONRPC_Codec_ErrorMessageTooLarge, "Stdio message exceeds configured maximum.")
    EndIf
  EndIf
EndProcedure

Procedure.i JSONRPC_Codec_StdioNextMessage(*state.JSONRPC_StdioCodecState, *message.JSONRPC_Message)
  Protected newlineIndex.i
  Protected line.s

  *message\body = ""
  *message\byteLength = 0

  If *state\errorCode <> #JSONRPC_Codec_ErrorNone
    ProcedureReturn #False
  EndIf

  newlineIndex = FindString(*state\buffer, #LF$, 1)
  If newlineIndex = 0
    ProcedureReturn #False
  EndIf

  line = Left(*state\buffer, newlineIndex - 1)
  *state\buffer = Mid(*state\buffer, newlineIndex + 1)

  If Right(line, 1) = #CR$
    line = Left(line, Len(line) - 1)
  EndIf

  If FindString(line, #CR$, 1) > 0
    JSONRPC_Codec_StdioSetError(*state, #JSONRPC_Codec_ErrorEmbeddedNewline, "Stdio message contains an embedded carriage return.")
    ProcedureReturn #False
  EndIf

  If JSONRPC_Framing_Utf8ByteLength(line) > *state\maxMessageBytes
    JSONRPC_Codec_StdioSetError(*state, #JSONRPC_Codec_ErrorMessageTooLarge, "Stdio message exceeds configured maximum.")
    ProcedureReturn #False
  EndIf

  *message\body = line
  *message\byteLength = JSONRPC_Framing_Utf8ByteLength(line)

  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_Codec_StdioHasError(*state.JSONRPC_StdioCodecState)
  ProcedureReturn Bool(*state\errorCode <> #JSONRPC_Codec_ErrorNone)
EndProcedure

Procedure.i JSONRPC_Codec_StdioGetErrorCode(*state.JSONRPC_StdioCodecState)
  ProcedureReturn *state\errorCode
EndProcedure

Procedure.s JSONRPC_Codec_StdioGetErrorMessage(*state.JSONRPC_StdioCodecState)
  ProcedureReturn *state\errorMessage
EndProcedure

Procedure.s JSONRPC_Codec_StdioBuildMessage(body.s)
  If JSONRPC_Codec_ContainsLineBreak(body)
    ProcedureReturn ""
  EndIf

  ProcedureReturn body + #LF$
EndProcedure

