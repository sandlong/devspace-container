# DevSpace Container

A one-command Docker wrapper for [Waishnav/DevSpace](https://github.com/Waishnav/devspace). It provides an isolated coding workspace with filesystem, code execution, and terminal tools for MCP clients such as ChatGPT.

The published image supports both `linux/amd64` and `linux/arm64`.

## Run

```bash
docker run --rm -p 7676:7676 \
  -v devspace-data:/home/devspace/.devspace \
  ghcr.io/sandlong/devspace-container:latest
```

On the first run, the container creates `config.json` and `auth.json` in the persistent `devspace-data` volume and prints a randomly generated owner password. Later runs preserve manual edits to those files.

To set the password and public HTTPS origin explicitly:

```bash
docker run --rm -p 7676:7676 \
  -v devspace-data:/home/devspace/.devspace \
  -e DEVSPACE_OAUTH_OWNER_TOKEN='replace-with-at-least-16-characters' \
  -e DEVSPACE_PUBLIC_BASE_URL='https://devspace.example.com' \
  ghcr.io/sandlong/devspace-container:latest
```

The MCP endpoint is `https://devspace.example.com/mcp` (or `http://localhost:7676/mcp` for local access).

## Workspace persistence

The default `/workspace` is ephemeral. Bind-mount a project when you want it persisted:

```bash
docker run --rm -p 7676:7676 \
  -v devspace-data:/home/devspace/.devspace \
  -v "$PWD:/workspace" \
  -e DEVSPACE_OAUTH_OWNER_TOKEN='replace-with-at-least-16-characters' \
  ghcr.io/sandlong/devspace-container:latest
```

Multiple folders can be mounted and allowed explicitly:

```bash
docker run --rm -p 7676:7676 \
  -v devspace-data:/home/devspace/.devspace \
  -v "$HOME/personal:/projects/personal" \
  -v "$HOME/work:/projects/work" \
  -e DEVSPACE_ALLOWED_ROOTS='/projects/personal,/projects/work' \
  -e DEVSPACE_OAUTH_OWNER_TOKEN='replace-with-at-least-16-characters' \
  ghcr.io/sandlong/devspace-container:latest
```

## Configuration

Environment variables override values in the persisted files. Important variables:

| Variable | Default | Purpose |
| --- | --- | --- |
| `HOST` | `0.0.0.0` | Bind address inside the container |
| `PORT` | `7676` | HTTP port |
| `DEVSPACE_ALLOWED_ROOTS` | `/workspace` | Comma-separated accessible roots |
| `DEVSPACE_PUBLIC_BASE_URL` | `http://localhost:7676` | Public origin, without `/mcp` |
| `DEVSPACE_OAUTH_OWNER_TOKEN` | generated once | Owner password; minimum 16 characters |
| `DEVSPACE_TOOL_MODE` | `full` | `minimal`, `full`, or experimental `codex` |
| `DEVSPACE_WIDGETS` | `changes` | `off`, `changes`, or `full` |

All DevSpace configuration, OAuth state, managed worktrees, skills, and agent profiles live under `/home/devspace/.devspace` and are covered by the named volume.

The image includes Bash, Git, curl, jq, ripgrep, fd, findutils, OpenSSH client, Python 3, tar, unzip, and other small shell essentials. It intentionally does not include authenticated service CLIs such as GitHub CLI.

## Local build

```bash
docker build -t devspace-container .
docker run --rm -p 7676:7676 -v devspace-data:/home/devspace/.devspace devspace-container
```

To run a diagnostic instead of the server:

```bash
docker run --rm -v devspace-data:/home/devspace/.devspace devspace-container devspace doctor
```
