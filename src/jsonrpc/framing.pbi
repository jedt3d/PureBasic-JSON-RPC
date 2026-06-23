EnableExplicit

#JSONRPC_Framing_DefaultMaxHeaderBytes = 8192
#JSONRPC_Framing_DefaultMaxBodyBytes = 1048576

Enumeration
  #JSONRPC_Framing_ErrorNone = 0
  #JSONRPC_Framing_ErrorHeaderTooLarge
  #JSONRPC_Framing_ErrorMissingContentLength
  #JSONRPC_Framing_ErrorDuplicateContentLength
  #JSONRPC_Framing_ErrorInvalidContentLength
  #JSONRPC_Framing_ErrorBodyTooLarge
  #JSONRPC_Framing_ErrorBodyLengthSplitsUtf8Character
EndEnumeration

Structure JSONRPC_FrameState
  buffer.s
  maxHeaderBytes.i
  maxBodyBytes.i
  errorCode.i
  errorMessage.s
EndStructure

Structure JSONRPC_Message
  body.s
  byteLength.i
EndStructure

Declare JSONRPC_Framing_Init(*state.JSONRPC_FrameState, maxHeaderBytes.i = #JSONRPC_Framing_DefaultMaxHeaderBytes, maxBodyBytes.i = #JSONRPC_Framing_DefaultMaxBodyBytes)
Declare JSONRPC_Framing_Reset(*state.JSONRPC_FrameState)
Declare JSONRPC_Framing_PushBytes(*state.JSONRPC_FrameState, chunk.s)
Declare.i JSONRPC_Framing_NextMessage(*state.JSONRPC_FrameState, *message.JSONRPC_Message)
Declare.i JSONRPC_Framing_HasError(*state.JSONRPC_FrameState)
Declare.i JSONRPC_Framing_GetErrorCode(*state.JSONRPC_FrameState)
Declare.s JSONRPC_Framing_GetErrorMessage(*state.JSONRPC_FrameState)
Declare.i JSONRPC_Framing_Utf8ByteLength(text.s)
Declare.s JSONRPC_Framing_BuildFrame(body.s)

#JSONRPC_Framing_HeaderTerminator$ = #CRLF$ + #CRLF$
#JSONRPC_Framing_ContentLengthHeader$ = "content-length"

Procedure JSONRPC_Framing_SetError(*state.JSONRPC_FrameState, code.i, message.s)
  If *state\errorCode = #JSONRPC_Framing_ErrorNone
    *state\errorCode = code
    *state\errorMessage = message
  EndIf
EndProcedure

Procedure.i JSONRPC_Framing_IsUnsignedDecimal(text.s)
  Protected index.i
  Protected charCode.i

  If text = ""
    ProcedureReturn #False
  EndIf

  For index = 1 To Len(text)
    charCode = Asc(Mid(text, index, 1))
    If charCode < '0' Or charCode > '9'
      ProcedureReturn #False
    EndIf
  Next

  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_Framing_ContentLengthFromHeader(*state.JSONRPC_FrameState, header.s)
  Protected fieldCount.i
  Protected fieldIndex.i
  Protected line.s
  Protected colonIndex.i
  Protected name.s
  Protected value.s
  Protected length.i = -1

  fieldCount = CountString(header, #CRLF$) + 1

  For fieldIndex = 1 To fieldCount
    line = StringField(header, fieldIndex, #CRLF$)

    If Trim(line) <> ""
      colonIndex = FindString(line, ":", 1)
      If colonIndex > 0
        name = LCase(Trim(Left(line, colonIndex - 1)))
        value = Trim(Mid(line, colonIndex + 1))

        If name = #JSONRPC_Framing_ContentLengthHeader$
          If length >= 0
            JSONRPC_Framing_SetError(*state, #JSONRPC_Framing_ErrorDuplicateContentLength, "Duplicate Content-Length header.")
            ProcedureReturn -1
          EndIf

          If JSONRPC_Framing_IsUnsignedDecimal(value) = #False
            JSONRPC_Framing_SetError(*state, #JSONRPC_Framing_ErrorInvalidContentLength, "Invalid Content-Length header.")
            ProcedureReturn -1
          EndIf

          length = Val(value)
        EndIf
      EndIf
    EndIf
  Next

  If length < 0
    JSONRPC_Framing_SetError(*state, #JSONRPC_Framing_ErrorMissingContentLength, "Missing Content-Length header.")
    ProcedureReturn -1
  EndIf

  If length > *state\maxBodyBytes
    JSONRPC_Framing_SetError(*state, #JSONRPC_Framing_ErrorBodyTooLarge, "Message body exceeds configured maximum.")
    ProcedureReturn -1
  EndIf

  ProcedureReturn length
EndProcedure

Procedure.i JSONRPC_Framing_Utf8CharCountForByteLength(text.s, targetBytes.i)
  Protected index.i
  Protected totalBytes.i

  If targetBytes = 0
    ProcedureReturn 0
  EndIf

  For index = 1 To Len(text)
    totalBytes + StringByteLength(Mid(text, index, 1), #PB_UTF8)

    If totalBytes = targetBytes
      ProcedureReturn index
    EndIf

    If totalBytes > targetBytes
      ProcedureReturn -1
    EndIf
  Next

  ProcedureReturn -2
EndProcedure

Procedure JSONRPC_Framing_Init(*state.JSONRPC_FrameState, maxHeaderBytes.i = #JSONRPC_Framing_DefaultMaxHeaderBytes, maxBodyBytes.i = #JSONRPC_Framing_DefaultMaxBodyBytes)
  *state\buffer = ""
  *state\maxHeaderBytes = maxHeaderBytes
  *state\maxBodyBytes = maxBodyBytes
  *state\errorCode = #JSONRPC_Framing_ErrorNone
  *state\errorMessage = ""
EndProcedure

Procedure JSONRPC_Framing_Reset(*state.JSONRPC_FrameState)
  JSONRPC_Framing_Init(*state, *state\maxHeaderBytes, *state\maxBodyBytes)
EndProcedure

Procedure JSONRPC_Framing_PushBytes(*state.JSONRPC_FrameState, chunk.s)
  If *state\errorCode = #JSONRPC_Framing_ErrorNone
    *state\buffer + chunk
  EndIf
EndProcedure

Procedure.i JSONRPC_Framing_NextMessage(*state.JSONRPC_FrameState, *message.JSONRPC_Message)
  Protected headerEnd.i
  Protected header.s
  Protected bodyLength.i
  Protected bodyStart.i
  Protected availableBody.s
  Protected availableBodyBytes.i
  Protected bodyCharCount.i

  *message\body = ""
  *message\byteLength = 0

  If *state\errorCode <> #JSONRPC_Framing_ErrorNone
    ProcedureReturn #False
  EndIf

  headerEnd = FindString(*state\buffer, #JSONRPC_Framing_HeaderTerminator$, 1)

  If headerEnd = 0
    If JSONRPC_Framing_Utf8ByteLength(*state\buffer) > *state\maxHeaderBytes
      JSONRPC_Framing_SetError(*state, #JSONRPC_Framing_ErrorHeaderTooLarge, "Header exceeds configured maximum.")
    EndIf

    ProcedureReturn #False
  EndIf

  header = Left(*state\buffer, headerEnd - 1)

  If JSONRPC_Framing_Utf8ByteLength(header) > *state\maxHeaderBytes
    JSONRPC_Framing_SetError(*state, #JSONRPC_Framing_ErrorHeaderTooLarge, "Header exceeds configured maximum.")
    ProcedureReturn #False
  EndIf

  bodyLength = JSONRPC_Framing_ContentLengthFromHeader(*state, header)
  If *state\errorCode <> #JSONRPC_Framing_ErrorNone
    ProcedureReturn #False
  EndIf

  bodyStart = headerEnd + Len(#JSONRPC_Framing_HeaderTerminator$)
  availableBody = Mid(*state\buffer, bodyStart)
  availableBodyBytes = JSONRPC_Framing_Utf8ByteLength(availableBody)

  If availableBodyBytes < bodyLength
    ProcedureReturn #False
  EndIf

  bodyCharCount = JSONRPC_Framing_Utf8CharCountForByteLength(availableBody, bodyLength)

  If bodyCharCount = -2
    ProcedureReturn #False
  EndIf

  If bodyCharCount < 0
    JSONRPC_Framing_SetError(*state, #JSONRPC_Framing_ErrorBodyLengthSplitsUtf8Character, "Content-Length ends inside a UTF-8 character.")
    ProcedureReturn #False
  EndIf

  If bodyCharCount = 0
    *message\body = ""
  Else
    *message\body = Left(availableBody, bodyCharCount)
  EndIf

  *message\byteLength = bodyLength
  *state\buffer = Mid(availableBody, bodyCharCount + 1)

  ProcedureReturn #True
EndProcedure

Procedure.i JSONRPC_Framing_HasError(*state.JSONRPC_FrameState)
  ProcedureReturn Bool(*state\errorCode <> #JSONRPC_Framing_ErrorNone)
EndProcedure

Procedure.i JSONRPC_Framing_GetErrorCode(*state.JSONRPC_FrameState)
  ProcedureReturn *state\errorCode
EndProcedure

Procedure.s JSONRPC_Framing_GetErrorMessage(*state.JSONRPC_FrameState)
  ProcedureReturn *state\errorMessage
EndProcedure

Procedure.i JSONRPC_Framing_Utf8ByteLength(text.s)
  ProcedureReturn StringByteLength(text, #PB_UTF8)
EndProcedure

Procedure.s JSONRPC_Framing_BuildFrame(body.s)
  ProcedureReturn "Content-Length: " + Str(JSONRPC_Framing_Utf8ByteLength(body)) + #CRLF$ + #CRLF$ + body
EndProcedure

