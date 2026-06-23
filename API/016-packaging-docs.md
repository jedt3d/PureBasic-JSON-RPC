# 016 Packaging And ReadTheDocs

Milestone `016-packaging-docs` adds the consolidated include and compile templates.

## Include

```purebasic
XIncludeFile "src/jsonrpc/jsonrpc.pbi"
```

## Packaging Templates

- `examples/016-packaging-docs/console_template.pb` verifies console application compilation.
- `examples/016-packaging-docs/shared_library_template.pb` verifies shared library compilation.
- `examples/016-packaging-docs/app_template.pb` verifies GUI/app target compilation.

## Behavior

- `jsonrpc.pbi` includes the complete generic JSON-RPC and MCP adapter stack.
- Existing lower-level includes remain supported.
- Documentation navigation links the top-level API index for Read the Docs.
