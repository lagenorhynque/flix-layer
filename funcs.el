;;; funcs.el --- Flix layer functions -*- lexical-binding: t -*-

;; Copyright (C) 2026 lagénorhynque

;; Author: lagénorhynque <ignorantia.juris.non.excusa@gmail.com>
;; URL: https://github.com/lagenorhynque/flix-layer
;; License: GPL-3.0-or-later

;;; Commentary:

;; Glue functions bridging flix-mode's public API to lsp-mode and the
;; Spacemacs key-binding system.

;;; Code:

(defun flix//compiler-command ()
  "Return the Flix compiler invocation as a list of strings.
Delegates to flix-mode, which downloads the jar on demand and resolves
its version from flix.toml.  The result looks like
\(\"java\" \"-jar\" <versioned-jar> \"lsp\")."
  (flix-mode-ensure)
  (flix-mode-server-path nil))

(defun flix/lsp-command (&rest _)
  "Return the command that launches the Flix LSP server.
Suitable as the COMMAND argument of `lsp-stdio-connection'."
  (flix//compiler-command))

(defun flix//run-subcommand (subcommand)
  "Run the Flix CLI SUBCOMMAND (e.g. \"run\", \"test\") for the current project.
Reuse the jar resolved by flix-mode and run from the project root."
  (let* ((default-directory (project-root (project-current)))
         ;; Replace the trailing "lsp" of the compiler command with SUBCOMMAND.
         (command (append (butlast (flix//compiler-command))
                          (list subcommand))))
    (compile (mapconcat #'shell-quote-argument command " "))))

(defun flix/run ()
  "Run `flix run' for the current project."
  (interactive)
  (flix//run-subcommand "run"))

(defun flix/test ()
  "Run `flix test' for the current project."
  (interactive)
  (flix//run-subcommand "test"))
