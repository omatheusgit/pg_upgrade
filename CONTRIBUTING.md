# Contributing to pg_upgrade

First off, thanks for taking the time to contribute! 🎉

## How Can I Contribute?

### 🐛 Reporting Bugs

- Open an [Issue](https://github.com/omatheusgit/pg_upgrade/issues/new) with the label `bug`
- Include the PostgreSQL versions involved (old → new)
- Paste the relevant terminal output or error messages
- Mention your OS and distribution version

### 💡 Suggesting Features

- Open an [Issue](https://github.com/omatheusgit/pg_upgrade/issues/new) with the label `enhancement`
- Describe the feature and why it would be useful
- If possible, suggest an implementation approach

### 🔧 Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Test in a safe environment (never test on production databases!)
5. Commit with a clear message: `git commit -m "feat: add dry-run mode"`
6. Push to your fork: `git push origin feature/my-feature`
7. Open a Pull Request

### 📝 Commit Message Convention

We follow a simple convention:

| Prefix | Usage |
|---|---|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Documentation changes |
| `refactor:` | Code refactoring |
| `chore:` | Maintenance tasks |

**Example:** `feat: add support for PostgreSQL 17`

### ⚠️ Important

- **Never** include real credentials, IPs, or production data in issues or PRs
- Always test changes in a **staging/dev environment**
- Keep the script simple and readable — that's a core design principle

## Questions?

Feel free to open an issue with the label `question`. We're happy to help!
