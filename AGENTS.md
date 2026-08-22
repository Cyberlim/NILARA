# AGENTS.md

## Mandatory Security Instructions

Before creating, modifying, refactoring, reviewing, or deploying any code in this project, read and follow `SECURITY.md`.

`SECURITY.md` is a mandatory project-wide security policy. Its requirements apply to every feature and every application component.

## Core Rules

1. Never weaken or remove security controls just to make a feature work.
2. Treat the client, browser, mobile app, network, user input, URL/query/body parameters, uploaded files, tokens, WebSocket events, and third-party callbacks as untrusted.
3. Enforce authentication and authorization on the backend for every protected operation.
4. Verify resource ownership to prevent IDOR/BOLA.
5. Never trust frontend-provided roles, permissions, prices, payment status, ownership IDs, verification state, or other privileged values.
6. Validate and constrain all server inputs.
7. Never expose private secrets, database credentials, JWT secrets, Firebase Admin credentials, signing keys, SMTP passwords, Cloudinary secrets, payment secrets, or other server credentials to frontend/mobile code.
8. Apply rate limiting and abuse controls according to endpoint risk.
9. Protect REST APIs and Socket.IO/WebSocket events with equivalent authentication, authorization, validation, and abuse controls.
10. Use HTTPS in production and place public backend traffic behind the approved reverse proxy/API gateway/WAF architecture where applicable.
11. Apply least privilege to users, administrators, services, database accounts, and CI/CD credentials.
12. Log and audit security-sensitive actions without logging passwords, OTPs, full tokens, authorization headers, private keys, or other secrets.
13. Add or update security tests whenever security-sensitive behavior changes.
14. Do not claim the application is 100% secure or unhackable.
15. Do not mark a task production-ready while a known CRITICAL security vulnerability remains unresolved.

## Required Workflow

For every implementation:

1. Understand the requested feature and its trust boundaries.
2. Read relevant existing code before changing it.
3. Identify authentication, authorization, ownership, validation, secret-management, abuse, and business-logic risks.
4. Implement the smallest secure solution.
5. Preserve existing security controls.
6. Add tests for important failure and unauthorized cases.
7. Review changed code against `SECURITY.md`.
8. Report remaining risks.

## Required Completion Report

For major implementations, finish with:

- Authentication: PASS / FAIL / N/A
- Authorization: PASS / FAIL / N/A
- Ownership / IDOR protection: PASS / FAIL / N/A
- Input validation: PASS / FAIL
- Rate limiting: PASS / FAIL / N/A
- Secret exposure: PASS / FAIL
- Database security: PASS / FAIL / N/A
- API security: PASS / FAIL / N/A
- Socket security: PASS / FAIL / N/A
- Admin security: PASS / FAIL / N/A
- Remaining risks: list explicitly

If my requested implementation conflicts with `SECURITY.md`, do not silently bypass the policy. Explain the conflict and use the safest practical implementation.
