EnableExplicit

PureUnitOptions(Thread)

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

ProcedureUnit ReleaseQualityGatesDocumentExists()
  Protected body.s

  body = ReadProjectTextFile("docs/release-quality-gates.md")

  Assert(Len(body) > 0, "Release quality gates document should be readable.")
  Assert(FindString(body, "### Alpha", 1) > 0, "Alpha gate should be documented.")
  Assert(FindString(body, "### Beta", 1) > 0, "Beta gate should be documented.")
  Assert(FindString(body, "### Production Candidate", 1) > 0, "Production candidate gate should be documented.")
EndProcedureUnit

ProcedureUnit ReleaseQualityGatesIncludeDocumentationAndPathHygiene()
  Protected body.s

  body = ReadProjectTextFile("docs/release-quality-gates.md")

  Assert(FindString(body, "Documentation Freshness Gate", 1) > 0, "Documentation freshness should be a gate.")
  Assert(FindString(body, "Absolute Path Gate", 1) > 0, "Absolute path hygiene should be a gate.")
  Assert(FindString(body, "./tools/verify-docs.sh", 1) > 0, "Documentation verification should be required.")
EndProcedureUnit
