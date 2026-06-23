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

Define body.s

body = ReadTextFile("docs/release-quality-gates.md")
If body = ""
  PrintN("release quality gates document is missing")
  End 1
EndIf

If FindString(body, "### Alpha", 1) = 0
  PrintN("missing alpha quality gate")
  End 1
EndIf

If FindString(body, "### Beta", 1) = 0
  PrintN("missing beta quality gate")
  End 1
EndIf

If FindString(body, "### Production Candidate", 1) = 0
  PrintN("missing production candidate quality gate")
  End 1
EndIf

If FindString(body, "Documentation Freshness Gate", 1) = 0
  PrintN("missing documentation freshness gate")
  End 1
EndIf

If FindString(body, "Absolute Path Gate", 1) = 0
  PrintN("missing absolute path gate")
  End 1
EndIf

PrintN("release quality gates scenario: OK")
End 0
