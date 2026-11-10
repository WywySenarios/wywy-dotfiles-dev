# Formatters

This repo uses [opencode formatters](https://opencode.ai/docs/formatters/) to format files after every edit. They are configured in `.opencode/opencode.jsonc` and run automatically on write.

The playbook installs the dependencies; do not install them by hand.

| Formatter      | Language                                                | Installed by                             |
| -------------- | ------------------------------------------------------- | ---------------------------------------- |
| `prettier`     | TypeScript, JavaScript, Markdown, JSON, YAML, CSS, HTML | `npm_globals` role (`3.9.10`)            |
| `shfmt`        | Shell scripts                                           | `packages` role                          |
| `ruff`         | Python                                                  | `python` role (`0.15.21`, via `uv tool`) |
| `gofmt`        | Go                                                      | `go` role                                |
| `rustfmt`      | Rust                                                    | `packages` role                          |
| `clang-format` | C, C++, headers                                         | `packages` role                          |
| `air`          | R                                                       | `air` role (`0.13.0`)                    |

`gofmt` ships with the Go toolchain. `clang-format` needs a `.clang-format` file in the project to activate; a minimal example:

```yaml
BasedOnStyle: LLVM
IndentWidth: 4
```

## Verify

Confirm a formatter is available:

```bash
prettier --version
shfmt --version
ruff --version
gofmt -h | head -n1
rustfmt --version
clang-format --version
air --version
```

OpenCode runs enabled formatters automatically after every file edit.
