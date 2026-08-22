# SECURITY.md

# Production Application Security Standard

This document is the mandatory security standard for this project.

## 1. Security Principle

Always assume:

- CLIENT = UNTRUSTED
- NETWORK = UNTRUSTED
- USER INPUT = UNTRUSTED
- TOKEN = VERIFY
- RESOURCE = AUTHORIZE
- SECRET = SERVER ONLY
- ADMIN ACTION = AUDIT
- UPLOAD = INSPECT
- PAYMENT = VERIFY SERVER-SIDE
- PRODUCTION TRAFFIC = HTTPS
- SECURITY CONTROL = TEST

Security must not be removed for convenience.

## 2. Recommended Architecture

Production request path:

Client (Flutter / Web / Admin)
-> HTTPS/TLS
-> CDN / DDoS Protection / WAF
-> Reverse Proxy / API Gateway
-> Node.js / Express Backend
-> Internal Services
-> MongoDB / Firebase Admin / Redis / Object Storage

Only intentionally public services should be reachable from the internet.

The reverse proxy is an additional security layer, not a replacement for backend authentication or authorization.

## 3. Reverse Proxy / API Gateway

Use an appropriate reverse proxy/API gateway such as Nginx, Caddy, Traefik, Cloudflare, a cloud load balancer, or managed API gateway.

Where applicable enforce:

- HTTPS termination and HTTP-to-HTTPS redirect
- request/body size limits
- connection limits
- endpoint/IP abuse limits
- request and upstream timeouts
- malformed-request rejection
- secure WebSocket forwarding
- WAF/DDoS protections
- security headers

Configure trusted proxies explicitly. Do not blindly trust X-Forwarded-For, X-Real-IP, or X-Forwarded-Proto.

## 4. Authentication

Passwords must be hashed with Argon2id or bcrypt. Never store plaintext passwords.

Protect:

- signup
- login
- email/phone verification
- OTP
- password reset
- refresh
- logout
- account recovery

Authentication endpoints require appropriate rate limits.

## 5. OTP and Reset Tokens

Use cryptographically secure randomness.

Tokens/codes must:

- expire quickly
- be single-use
- have retry limits
- have resend cooldowns
- be invalidated after successful use

Prefer storing hashes of sensitive reset tokens/OTPs where practical.

Avoid unnecessary account enumeration.

## 6. Firebase / Google Authentication

The client obtains the provider token. The backend verifies it using trusted server SDKs.

Verify signature, issuer, audience/project, and expiration.

Never trust uid, email, role, or isAdmin simply because the client submitted them.

Firebase Admin credentials are server-only.

## 7. Sessions and JWTs

Prefer short-lived access tokens plus rotating/revocable refresh tokens.

Verify:

- signature
- issuer
- audience
- expiration
- token type
- relevant session/account state

Never accept unsigned tokens or attacker-selected algorithms.

For browser cookies, use HttpOnly, Secure, and an appropriate SameSite policy.

## 8. Authorization / RBAC

Every protected operation requires server-side authorization.

Use explicit roles and permissions where appropriate.

Never trust frontend-provided role/permission fields.

Administrative and super-admin permissions must use least privilege.

Privilege changes must be validated and audited.

## 9. IDOR / BOLA

Possession of a resource ID does not grant access.

Verify ownership or explicit permission before reading, editing, deleting, downloading, cancelling, or sharing resources.

Apply this to orders, addresses, profiles, subscriptions, payments, files, chats, notifications, delivery records, reports, and similar resources.

## 10. Input Validation

Validate all untrusted:

- request bodies
- query parameters
- route parameters
- relevant headers
- uploaded files
- WebSocket messages
- webhook payloads

Use a schema validator such as Zod/Joi/Valibot/JSON Schema.

Validate type, length, range, format, enum, arrays, required fields, and object structure.

Reject unexpected fields on sensitive operations.

## 11. Mass Assignment

Never directly use an arbitrary request body as a model create/update payload.

Explicitly allow editable fields.

Protect privileged fields such as role, permissions, isAdmin, balance, verified, ownerId, userId, status, and createdBy.

## 12. Database Security

Keep databases private whenever practical.

Use:

- authenticated database users
- strong generated credentials
- TLS
- least privilege
- restricted network access
- separate credentials/environments

Never expose database connection strings to client applications.

## 13. Injection

Do not pass arbitrary client query objects/operators directly to MongoDB.

Construct queries server-side from validated values.

Use parameterized SQL for relational databases.

Do not concatenate untrusted data into shell/system commands.

## 14. XSS

Treat user-generated HTML as hostile.

Escape output and sanitize rich HTML when supported.

Use Content Security Policy where practical.

