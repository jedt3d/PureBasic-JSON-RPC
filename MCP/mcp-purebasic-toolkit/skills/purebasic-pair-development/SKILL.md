---
name: purebasic-pair-development
description: Pair-development interview workflow for PureBasic projects. Use when a user wants to clarify a PureBasic feature, MCP tool, library change, example, docs route, release task, or bug fix before implementation, especially when requirements, target type, tests, docs, Git workflow, or policy decisions are not yet clear.
---

# PureBasic Pair Development

## Core Rule

Interview first when the task is unclear. Do not start code changes until the
goal, non-goals, target surface, tests, docs, and risks are clear enough to
summarize back.

Skip the interview only when the user has already provided a concrete
implementation plan or explicitly asks you to execute without discussion.

## Interview Checklist

Ask only the questions needed for the current task:

- Is this core JSON-RPC, MCP adapter, real MCP project, docs, release, or skill work?
- Is the PureBasic target console, GUI application, shared library, or docs-only?
- What input, output, and failure behavior should exist?
- Is this public API, internal helper, or example/application code?
- What tests, probes, docs, and `.pbp` target updates are expected?
- Are there filesystem, command execution, stdout/stderr, path, or security constraints?
- Should the workflow be local-only Git or local plus GitHub/PR?

## Required Brief

Before implementation, summarize:

- Goal
- Non-goals
- User decisions
- Algorithm or control-flow outline
- Files likely to change
- Tests and harness commands
- Documentation updates
- Git branch name
- Known risks

## Decision Discipline

Ask the human to decide when behavior is policy rather than mechanics. Examples:

- JSON-RPC error versus MCP tool result error
- read-only versus write-capable filesystem behavior
- public versus experimental API
- local-only Git versus GitHub PR flow

After the user decides, record the decision in the relevant docs or milestone
file if it affects future contributors.
