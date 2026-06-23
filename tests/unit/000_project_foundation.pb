EnableExplicit

PureUnitOptions(Thread)

ProcedureUnit PureBasicVersionIsPinned()
  Assert(#PB_Compiler_Version = 640, "This project requires PureBasic 6.40.")
EndProcedureUnit

ProcedureUnit CompilerProcessorIsSupported()
  Assert(#PB_Compiler_Processor = #PB_Processor_arm64 Or #PB_Compiler_Processor = #PB_Processor_x64, "Target processor must be arm64 or x64.")
EndProcedureUnit

ProcedureUnit JsonLibraryCanAllocateAndFreeHandle()
  Protected json.i

  json = CreateJSON(#PB_Any)
  Assert(json <> 0, "CreateJSON() should allocate a JSON handle.")

  If json <> 0
    FreeJSON(json)
  EndIf
EndProcedureUnit

