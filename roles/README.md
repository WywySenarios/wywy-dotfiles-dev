# Roles

`playbooks/site.yaml` applies these roles in order. Apt and apt-repository tasks escalate individually; the play runs as the operator user.

| Role            | Owns                                                                            |
| --------------- | ------------------------------------------------------------------------------- |
| `artifact`      | Shared verified download, atomic install, and PATH link logic.                  |
| `local_bin`     | Safe `~/.local/bin` links for arbitrary targets.                                |
| `config_link`   | Safe absolute configuration symlinks with the `.bak` and foreign-symlink rules. |
| `docker_repo`   | Docker apt repository and signing key.                                          |
| `packages`      | apt packages and their `~/.local/bin` links.                                    |
| `docker_group`  | Docker group membership and service.                                            |
| `gh`            | GitHub CLI apt repository and package.                                          |
| `vscode`        | VS Code apt repository and package.                                             |
| `node`          | Pinned Node.js toolchain.                                                       |
| `go`            | Pinned Go toolchain.                                                            |
| `gitleaks`      | Pinned gitleaks binary.                                                         |
| `betterleaks`   | Pinned betterleaks build.                                                       |
| `kind`          | Pinned kind binary.                                                             |
| `air`           | Pinned air binary.                                                              |
| `vscode_config` | VS Code settings links and extensions.                                          |
| `python`        | pswd virtualenv and ruff.                                                       |
| `npm_globals`   | Pinned prettier and opencode-ai.                                                |
| `opencode`      | opencode config and plugin dependencies.                                        |
| `shell`         | bash entry links and machine-local bash overrides.                              |
| `git_config`    | Git configuration link.                                                         |

## Variables

Variable defaults are declared in each role's `defaults/main.yaml`.
