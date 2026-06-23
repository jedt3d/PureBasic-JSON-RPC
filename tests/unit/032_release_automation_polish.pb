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

ProcedureUnit ReleaseArtifactVerifierIsWiredAfterPackaging()
  Protected checkScript.s
  Protected verifier.s
  Protected packageIndex.i
  Protected verifierIndex.i

  checkScript = ReadProjectTextFile("tools/check.sh")
  verifier = ReadProjectTextFile("tools/verify-release-artifacts.sh")

  Assert(checkScript <> "", "tools/check.sh should be readable.")
  Assert(verifier <> "", "tools/verify-release-artifacts.sh should be readable.")

  packageIndex = FindString(checkScript, "package-alpha.sh", 1)
  verifierIndex = FindString(checkScript, "verify-release-artifacts.sh", 1)

  Assert(packageIndex > 0, "Full check should package the alpha release.")
  Assert(verifierIndex > packageIndex, "Full check should verify release artifacts after packaging.")
  Assert(FindString(verifier, "shasum -a 256 -c", 1) > 0, "Verifier should validate checksums.")
  Assert(FindString(verifier, "docs/release-checklist.md", 1) > 0, "Verifier should require the release checklist in the manifest.")
  Assert(FindString(verifier, "API/032-release-automation-polish.md", 1) > 0, "Verifier should require the current API page.")
EndProcedureUnit

ProcedureUnit ReleaseChecklistDocumentsRequiredGuards()
  Protected checklist.s

  checklist = ReadProjectTextFile("docs/release-checklist.md")

  Assert(checklist <> "", "Release checklist should exist.")
  Assert(FindString(checklist, "./tools/verify-projects.sh", 1) > 0, "Checklist should include project verification.")
  Assert(FindString(checklist, "./tools/verify-docs.sh", 1) > 0, "Checklist should include docs verification.")
  Assert(FindString(checklist, "./tools/verify-paths.sh", 1) > 0, "Checklist should include path verification.")
  Assert(FindString(checklist, "./tools/build-docs.sh", 1) > 0, "Checklist should include docs build.")
  Assert(FindString(checklist, "./tools/check.sh", 1) > 0, "Checklist should include full check.")
  Assert(FindString(checklist, "SHA-256", 1) > 0, "Checklist should require checksum verification.")
EndProcedureUnit

ProcedureUnit RouteMetadataIncludesReleaseAutomation()
  Protected milestones.s
  Protected apiIndex.s
  Protected docsApi.s
  Protected releaseNotes.s

  milestones = ReadProjectTextFile("docs/milestones.md")
  apiIndex = ReadProjectTextFile("API/index.md")
  docsApi = ReadProjectTextFile("docs/api.md")
  releaseNotes = ReadProjectTextFile("docs/release-notes.md")

  Assert(FindString(milestones, "## 032-release-automation-polish", 1) > 0, "Milestones should include 032.")
  Assert(FindString(milestones, "Status: completed", 1) > 0, "Milestones should mark completed routes.")
  Assert(FindString(apiIndex, "032-release-automation-polish.md", 1) > 0, "API index should include 032.")
  Assert(FindString(docsApi, "API/032-release-automation-polish.md", 1) > 0, "Docs API bridge should include 032.")
  Assert(FindString(releaseNotes, "release artifact verifier", 1) > 0, "Release notes should mention the verifier.")
EndProcedureUnit
