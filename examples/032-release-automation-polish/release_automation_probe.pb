EnableExplicit

Procedure.s ReadTextFile(path.s)
  Protected file.i
  Protected text.s

  file = ReadFile(#PB_Any, path, #PB_UTF8)
  If file = 0
    ProcedureReturn ""
  EndIf

  While Eof(file) = 0
    text + ReadString(file, #PB_UTF8) + #LF$
  Wend

  CloseFile(file)
  ProcedureReturn text
EndProcedure

Procedure.s ReadProjectTextFile(path.s)
  Protected text.s

  text = ReadTextFile(path)
  If text <> ""
    ProcedureReturn text
  EndIf

  text = ReadTextFile("../" + path)
  If text <> ""
    ProcedureReturn text
  EndIf

  text = ReadTextFile("../../" + path)
  If text <> ""
    ProcedureReturn text
  EndIf

  ProcedureReturn ""
EndProcedure

Define checkScript.s = ReadProjectTextFile("tools/check.sh")
Define verifier.s = ReadProjectTextFile("tools/verify-release-artifacts.sh")
Define checklist.s = ReadProjectTextFile("docs/release-checklist.md")
Define packageIndex.i
Define verifierIndex.i

If checkScript = ""
  PrintN("missing tools/check.sh")
  End 1
EndIf

If verifier = ""
  PrintN("missing tools/verify-release-artifacts.sh")
  End 1
EndIf

If checklist = ""
  PrintN("missing docs/release-checklist.md")
  End 1
EndIf

packageIndex = FindString(checkScript, "package-alpha.sh", 1)
verifierIndex = FindString(checkScript, "verify-release-artifacts.sh", 1)

If packageIndex = 0 Or verifierIndex = 0 Or verifierIndex < packageIndex
  PrintN("release artifact verifier is not wired after packaging")
  End 1
EndIf

If FindString(verifier, "API/032-release-automation-polish.md", 1) = 0
  PrintN("release artifact verifier does not check the current API page")
  End 1
EndIf

If FindString(checklist, "./tools/check.sh", 1) = 0 Or FindString(checklist, "./tools/verify-release-artifacts.sh", 1) = 0
  PrintN("release checklist does not describe the final verification path")
  End 1
EndIf

PrintN("release automation scenario: OK")
End 0
