# Potential Issues and Testing Checklist

Known concerns and areas requiring testing for the Git Proxy skill approach.

## ⚠️ Critical: Environment Variable Access in Skills

### Issue

**Uncertain:** Whether Python code in Claude.ai skills can access `os.getenv()` to read environment variables from a project's `.env` file.

### What We Know

- Claude.ai Projects can have files uploaded (including `.env`)
- Skills documentation doesn't explicitly address env var access
- Claude Code (CLI) skills can access env vars - but this is the web interface

### What Needs Testing

1. **Upload `.env` to project**
2. **Use skill's Python code with:**
   ```python
   import os
   test_var = os.getenv('GIT_PROXY_URL')
   print(f"Found: {test_var}")
   ```
3. **Verify it reads the variable**

### Workarounds If It Fails

**Option A: Hardcode in skill per-project**
- Not ideal: requires custom skill per project
- Defeats reusability benefit

**Option B: Pass credentials explicitly**
```python
# In project instructions
client = GitProxyClient(
    proxy_url='https://ganymede.tail0410a7.ts.net',
    auth_key='<secret-key>'
)
```
- Problem: Exposes secret in context
- Still better than nothing

**Option C: Use MCP for credential management**
- More complex setup
- May be overkill

### Test Priority: **CRITICAL** ⚠️

This is the foundation of the skill approach. Must test immediately.

---

## Skill Description Length Limit

### Issue

Claude.ai skills have a **200 character** description limit (not 1024 like Claude Code).

### Current Status

✅ **Fixed** - SKILL.md description is 137 characters

### What to Watch

If skill doesn't activate automatically:
- Description may not be specific enough
- May need to explicitly say "Use the Git Proxy skill"

---

## Skill Discovery and Activation

### Issue

Skills activate based on description matching. Claude must infer when to use it.

### Test Scenarios

Test if Claude auto-activates the skill for:

**Should activate:**
- "Clone the repository at https://github.com/user/repo.git"
- "Commit these changes"
- "Push to main branch"
- "Show me the git log"

**May not activate:**
- "Get the latest code" (too vague)
- "Update from GitHub" (doesn't mention git explicitly)

### Workaround

If auto-activation fails, be explicit:
```
Use the Git Proxy skill to clone the repository.
```

### Test Priority: **Medium**

---

## Python Dependencies in Skills

### Issue

Skill declares `dependencies: python>=3.7, requests>=2.31.0` but unclear if Claude.ai automatically installs them.

### What We Know

- Skills can declare dependencies in frontmatter
- Documentation doesn't specify installation behavior
- `git_client.py` imports `requests`

### What Needs Testing

1. Use skill without pre-installing requests
2. Check if it fails with import error
3. Verify requests is available

### Workaround If It Fails

**Option A: Remove dependency on requests**
- Rewrite `git_client.py` to use `urllib` (stdlib)
- More code, no external deps

**Option B: Document manual installation**
- Not ideal: defeats skill portability
- Users can't install packages in claude.ai web

### Test Priority: **High** ⚠️

---

## File Size Limits

### Issue

Skills have file size limits (undocumented what they are).

### Current Status

- `git_client.py`: ~8KB
- `SKILL.md`: ~4KB
- Total skill: ~4KB compressed

✅ Likely fine, but should monitor

### What to Watch

If skill upload fails:
- Try removing comments/docstrings
- Split into multiple smaller files

---

## Workspace Path Differences

### Issue

Default workspace in `git_client.py` is `/tmp/git-workspace` but server uses `~/git-proxy-workspace`.

### Current Status

✅ **Handled** - Client reads `GIT_WORKSPACE` from env (optional) or uses proxy's default workspace

### What to Watch

Path issues if:
- Claude tries to access files outside workspace
- Permissions different between client/server

---

## Tailscale Domain Allowlisting

### Issue

Each project must add the Tailscale domain to allowed list or all requests fail with 403.

### Current Status

✅ Documented in setup guide

### What to Watch

Common user error - forgetting this step

### Mitigation

- Clear error message in troubleshooting docs
- Consider adding health check to skill that gives friendly error

---

## Mac Sleep/Network Changes

### Issue

When Mac sleeps or changes networks, Tailscale Funnel and Flask server may need time to reconnect.

### Current Status

✅ Both auto-restart, but may have brief downtime

### What to Watch

- Requests timing out right after waking Mac
- Need to wait 5-10 seconds for reconnection

### Mitigation

Document in troubleshooting:
```
If you get connection errors right after waking your Mac,
wait 10 seconds and try again.
```

---

## Git Authentication for Private Repos

### Issue

Cloning private repos requires git credentials (SSH keys or tokens).

### Current Status

⚠️ **Not yet handled**

### Solutions

**Option A: SSH key on server**
- Set up SSH key on Mac
- Add to GitHub account
- Git automatically uses it

**Option B: Personal access token**
- Store in env var: `GITHUB_TOKEN`
- Use HTTPS URLs with token

### Test Priority: **Medium**

Will need this for private repos.

---

## Concurrent Operations

### Issue

Multiple Claude.ai projects could use proxy simultaneously.

### Current Status

✅ Server handles concurrent requests (Flask + subprocess)

### What to Watch

- Race conditions if multiple projects modify same repo
- Workspace isolation should prevent conflicts

### Mitigation

Each project should clone to unique directory:
```python
repo = client.clone(url, 'project-specific-name')
```

---

## Testing Checklist

### Phase 1: Critical (Test First)

- [ ] Environment variable access from `.env` in projects
- [ ] Python dependencies (requests) available in skill
- [ ] Skill activates automatically for git operations
- [ ] Health check works through skill

### Phase 2: Core Functionality

- [ ] Clone public repository
- [ ] Commit changes
- [ ] Push to remote
- [ ] Branch operations
- [ ] Log viewing

### Phase 3: Edge Cases

- [ ] Private repository access (with SSH/token)
- [ ] Multiple projects using proxy concurrently
- [ ] Mac sleep/wake reconnection
- [ ] Network change recovery
- [ ] Large repository cloning

### Phase 4: User Experience

- [ ] Skill activates without being explicitly called
- [ ] Error messages are clear and actionable
- [ ] Setup instructions are sufficient
- [ ] Troubleshooting guide covers common issues

---

## Recommended Testing Order

1. **Upload skill** to Claude.ai
2. **Test env var access** (critical dependency)
3. **Test basic health check** (verify connectivity)
4. **Test public repo clone** (core functionality)
5. **Test private repo** (if needed for your use case)
6. **Test auto-activation** (user experience)
7. **Test error scenarios** (verify troubleshooting docs)

---

## Known Limitations

### Won't Fix (By Design)

- **Requires Mac running**: Tailscale Funnel only works when Mac is on
- **macOS only**: LaunchAgent setup is Mac-specific
- **Single proxy server**: One Mac serves all projects (intentional)

### May Address Later

- **No GUI**: All server management via CLI
- **Basic logging**: Could add structured logging
- **No metrics**: Could add operation counting, timing
- **Manual domain allowlisting**: Could automate somehow

---

## Success Criteria

**Minimum viable:**
- [ ] Skill activates for git commands
- [ ] Can clone public repos
- [ ] Can commit and push
- [ ] Env vars work from project `.env`

**Fully functional:**
- [ ] All above +
- [ ] Works with private repos
- [ ] Auto-activates reliably
- [ ] Error messages clear
- [ ] Setup takes < 15 minutes

**Excellent:**
- [ ] All above +
- [ ] GitHub CLI (gh) support (Issue #1)
- [ ] Claude proposes changes via PRs
- [ ] Self-improving workflow demonstrated