Avoid unsafe HTML rendering unless sanitized.

## 15. CORS

Explicitly allow trusted production origins.

Do not use wildcard CORS with credentialed APIs.

CORS is not authentication or authorization.

## 16. CSRF

Cookie-authenticated browser applications must use appropriate CSRF defenses for state-changing requests, such as SameSite cookies, CSRF tokens, and origin validation.

## 17. Security Headers

Configure appropriate:

- Strict-Transport-Security
- Content-Security-Policy
- X-Content-Type-Options
- Referrer-Policy
- Permissions-Policy
- frame-ancestors / clickjacking protections

## 18. HTTPS

Production APIs must use HTTPS.

Never transmit credentials, tokens, OTPs, cookies, personal information, or payment data over plaintext HTTP.

## 19. Secrets

Private credentials must be stored server-side using environment variables or a secret manager.

Never expose private:

- API secrets
- database credentials
- JWT signing secrets
- SMTP credentials
- Firebase Admin credentials
- Cloudinary API secrets
- payment secrets
- OAuth client secrets/private keys

Assume anything shipped to a browser or mobile binary can be inspected.

## 20. Secret Leakage

If a private credential is exposed:

1. revoke/rotate it
2. replace it
3. move the replacement to secure configuration
4. remove it from source
5. inspect logs for misuse
6. clean repository history when appropriate

Deleting the visible string alone is insufficient.

## 21. Rate Limiting and Abuse

Use risk-based rate limits.

Use stricter controls for login, signup, OTP, reset, verification, payments, AI endpoints, uploads, and expensive search operations.

Where useful combine IP, account, session/device, token, and endpoint limits.

Use progressive bot protections for suspicious activity.

## 22. File Uploads

Never trust filename, extension, Content-Type, or MIME header alone.

Validate:

- allowed type
- size
- actual structure where feasible
- dimensions for images
- upload count

Generate safe server-side filenames.

Prevent path traversal, double extensions, executable uploads, archive bombs, and oversized files.

Store uploads outside executable application paths.

## 23. Cloud/Object Storage

Keep signing credentials server-side.

For direct signed uploads, issue short-lived constrained authorization and restrict file type, size, folder, overwrite permissions, and transformations.

## 24. SSRF

If the backend fetches user-supplied URLs, restrict schemes and destinations.

Prevent access to localhost, loopback, private IP ranges, internal services, cloud metadata endpoints such as 169.254.169.254, and file://.

Prefer allowlists.

## 25. Webhooks

Verify cryptographic signatures and replay protections where supported.

Never trust the frontend as proof of payment or other external state.

Process sensitive webhooks idempotently.

## 26. Socket.IO / WebSockets

Authenticate connections.

Authorize every private room join and every sensitive event.

Validate all event payloads.

Apply connection, event-rate, and payload-size limits.

Never allow clients to join another user's private room merely by supplying that user's ID.

## 27. Admin Security

Admin APIs require dedicated server-side authorization.

Use:

- strict RBAC/permissions
- least privilege
- appropriate session expiry
- MFA where appropriate
- stronger monitoring
- audit logs
- rate limiting

A hidden /admin route is not a security control.

## 28. Sensitive Operations

Consider step-up/recent authentication for:

- password/email/phone changes
- account deletion
- permission changes
- admin creation
- MFA disablement
- payout/payment destination changes
- personal-data exports

## 29. Logging and Audit

Log important security events such as login failures, resets, permission changes, admin actions, suspensions, revocations, authorization failures, rate-limit triggers, and webhook failures.

Never log passwords, OTP values, full tokens, authorization headers, refresh tokens, private keys, card data, or secrets.

Sensitive administrative actions should create protected audit records.

## 30. Error Handling

Do not expose production stack traces or internal database/filesystem/service details.

Return safe errors and a request ID. Keep diagnostic details in protected logs.

## 31. Request IDs

Generate and propagate request IDs through proxy/backend/services/logs where appropriate.

## 32. Data Privacy and Encryption

Collect only necessary user data.

Use TLS in transit and provider/database encryption at rest.

Use application-level field encryption only where the threat model requires it.

Never invent custom cryptographic algorithms.

## 33. Dependencies and Supply Chain

Use lock files.

Run dependency and secret scans.

Review high/critical vulnerabilities.

Remove unused/abandoned dependencies.

Use least-privilege CI/CD credentials.

Review suspicious install scripts.

## 34. Environment Separation

Keep development, staging, and production separate.

Do not reuse production secrets in development.

Separate databases, API credentials, OAuth configuration, and payment credentials where practical.

## 35. Production Debugging

