EnableExplicit

XIncludeFile "../../src/jsonrpc/jsonrpc.pbi"

If JSONRPC_LibraryVersion() <> "0.1.0-alpha.1"
  PrintN("unexpected library version: " + JSONRPC_LibraryVersion())
  End 1
EndIf

If JSONRPC_LibraryStatus() <> "alpha"
  PrintN("unexpected library status: " + JSONRPC_LibraryStatus())
  End 1
EndIf

PrintN("public API review scenario: OK")
End 0
