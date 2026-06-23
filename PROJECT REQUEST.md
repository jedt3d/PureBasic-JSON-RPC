# Project Request: PureBasic JSON-RPC 2.0 Library

## Objective

Build a PureBasic JSON-RPC 2.0 library based on the architecture described in `GUIDELINE.md`.

The library should be reliable, testable, memory-conscious, and suitable for long-running tools, agent integrations, editor integrations, and service communication. The implementation should follow the JSON-RPC 2.0 official specification and take architectural inspiration from Microsoft’s `vscode-jsonrpc`.

Before implementing library features, first establish a strong AI development harness and an `AGENTS.md` project guideline so future AI agents and contributors follow the same workflow, testing expectations, architecture, and quality standards.

## Required References

Use these as primary sources:

- `GUIDELINE.md` in this repository
- Official JSON-RPC 2.0 specification: `https://www.jsonrpc.org/specification`
- Microsoft `vscode-jsonrpc` repository/package as an architectural reference
- Official PureBasic 6.40 documentation `https://www.purebasic.com/documentation/`
- PureUnit documentation and examples

Sample protocol data, compliance examples, and benchmark ideas may be researched from the internet, but protocol behavior must be verified against official specifications whenever possible.

## PureBasic Environment Requirements

Use PureBasic version `6.40` only.

The project must support:

- macOS Apple Silicon / ARM64
- Future Windows & Ubuntu x64/ARM64 compatibility where practical

The AI agent should discover the local PureBasic installation and create project-local development homes/configuration as needed, including:

- Look at this folder, /Applications/PureBasic.app/Contents/Resources. It could be set as PureBasic Home.
- PureBasic home/setup for this project
- PureUnit home/setup for this project
- Build output directories
- Test output directories

The agent must understand that PureBasic can compile into different target types, and each needs a different template or build configuration:

- Console application
- macOS application / Windows `.exe`
- Shared library

Because this project is a library, the build system and examples should make those distinctions explicit.

## Development Workflow

Each feature must be developed as a small milestone using this cycle:

1. Create a dedicated Git branch for the feature.
2. Plan the feature as a senior architect.
3. Review the plan’s pros, cons, risks, alternatives, and test strategy.
4. Design one concrete scenario that demonstrates the feature.
5. Implement the feature using test-driven development with PureUnit.
6. Keep the library code and unit tests close together in the same relevant source area.
7. Create a separate example/testing application for the scenario.
8. Place each scenario app in a sequentially numbered folder, preferably matching the feature branch name.
9. Review the code for security, memory leaks, readability, and maintainability.
10. Fix issues found during review.
11. Create or update official API documentation in the `API/` folder as Markdown.
12. Ensure documentation is structured so it can later be compiled by Read the Docs.

## Quality Requirements

Every milestone should include:

- PureUnit tests
- At least one runnable example application
- Protocol compliance checks where relevant
- Memory lifecycle review
- Security review
- Readability review
- Documentation update
- Clear acceptance criteria

Testing should include happy paths, malformed input, edge cases, and long-running stability concerns where applicable.

## Initial Priority

The first milestone should not immediately implement the JSON-RPC library.

Instead, first build the project foundation:

- `AGENTS.md`
- AI harness instructions
- PureBasic/PureUnit discovery process
- Local build/test conventions
- Branch and milestone workflow
- Example app folder convention
- Documentation convention
- Quality gates for future features

This version keeps your intent intact, but makes the request easier for an AI agent or engineer to execute consistently.