# Claude Git Bridge - Technical Reference

## Project Purpose
Git bundle proxy enabling Claude.ai to clone repositories into its own environment via temporary operations on your Mac.

## Architecture
- **Server**: `server/proxy_server.py` - Flask app, bundle operations, temporary storage only
- **Client**: `skill-package/git-proxy/git_client.py` - Python client in Claude.ai skill
- **Auth**: Token-based via `X-Auth-Key` header
- **Storage**: Temporary directories only (auto-cleanup)

## Key Files

### Server (`server/proxy_server.py`)
- Endpoints: `/health`, `/git/fetch-bundle`, `/git/push-bundle`
- Security: Validates auth, uses temp directories with auto-cleanup
- Logging: Python logger (no persistent log files)
- Config: Env vars `PROXY_SECRET_KEY`, `PORT`, `DEBUG`

### Client (`skill-package/git-proxy/git_client.py`)
- `GitProxyClient` class with methods: `health_check()`, `fetch_bundle()`, `push_bundle()`
- Config: Env vars `GIT_PROXY_URL`, `GIT_PROXY_KEY`
- Handles bundle download/upload, PR creation

### Configuration (`.env`)
```
PROXY_SECRET_KEY=<secret>      # Required: auth token
PORT=8443                      # Optional: server port
DEBUG=false                    # Optional: debug mode
```

**Client .env** (in Claude.ai project):
```
GIT_PROXY_URL=https://your-machine.tail-id.ts.net
GIT_PROXY_KEY=<matches PROXY_SECRET_KEY>
```

## Workflow

### Fetch Bundle (Clone into Claude's environment)
```python
from git_client import GitProxyClient
import subprocess

client = GitProxyClient()

# 1. Fetch bundle from proxy
client.fetch_bundle('https://github.com/user/repo.git', 'repo.bundle')

# 2. Clone in Claude's environment
subprocess.run(['git', 'clone', 'repo.bundle', 'repo/'])
subprocess.run(['git', 'remote', 'set-url', 'origin', 'https://github.com/user/repo.git'], cwd='repo/')
```

**On proxy server:**
- Clones repo to temporary directory
- Creates git bundle
- Returns bundle file
- Deletes temporary directory automatically

### Push Bundle (Push changes from Claude)
```python
# After editing files and committing in Claude's environment
subprocess.run(['git', 'checkout', '-b', 'feature/improvements'], cwd='repo/')
subprocess.run(['git', 'bundle', 'create', 'changes.bundle', 'main..HEAD'], cwd='repo/')

# Push bundle through proxy
result = client.push_bundle(
    'changes.bundle',
    'https://github.com/user/repo.git',
    'feature/improvements',
    create_pr=True,
    pr_title='Improvements from Claude'
)
print(result['pr_url'])
```

**On proxy server:**
- Clones repo to temporary directory
- Applies bundle (fetches branch)
- Pushes branch to GitHub
- Creates PR via gh CLI (if requested)
- Deletes temporary directory automatically

## Security Model
- Auth token required (401 if missing/invalid)
- All operations in temporary directories
- No persistent storage on proxy server
- Automatic cleanup after each operation
- Timeout: 300s for clone/bundle, 60s for other operations
- Logging via Python logger only

## Server Lifecycle
1. Request arrives with auth key
2. Temporary directory created
3. Git operations execute
4. Response returned
5. Temporary directory automatically deleted
6. No files persist on disk

## Dependencies
- Flask (server)
- requests (client)
- Python 3.7+
- git installed on server machine
- gh CLI (optional, for PR creation)

## Deployment
**Tailscale Funnel** (Recommended): Free stable URLs, auto-start on boot
- URL: `https://<machine>.<tailnet>.ts.net:8443`
- Setup: `tailscale funnel --bg 8443`
- Auto-restarts: On reboot, WiFi change, Tailscale restart
- LaunchAgent: Auto-starts Flask server on login

## ToS Compliance
Compliant with Anthropic Usage Policy - equivalent to VPN/ngrok/SSH tunneling for legitimate development.
