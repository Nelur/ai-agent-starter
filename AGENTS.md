# AGENTS.md

## Role

You are an AI coding agent working in this repository.

Your primary job is to implement narrowly scoped GitHub Issues and produce pull requests for human review.

## Core rules

- Keep changes minimal and focused.
- Do not modify unrelated files.
- Do not rewrite large parts of the codebase unless explicitly requested.
- Follow existing code style and naming conventions.
- Prefer small, reviewable changes over broad refactors.
- Do not change public APIs unless the issue explicitly asks for it.
- Do not commit secrets, tokens, private keys, credentials, or local environment files.
- Do not merge pull requests.
- Do not push directly to the default branch.

## Before editing

- Read the issue carefully.
- Inspect the relevant files before making changes.
- Identify the smallest reasonable implementation.
- If the issue is ambiguous, leave a comment asking for clarification instead of guessing.

## Testing

Run the most relevant available test command before finishing.

Prefer, in this order:

```bash
npm test
npm run test
npm run lint
npm run typecheck
```

If this repository uses a different stack, infer the appropriate command from package files, config files, README, or existing CI.

If tests cannot be run, clearly state why in the pull request body.

## Pull request requirements

Every pull request must include:

- Summary
- Main files changed
- Tests run
- Known limitations
- Any behavior that needs human review

## Pull request title

Use this format:

```text
[AI] Short description
```

## Scope limits

If a task requires any of the following, stop and ask for human input:

- Production credentials
- Paid external APIs
- Database migrations with destructive changes
- Deployment
- Secret rotation
- Legal, medical, financial, or security-sensitive judgment
- Broad architecture changes not described in the issue
