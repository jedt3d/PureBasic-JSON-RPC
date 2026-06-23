# 010 Diagnostics Counters

Milestone `010-diagnostics` adds lightweight connection diagnostics.

## Include

```purebasic
XIncludeFile "src/jsonrpc/diagnostics.pbi"
```

## Public Structures

```purebasic
Structure JSONRPC_Diagnostics
  receivedMessages.q
  sentMessages.q
  errors.q
  timeouts.q
  orphanResponses.q
  batches.q
  cancellations.q
EndStructure
```

## Public Procedures

```purebasic
JSONRPC_Diagnostics_Reset(*connection)
JSONRPC_Diagnostics_Copy(*connection, *diagnostics)
JSONRPC_Diagnostics_Summary(*connection)
```

## Behavior

- Counters are stored on the connection.
- Sends, inbound dispatch, errors, timeouts, orphan responses, batches, and cancellations are counted.
- Diagnostics are observational and do not change protocol wire shapes.
