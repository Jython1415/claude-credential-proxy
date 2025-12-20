---
name: Git Proxy
description: Execute git operations through a secure proxy server. Use when you need to clone, commit, push, pull, or manage git repositories from Claude.ai Projects.
dependencies: python>=3.7, requests>=2.31.0
---

# Git Proxy Skill

Execute git operations (clone, commit, push, pull, branch management) through a secure HTTPS proxy server.

## Prerequisites

This skill requires a `.env` file in your project with:

```
GIT_PROXY_URL=https://your-machine.your-tailnet.ts.net
GIT_PROXY_KEY=your-secret-authentication-key
```

## Quick Start

```python
from git_client import GitProxyClient

# Initialize client (reads from .env automatically)
client = GitProxyClient()

# Clone a repository
repo_path = client.clone('https://github.com/username/repo.git')

# Check status
status = client.status(repo_path)
print(status)

# Make changes, then commit
client.commit(repo_path, "Your commit message here")

# Push to remote
client.push(repo_path, branch='main')
```

## Common Operations

### Clone Repository
```python
repo = client.clone('https://github.com/user/repo.git')
```

### Check Status
```python
status = client.status(repo)
```

### Create Branch
```python
client.branch(repo, 'feature-branch', checkout=True)
```

### Commit Changes
```python
client.commit(repo, "Describe your changes")
```

### Push to Remote
```python
client.push(repo, branch='main')
```

### Pull Latest
```python
client.pull(repo)
```

### View History
```python
log = client.log(repo, n=10)
```

## API Reference

### GitProxyClient Methods

- `health_check()` - Verify proxy server is reachable
- `clone(repo_url, local_path=None)` - Clone a repository
- `status(repo_path, short=True)` - Get repository status
- `add(repo_path, files="-A")` - Stage files
- `commit(repo_path, message, files=None)` - Commit changes
- `push(repo_path, branch='main', remote='origin')` - Push to remote
- `pull(repo_path, branch='main', remote='origin')` - Pull from remote
- `log(repo_path, n=10, oneline=True)` - View commit history
- `branch(repo_path, branch_name=None, checkout=False)` - Manage branches
- `checkout(repo_path, branch)` - Switch branches
- `list_workspace()` - List all repositories in workspace

## Troubleshooting

### Connection Errors
- Verify `.env` file exists in project
- Check `GIT_PROXY_URL` and `GIT_PROXY_KEY` are set correctly
- Ensure proxy server is running on your local machine
- Confirm domain is in Claude.ai allowed domains list

### Authentication Failures
- Verify `GIT_PROXY_KEY` matches the secret key on your proxy server
- Check server logs for authentication attempts

### Command Failures
- All commands must start with `git ` (enforced by proxy for security)
- Ensure you're in a valid git repository path
- Check server logs: `tail -f ~/Library/Logs/gitproxy.log`

## Security Notes

- All git commands are executed through an authenticated proxy
- The proxy server validates all commands before execution
- Commands are restricted to workspace directory only
- Full audit trail maintained in server logs
