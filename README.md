# Spacemacs Flix layer

A [Spacemacs](https://www.spacemacs.org/) layer for the
[Flix](https://flix.dev/) programming language.

It wires up [`flix-mode`](https://codeberg.org/mdiin/flix-mode) as the major
mode and drives the official Flix compiler as an LSP server, giving you the
same core language features available in the official
[VS Code](https://github.com/flix/vscode-flix) and
[Neovim](https://github.com/flix/nvim) clients — completion, type/effect
hovers, go to definition, find references, rename, inlay hints, code lenses,
and server-provided semantic highlighting — inside the Spacemacs key-binding
system.

## Demo

https://github.com/user-attachments/assets/5b784e27-05b0-4210-b76d-0e211b8b0bb2

Semantic highlighting, the "Run" code lens on an entry point, and an LSP
rename propagating across the project.

## Features

- **LSP integration** via the official Flix compiler (jar), started through
  `flix-mode`'s public API.
- **Automatic compiler management**: `flix-mode` downloads the jar on demand
  and resolves its version from `flix.toml`.
- **Whole-project analysis**: the Flix LSP server loads every project file on
  initialize, so cross-file module resolution works out of the box.
- **Semantic highlighting** provided by the compiler.
- **Run / test** commands that invoke the Flix CLI from the project root.
- **REPL** integration: start a project-scoped Flix REPL, and run entry points
  directly from the "Run" code lens. The REPL buffer has minimal standalone
  syntax highlighting (keywords, types, comments, strings) and `C-j` / `C-k`
  history navigation.

## Requirements

- Spacemacs with the `lsp` layer enabled.
- **Java 21+** available on your `PATH` (the Flix compiler runs on the JVM).
- A Flix project with a `flix.toml` in its root.

## Installation

Clone this repository into your private layers directory:

```sh
git clone https://github.com/lagenorhynque/flix-layer.git \
  ~/.emacs.d/private/flix
```

Then enable the layer in your `.spacemacs`:

```elisp
dotspacemacs-configuration-layers
'(;; ...
  lsp
  flix)
```

Restart Spacemacs (or reload the configuration with `SPC f e R`). The first
time you open a `.flix` file, `flix-mode` offers to download the Flix compiler
jar for the version declared in `flix.toml`.

## Key bindings

Under the major-mode leader (`SPC m` or `,`):

| Key     | Command          | Description                 |
|---------|------------------|-----------------------------|
| `, '`   | `flix/repl`      | Start / switch to the REPL  |
| `, c c` | `flix/run`       | Run `flix run`              |
| `, s i` | `flix/repl`      | Start / switch to the REPL  |
| `, s q` | `flix/repl-quit` | Quit the REPL               |
| `, t a` | `flix/test`      | Run `flix test`             |

Inside the REPL buffer:

| Key   | Command               | Description                 |
|-------|-----------------------|-----------------------------|
| `C-j` | `comint-next-input`   | Next item in REPL history   |
| `C-k` | `comint-previous-input` | Previous item in REPL history |

Clicking the **Run** code lens above an entry point runs it in the REPL. All
other language features come from the `lsp` layer's standard bindings (e.g.
`g d` for go to definition, `K` for hover, `SPC m r r` for rename).

## Configuration

The layer is intentionally thin and adds no variables of its own; you
customize it through the packages it builds on.

- **Compiler / jar management** is handled by `flix-mode`. Its customize group
  `flix-mode` (browse it with `M-x customize-group RET flix-mode RET`) exposes:
    - `flix-mode-download-dir` — where jars are downloaded
    - `flix-mode-jar-name` — the jar file name
    - `flix-mode-releases-url` — where Flix releases are fetched from
    - `flix-mode-project-file` — the project file (`flix.toml` by default)
- **LSP behavior** (inlay hints, code lenses, semantic tokens, completion,
  and so on) is controlled by the standard `lsp-mode` variables. The layer
  enables `lsp-semantic-tokens-enable` in Flix buffers so the compiler's
  semantic highlighting is on by default; everything else uses your existing
  `lsp` layer configuration.
- **Key bindings** follow the Spacemacs conventions above and can be
  overridden the usual way, e.g. with `spacemacs/set-leader-keys-for-major-mode`
  in your `dotspacemacs/user-config`.

## How it works

The layer is deliberately thin; it delegates as much as possible to
`flix-mode` and `lsp-mode`.

- `flix-mode` owns the major mode, jar download, and version resolution. This
  layer calls its public API (`flix-mode-ensure`, `flix-mode-server-path`) to
  obtain the compiler command.
- `lsp-mode` receives an `lsp-stdio-connection` client that launches
  `java -jar <jar> lsp`.
- The Flix LSP server resolves the LSP `workspaceFolder` name as a *relative*
  path when it scans the project. Because `lsp-mode` sends the directory's
  short name rather than a full path, the layer sets the server process's
  working directory to the **parent** of the workspace root so that the scan
  resolves correctly. Without this, only the opened file is compiled and you
  get `Orphaned module` / `Undefined use` errors.
- The server does not implement `workspace/executeCommand`, so the "Run" code
  lens (`flix.runMain`) is handled on the client side: an action handler sends
  `:eval <symbol>()` to a project-scoped REPL, the same approach the official
  VS Code extension takes.
- `flix.toml` is registered as a Projectile project root marker.

## Known limitations

- Test code lenses are not shown: the Flix compiler (as of v0.75.1) only emits
  a "Run" lens for entry points, not for `@Test` functions, so there is nothing
  for this layer to wire up. Use `, c t` to run the whole test suite.
- `flix test` runs the entire suite; the compiler exposes no way to filter by
  test name from the CLI or REPL, so per-test execution is not available.
- Files created or deleted mid-session are not pushed to the server until the
  file is opened (or LSP is restarted), since there is no file-system watcher.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).
