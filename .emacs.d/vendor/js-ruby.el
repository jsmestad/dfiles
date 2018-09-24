;;; js-ruby.el --- Part of my Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(use-package ruby-mode
  :ensure nil
  :ensure-system-package
  ((ruby-lint   . "gem install ruby-lint")
   (ripper-tags . "gem install ripper-tags")
   (pry . "gem install pry"))
  :hook (ruby-mode . flycheck-mode)
  :custom
  (ruby-insert-encoding-magic-comment nil)
  (ruby-align-to-stmt-keywords '(if while unless until begin case for def))
  :general
  (space-leader-def
    :keymaps 'ruby-mode-map
    "m" '(:ignore t :which-key "Ruby")
    "m t" '(:ignore t :which-key "Tests")))

(use-package inf-ruby
  :custom
  (inf-ruby-console-environment "development")
  :hook
  (after-init . inf-ruby-switch-setup))

(use-package company-inf-ruby
  :after inf-ruby
  :config
  (add-to-list 'company-backends 'company-inf-ruby))

;; Not available yet on MELPA
;; (use-package lsp-ruby
;;   :requires lsp-mode
;;   :hook (ruby-mode . lsp-ruby-enable))

;; (use-package robe
;;   :disabled
;;   :hook (ruby-mode . robe-mode)
;;   :config (add-to-list 'company-backends 'company-robe))

(use-package rspec-mode
  :hook (ruby-mode . rspec-mode)
  :custom
  (compilation-scroll-output 'first-error)
  (rspec-autosave-buffer t)
  :config
  (add-hook 'rspec-compilation-mode-hook 'inf-ruby-auto-enter nil t)
  ;; (add-hook 'rspec-compilation-mode-hook
  ;;           (lambda ()
  ;;             (make-local-variable 'compilation-scroll-output)
  ;;             (setq compilation-scroll-output 'first-error)))
  :general
  (space-leader-def ruby-mode-map
    "m t a" '(rspec-verify-all :which-key "run all tests")
    "m t b" '(rspec-verify :which-key "run tests in buffer")
    "m t e" '(rspec-toggle-example-pendingness :which-key "toggle test pending")
    "m t t" '(rspec-verify-single :which-key "run focus test")
    "m t l" '(rspec-run-last-failed :which-key "rerun failed tests")
    "m t r" '(rspec-rerun :which-key "rerun last tests")))

(use-package rubocop
  :ensure-system-package
  (rubocop . "gem install rubocop")
  :hook (ruby-mode . rubocop-mode))

(use-package rbenv
  :hook (ruby-mode . global-rbenv-mode))

(use-package yard-mode
  :hook (ruby-mode . yard-mode))

(use-package ruby-hash-syntax
  :requires ruby-mode
  :general
  (space-leader-def ruby-mode-map
    "m f h" '(ruby-hash-syntax-toggle :which-key "toggle hash syntax")))

(use-package projectile-rails
  :requires projectile
  :hook (projectile-mode . projectile-rails-on))

(provide 'js-ruby)

;;; js-ruby.el ends here
