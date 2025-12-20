# Git Proxy Skill Setup for Claude.ai Projects

Complete guide for using the Git Proxy skill in Claude.ai Projects.

## Overview

The skill-based approach keeps `git_client.py` out of your project context, only loading it when needed for git operations. This saves context space and keeps your project files clean.

## One-Time Server Setup

### 1. Install and Configure Proxy Server

```bash
cd ~/Documents/_programming/claude-git-bridge

# Install dependencies
./scripts/setup.sh

# Install Tailscale from Mac App Store and login

# Start Tailscale Funnel (auto-restarts on boot)
tailscale funnel --bg 8443

# Auto-start Flask server on login
./scripts/install_launchagent.sh

# Get your stable URL
tailscale funnel status
# Copy the URL (e.g., https://your-machine.tail-abc123.ts.net)

# Get your secret key
grep PROXY_SECRET_KEY .env
# Copy the key value
```

**Done!** Server is now running and will auto-start on boot.

## Install Skill in Claude.ai

### 1. Download the Skill

Get `git-proxy-skill.zip` from:
```
claude-git-bridge/skill-package/git-proxy-skill.zip
```

### 2. Upload to Claude.ai

1. Go to **claude.ai → Settings → Skills**
2. Click **Upload Custom Skill**
3. Upload `git-proxy-skill.zip`
4. Enable the "Git Proxy" skill

**Done!** The skill is now available in all your projects.

## Configure Each Project

For each Claude.ai Project that needs git access:

### 1. Add Domain to Allowed List

**Critical:** Without this, all requests fail with 403.

1. Go to **Project Settings → Security/Network**
2. Add your Tailscale domain (e.g., `your-machine.tail-abc123.ts.net`)

### 2. Create .env File

1. In the project, click **+ → Add text content**
2. Name it `.env`
3. Add:
   ```
   GIT_PROXY_URL=https://your-machine.your-tailnet.ts.net
   GIT_PROXY_KEY=<your-secret-key>
   ```

**Note:** Use the URL and key from your server setup above.

### 3. Give Claude Instructions

In your project's main instructions or README, add:

````markdown
## Git Operations

This project uses the Git Proxy skill for git operations.

When you need to:
- Clone the project repository
- Commit changes to documentation
- Push improvements
- Create feature branches

Use the Git Proxy skill. The repository URL is: https://github.com/username/your-project-repo.git
````

### 4. Test It

Ask Claude:
```
Can you use the Git Proxy skill to check if the proxy server is reachable?
```

Expected response:
```python
{
  'status': 'healthy',
  'workspace': '~/git-proxy-workspace',
  'timestamp': '...'
}
```

## Project Repository Structure

**Recommended structure for projects synced to GitHub:**

```
your-project-repo/
├── README.md                    # Main project docs
├── project-knowledge/           # ← Sync THIS to Claude.ai
│   ├── README.md               # Instructions for Claude
│   ├── design-principles.md
│   └── content.md
└── .github/                     # (optional)
    └── workflows/
```

**In Claude.ai Project Settings:**
- **Sync folder**: `project-knowledge/` only
- **Why**: Keeps infrastructure separate from content
- **Benefit**: Claude only sees relevant knowledge, not meta files

## Usage Examples

Once configured, Claude will automatically use the skill:

### Clone Your Project Repo
```
Clone our project repository at https://github.com/user/project.git
and show me the structure.
```

### Propose Improvements
```
Analyze the project documentation in the repo.
Create a feature branch called "claude/improve-docs".
Make improvements to gaps you identify.
Commit with a descriptive message.
Push the branch for my review.
```

### Regular Workflow
```
I've made changes to the project knowledge.
Please commit them with message: "Updated design principles"
and push to the main branch.
```

## Troubleshooting

### Skill Not Activating

**Symptom:** Claude doesn't use the skill when asked about git.

**Fix:** Be explicit:
```
Use the Git Proxy skill to clone the repository.
```

### Connection Errors

**Symptom:** "Connection refused" or timeout errors.

**Check:**
1. Is your Mac awake and online?
2. Server running: `tail -f ~/Library/Logs/gitproxy.log`
3. Funnel active: `tailscale funnel status`
4. Domain in allowed list: Project Settings → Security

### Authentication Errors

**Symptom:** "401 Unauthorized"

**Fix:**
1. Verify keys match: Compare `.env` in project with local `grep PROXY_SECRET_KEY .env`
2. Check server logs: `tail -f ~/Library/Logs/gitproxy-error.log`

### Env Variable Not Found

**Symptom:** "Missing GIT_PROXY_URL"

**Fix:**
1. Verify `.env` file is uploaded to project
2. File must be named exactly `.env` (not `.env.txt`)
3. Try re-uploading the file

## Benefits of Skill Approach

✅ **Clean context**: `git_client.py` not loaded in every conversation
✅ **Reusable**: One skill works across all projects
✅ **Easy updates**: Update skill once, affects all projects
✅ **Automatic**: Claude knows when to use it
✅ **Per-project config**: Each project can have different credentials

## Maintenance

### Update the Skill

1. Make changes to `skill-package/git-proxy/`
2. Re-create ZIP: `(cd skill-package && zip -r git-proxy-skill.zip git-proxy/)`
3. Re-upload to Claude.ai Settings → Skills

### View Server Logs

```bash
# Server output
tail -f ~/Library/Logs/gitproxy.log

# Server errors
tail -f ~/Library/Logs/gitproxy-error.log
```

### Restart Server

```bash
launchctl unload ~/Library/LaunchAgents/com.joshuashew.gitproxy.plist
launchctl load ~/Library/LaunchAgents/com.joshuashew.gitproxy.plist
```

## Security Notes

- **.env files are per-project**: Each project has its own credentials
- **Secret key stays on your Mac**: Never committed to git
- **Audit trail**: All operations logged on server
- **Workspace isolation**: Commands restricted to workspace directory
- **Command validation**: Only `git ` commands allowed (server enforced)

**Sources:**
- [How to create custom Skills](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)
- [Claude Skills announcement](https://www.anthropic.com/news/skills)
- [Skills explained: How Skills compares to prompts, Projects, MCP](https://claude.com/blog/skills-explained)
