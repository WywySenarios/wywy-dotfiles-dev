# Contributing

## Development setup

Install the hooks once per clone. This requires `pre-commit`:

```bash
pre-commit install
```

## Testing

All suites are under `scripts/tests/**`. Make sure they all pass before committing.

| Suite                             | Purpose                                                      |
| --------------------------------- | ------------------------------------------------------------ |
| `scripts/tests/shell.sh`          | Shell syntax and executable bits.                            |
| `scripts/tests/ansible/lint.sh`   | `ansible-lint` production profile.                           |
| `scripts/tests/ansible/syntax.sh` | `ansible-playbook --syntax-check`.                           |
| `scripts/tests/e2e.sh`            | Apply on the local host, then verify. Changes machine state. |

## Code Conventions

Please read the dotfiles conventions for Wywy repos inside Wywy-Docs.

## A Final Warning

Do not commit with `--no-verify`.
