;;; js-builtin.el --- Part of my Emacs configuration

;;; Commentary:
;;; This file contains changes to built-in Emacs packages. Things like
;;; dired, files, etc. Ignore the "use-package" stuff.

;;; Code:

;; Handle very large CSV files
(use-package vlf
  :hook csv-mode)

(use-package files
  :ensure nil
  :demand t
  :custom
  (backup-by-copying t)
  (require-final-newline t)
  (delete-old-versions t)
  (version-control t)
  (backup-directory-alist
   `((".*" . ,(no-littering-expand-var-file-name "backup/"))))
  (auto-save-file-name-transforms
   `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  (large-file-warning-threshold (* 20 1000 1000) "20 megabytes."))

;; Version control
(use-package vc-hooks
  :ensure nil
  :demand t
  :custom (vc-follow-symlinks t))


(use-package dired
  :ensure nil
  :demand t
  :commands (dired)
  :custom
  (dired-dwim-target t "Enable side-by-side `dired` buffer targets.")
  (dired-recursive-copies 'always "Better recursion in `dired`.")
  (dired-recursive-deletes 'top)
  (delete-by-moving-to-trash t)
  (dired-use-ls-dired nil))

;; Line Numbers
(use-package display-line-numbers
  :ensure nil
  :if (> emacs-major-version 25)
  :hook (prog-mode . display-line-numbers-mode))

;; Fix Annoyances
(use-package uniquify
  :ensure nil
  :demand t
  :custom (uniquify-buffer-name-style 'forward))

;; Shell
(use-package sh-mode
  :ensure nil
  :mode
  (("\\.zshrc" . sh-mode)
   ("bashrc$" . sh-mode)
   ("bash_profile$" . sh-mode)
   ("bash_aliases$" . sh-mode)
   ("bash_local$" . sh-mode)
   ("bash_completion$" . sh-mode)))

;; Better scrolling
(use-package pixel-scroll
  :disabled
  :ensure nil
  :if (> emacs-major-version 25)
  :hook (after-init . pixel-scroll-mode))


(use-package recentf
  :ensure nil
  :requires no-littering
  :custom
  (recentf-auto-cleanup 200)
  (recentf-max-saved-items 1000)
  (recentf-auto-cleanup 'never)
  (recentf-auto-save-timer (run-with-idle-timer 600 t 'recentf-save-list))
  :config
  (add-to-list 'recentf-exclude "COMMIT_EDITMSG\\'")
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory))

(provide 'js-builtin)

;;; js-builtin.el ends here