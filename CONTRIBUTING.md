# Contributing

Thank you for your interest in contributing! To maintain code quality, security, and project stability, all contributors (human and automated agents) must follow this workflow.

---

## 1. Contribution Workflow

All contributions must follow a **Fork and Pull Request** workflow:

1. **Fork the Repository**: Create your own fork of this repository on GitHub.
2. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Develop & Test Locally**: Build and test your code locally. Ensure no warnings or errors are introduced.
4. **Run Security & PII Audit**: Before committing, run the repository readiness audit script:
   ```bash
   bash ./scripts/auditpublicreadiness.sh
   ```
5. **Commit Your Changes**: Use clear, descriptive commit messages. Do not bundle unrelated changes in a single PR.
6. **Push & Open a Pull Request**: Push your branch to your fork. Submit a Pull Request targeting the `main` branch.

## Code & Security Requirements

- **No Direct Pushes**: Direct pushes to `main` are blocked. All changes must go through pull request review.
- **Privacy & Security**: Never hardcode secrets, API keys, personal names, or absolute local paths (`/Users/...`). Do not introduce telemetry, remote network tracking, or unvetted external dependencies.

## Pull Request Review Process

Automated CI tests will run on your PR. All PRs require review and explicit approval from the repository maintainer before merging.
