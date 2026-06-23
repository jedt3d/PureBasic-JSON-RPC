EnableExplicit

XIncludeFile "stress.pbi"

Structure JSONRPC_StdioRuntime
  reader.JSONRPC_StdioCodecState
  processedMessages.i
EndStructure

Declare JSONRPC_StdioRuntime_Init(*runtime.JSONRPC_StdioRuntime, maxMessageBytes.i = #JSONRPC_Codec_StdioDefaultMaxMessageBytes)
Declare.i JSONRPC_StdioRuntime_Feed(*runtime.JSONRPC_StdioRuntime, *dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, chunk.s)
Declare.i JSONRPC_StdioRuntime_ProcessMessage(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)

Procedure JSONRPC_StdioRuntime_Init(*runtime.JSONRPC_StdioRuntime, maxMessageBytes.i = #JSONRPC_Codec_StdioDefaultMaxMessageBytes)
  JSONRPC_Codec_StdioInit(@*runtime\reader, maxMessageBytes)
  *runtime\processedMessages = 0
EndProcedure

Procedure.i JSONRPC_StdioRuntime_ProcessMessage(*dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, body.s)
  Protected inspect.JSONRPC_ProtocolResult

  If JSONRPC_Batch_IsBatch(body)
    ProcedureReturn JSONRPC_Batch_DispatchToConnection(*dispatcher, *connection, body)
  EndIf

  If JSONRPC_Protocol_Inspect(body, @inspect)
    If inspect\messageType = #JSONRPC_MessageTypeResponse
      ProcedureReturn JSONRPC_Connection_MatchResponse(*connection, body)
    EndIf
  EndIf

  If JSONRPC_Cancel_ProcessNotification(*connection, body)
    ProcedureReturn #True
  EndIf

  ProcedureReturn JSONRPC_Dispatcher_DispatchToConnection(*dispatcher, *connection, body)
EndProcedure

Procedure.i JSONRPC_StdioRuntime_Feed(*runtime.JSONRPC_StdioRuntime, *dispatcher.JSONRPC_Dispatcher, *connection.JSONRPC_Connection, chunk.s)
  Protected message.JSONRPC_Message

  JSONRPC_Codec_StdioPushBytes(@*runtime\reader, chunk)

  While JSONRPC_Codec_StdioNextMessage(@*runtime\reader, @message)
    If JSONRPC_StdioRuntime_ProcessMessage(*dispatcher, *connection, message\body) = #False
      ProcedureReturn #False
    EndIf
    *runtime\processedMessages + 1
  Wend

  ProcedureReturn Bool(JSONRPC_Codec_StdioHasError(@*runtime\reader) = #False)
EndProcedure
