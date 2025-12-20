# Git Proxy Skill for Claude.ai

This skill enables Claude.ai Projects to execute git operations through a secure proxy server.

## Installation

### Step 1: Install the Skill

1. Download `git-proxy-skill.zip` from this repository
2. In Claude.ai, go to **Settings → Skills**
3. Click **Upload Custom Skill**
4. Upload the ZIP file
5. Enable the "Git Proxy" skill

### Step 2: Configure Your Project

In any Claude.ai Project where you want to use git operations:

1. Create a file named `.env` with:
   ```
   GIT_PROXY_URL=https://your-machine.your-tailnet.ts.net
   GIT_PROXY_KEY=your-secret-key
   ```
2. Upload this `.env` file to the project
3. Add your Tailscale domain to **Project Settings → Allowed Domains**

### Step 3: Verify Setup

Ask Claude in your project:
```
Can you use the Git Proxy skill to check if the proxy server is healthy?
```

Claude should execute:
```python
from git_client import GitProxyClient
client = GitProxyClient()
client.health_check()
```

## Usage

Once installed, Claude will automatically use this skill when you ask to perform git operations:

- "Clone the repository at https://github.com/user/repo.git"
- "Commit these changes with message: 'Updated documentation'"
- "Push the changes to the main branch"
- "Show me the git log for the last 10 commits"

## Requirements

- Git proxy server running (see main project README)
- Tailscale Funnel active
- `.env` file in each project that uses the skill

## Notes

- The skill reads `GIT_PROXY_URL` and `GIT_PROXY_KEY` from the project's `.env` file
- Each project can use different proxy servers by having different `.env` files
- The skill keeps no state - all configuration is per-project
