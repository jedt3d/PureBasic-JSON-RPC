EnableExplicit

#ProjectName$ = "PureBasic JSON-RPC 2.0"

CompilerSelect #PB_Compiler_Processor
  CompilerCase #PB_Processor_arm64
    #ProbeProcessor$ = "arm64"
  CompilerCase #PB_Processor_x64
    #ProbeProcessor$ = "x64"
  CompilerDefault
    #ProbeProcessor$ = "unsupported"
CompilerEndSelect

PrintN(#ProjectName$ + " foundation probe")
PrintN("PureBasic compiler version: " + Str(#PB_Compiler_Version))
PrintN("Compiler processor: " + #ProbeProcessor$)
PrintN("Console scenario: OK")

End 0

