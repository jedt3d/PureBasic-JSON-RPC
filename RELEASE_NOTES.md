# Release Notes

## 0.1.0-alpha.1

Initial macOS arm64 alpha target for the PureBasic JSON-RPC 2.0 library.

Highlights:

- JSON-RPC 2.0 parsing, dispatch, responses, notifications, and batches.
- Content-Length framing and newline-delimited stdio codec.
- Connection lifecycle, pending requests, timeouts, cancellation, diagnostics, events, write queue, and tracing.
- JSON-RPC compliance runner.
- MCP-oriented adapter previews for lifecycle and tools.
- Console, shared library, and app compile templates.

Status:

- API is alpha and may still evolve.
- Public procedure names are preferred stable surfaces.
- Public structure fields remain experimental unless documented otherwise.