Disable debug routes, mock authentication, development dashboards, verbose errors, database explorers, and bypass middleware in production.

Review TODO/FIXME/TEMP/DEBUG/BYPASS/ALLOW_ALL before release.

## 36. API Responses

Return only fields required by the client.

Do not expose password hashes, refresh/reset tokens, OTPs, private notes, secret keys, or unnecessary permission metadata.

## 37. Resource Exhaustion

Enforce pagination and maximum page sizes.

Constrain expensive search, regex, aggregation, sort, export, upload, and AI operations.

Set request, database, external API, socket, and upload timeouts.

Set explicit request/body size limits.

## 38. Payments

The backend must create/verify payment state.

Use trusted payment providers and verify signed callbacks/webhooks.

Never accept frontend paymentStatus as proof.

Do not store raw card numbers or CVVs.

Use idempotency for payment/refund/subscription operations where appropriate.

## 39. Business Logic

Server-side code is authoritative for:

- price
- discount
- tax
- inventory
- subscription duration
- payment status
- permissions
- delivery assignment

Review negative quantities, coupon reuse, repeated trials, price manipulation, inventory bypass, refund abuse, delivery-state manipulation, and duplicate requests.

## 40. Race Conditions / Idempotency

Use atomic updates, transactions, unique constraints, and idempotency keys where appropriate for inventory, coupons, payments, subscriptions, balances, refunds, and other sensitive operations.

## 41. Database Constraints

Use database-level unique indexes, required fields, enums, schema validation, and atomic updates for critical invariants where possible.

## 42. Mobile Security

Assume APK/IPA code can be reverse engineered.

Never embed long-lived private secrets.

Use platform-backed secure storage such as Android Keystore/iOS Keychain for sensitive local credentials where appropriate.

App integrity/attestation may supplement, but never replace, backend security.

## 43. Web Frontend

Assume public/client environment variables are visible.

Keep privileged logic on trusted server/backend code.

Hidden UI components and disabled buttons are not authorization controls.

## 44. Cache Security

Never publicly cache private profiles, orders, addresses, admin responses, or authentication data.

Configure CDN/cache headers to prevent cross-user data leakage.

## 45. WAF / DDoS

Use edge WAF/DDoS protections where practical.

They supplement secure coding; they do not replace it.

Also use application limits, timeouts, pagination, caching, queues, and concurrency controls.

## 46. Backups

Define backup frequency, retention, encryption, and restore procedures.

Test restoration periodically.

## 47. Monitoring / Incident Response

Monitor authentication failures, 401/403/429/5xx spikes, database errors, latency, unexpected admin actions, payment/webhook failures, and suspicious traffic.

Maintain response procedures for credential leaks, compromised accounts, database incidents, malicious admins, DDoS, payment incidents, and vulnerable dependencies.

Support credential rotation, session revocation, account suspension, key revocation, log investigation, and emergency patches.

## 48. Security Tests

Automated tests should cover, where relevant:

- unauthenticated protected access
- normal user accessing admin APIs
- user A accessing user B resources
- expired/invalid tokens
- malformed input
- unexpected fields
- oversized requests
- duplicate payment requests
- unauthorized WebSocket room/event access

## 49. OWASP and Security Scanning

Review against current relevant OWASP Web/API guidance.

Run appropriate:

- secret scanning
- dependency scanning
- static analysis
- linting
- type checking
- security tests
- container scanning when applicable

Possible tools include Dependabot, CodeQL, Semgrep, Gitleaks, Trivy, and npm audit.

Do not blindly auto-fix scanner output. Verify the finding, understand exploitability, implement a targeted fix, test it, and add regression coverage.

## 50. Vulnerability Severity

Classify findings as:

- CRITICAL
- HIGH
- MEDIUM
- LOW
- INFORMATIONAL

Fix in that order.

For each finding document:

- finding
- severity
- affected file/component
- attack scenario
- impact
- recommended fix
- verification method

Do not approve production deployment while an unresolved CRITICAL vulnerability remains.

## 51. Required Pre-Release Review

Review:

- Authentication
- Authorization/RBAC
- IDOR/BOLA
- Input validation
- Rate limiting
- Secret management
- CORS
- CSRF
- Security headers
- HTTPS/proxy/WAF
- Database security
- File uploads
- Socket.IO
- Payments/webhooks
- Admin security
- Logging/auditing
- Dependency/supply-chain security
- Backups
- Monitoring

Report remaining risks explicitly.

## 52. Final Rule

Every feature must pass:

authenticate -> validate -> authorize -> ownership check -> business-rule enforcement -> secret protection -> abuse limits -> secure logging -> failure/security tests.

Never claim the application is 100% secure or unhackable.
