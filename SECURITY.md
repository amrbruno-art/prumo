# Security

## Reporting

If you believe you found a vulnerability in Prumo, **do not** open a public issue.

Email or message the repository owner via GitHub Security Advisories on this repository:

https://github.com/amrbruno-art/prumo/security/advisories/new

Please include:

- a description of the issue;
- steps to reproduce;
- affected version / commit;
- impact (e.g. XSS, data leak).

## Scope

Prumo is a client-side web timer. It stores data in the browser (`localStorage`). It does not require an account. Typical issues to report: XSS, unexpected code execution, abuse of the Notification API, or supply-chain problems in dependencies.

This project is provided as-is. See `DISCLAIMER.md`.
