;; init --- Justin Smestad's Emacs init file
;;; Commentary:

;;; Code:
(customize-set-variable 'gc-cons-threshold (* 10 1024 1024))

;; Default to UTF-8 early as this file uses Unicode symbols.
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq-default buffer-file-coding-system 'utf-8)

;; Get package repos configured
(require 'package)
(customize-set-variable
 'package-archives
 '(("melpa" . "https://melpa.org/packages/")
   ("melpa-stable" . "https://stable.melpa.org/packages/")
   ("gnu" . "https://elpa.gnu.org/packages/")
   ("org" . "https://orgmode.org/elpa/")))
(unless package--initialized
  (package-initialize))

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(customize-set-variable 'use-package-always-ensure t)
(eval-when-compile
  (require 'use-package))

;; Used to benchmark init timings
(use-package benchmark-init
  :disabled
  :config
  ;; To disable collection of benchmark data after init is done.
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

(use-package delight)
(use-package dash)

;; Ensure system has required packages and install if missing
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :custom
  (exec-path-from-shell-variables '("PATH" "GOPATH"))
  :config
  (exec-path-from-shell-initialize))
(use-package use-package-ensure-system-package)
(use-package system-packages
  :requires use-package-ensure-system-package)

;; Save data files consistently:
;; - `save-place-file'
;; - `undo-tree-history-directory-alist'
;; - `backup-directory-alist'
;; - etc.
(use-package no-littering)
(customize-set-variable
 'custom-file (no-littering-expand-var-file-name "custom.el"))

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


(customize-set-variable 'user-full-name "Justin Smestad")
(customize-set-variable 'user-mail-address "justin.smestad@gmail.com")


;;; Key Bindings
(use-package general
  ;; :custom
  ;; (general-default-prefix "SPC")
  ;; (general-default-non-normal-prefix "C-SPC")
  :config
  (general-create-definer space-leader-def
    :prefix "SPC"
    :non-normal-prefix "C-SPC")
  (general-evil-setup)
  (space-leader-def
    :states '(normal visual insert emacs)

    "SPC" '(counsel-M-x :which-key "M-x")
    ;; "TAB" '(switch-to-other-buffer :which-key "prev buffer")

    ;;; Help bindings
    "?" '(counsel-descbinds :which-key "Help")
    "h" '(:ignore t :which-key "Help")
    "h d f" '(counsel-describe-function :which-key "describe function")
    "h d m" '(describe-mode :which-key "describe modes")
    "h d v" '(counsel-describe-variable :which-key "describe variable")

    ;;; Buffers
    "b"   '(:ignore t :which-key "Buffers")
    "b b" '(ivy-switch-buffer :which-key "list buffers")
    "b n" '(next-buffer :which-key "next buffer")
    "b p" '(previous-buffer :which-key "prev buffer")
    "b d" '((lambda ()
              (interactive)
              (kill-buffer (current-buffer)))
            :which-key "close current buffer")

    ;;; Files
    "f"   '(:ignore t :which-key "Files")
    "f f" '(counsel-find-file :which-key "find file")
    "f t" '(neotree-toggle :which-key "toggle file tree")
    "f e d" '((lambda ()
                (interactive)
                (find-file-existing user-init-file))
              :which-key "open emacs configuration")

    ;;; Projects
    "p"   '(:ignore t :which-key "Projects")
    "p !" '(projectile-run-shell-command-in-root :which-key "run command")
    "p %" '(projectile-replace-regexp :which-key "replace regexp")
    ;; "p a" '(projectile-toggle-between-implementation-and-test :which-key "toggle test")
    "p I" '(projectile-invalidate-cache :which-key "clear cache")
    "p R" '(projectile-replace :which-key "replace")
    "p b" '(counsel-projectile-switch-to-buffer :which-key "switch to buffer")
    "p d" '(counsel-projectile-find-dir :which-key "find directory")
    "p f" '(counsel-projectile-find-file :which-key "open file")
    "p k" '(projectile-kill-buffers :which-key "kill buffers")
    "p p" '(counsel-projectile-switch-project :which-key "open project")
    "p r" '(projectile-recentf :which-key "recent files")
    "p t" '(neotree-projectile-action :which-key "project tree")

    ;; Does not seem to work
    ;; "p s" '(counsel-projectile-rg :which-key "search in project")

    ;;; Quit
    "q"   '(:ignore t :which-key "Quit")
    "q q" '(kill-emacs :which-key "quit")
    "q r" '(restart-emacs :which-key "restart")

    ;;; Search
    "s" '(:ignore t :which-key "Search")
    "s s" '(swiper :which-key "search buffer")
    "s S" '(lambda ()
             (interactive)
             (let ((input (if (region-active-p)
                              (buffer-substring-no-properties
                               (region-beginning) (region-end))
                            (thing-at-point 'symbol t))))
               (swiper input))
             :which-key "search buffer")

    ;;; Themes
    "t" '(:ignore t :which-key "Theme")
    "t s" '(counsel-load-theme :which-key "switch theme")

    ;;; Windows
    "w"   '(:ignore t :which-key "Windows")
    "w d" '(delete-window :which-key "close window")
    "w /" '((lambda ()
              (interactive)
              (split-window-horizontally)
              (other-window 1))
            :which-key "split vertical")
    "w -" '((lambda ()
              (interactive)
              (split-window-vertically)
              (other-window 1))
            :which-key "split horizontal")
    "w h" '(evil-window-left :which-key "window left")
    "w <left>" '(evil-window-left :which-key nil)
    "w j" '(evil-window-down :which-key "window down")
    "w <down>" '(evil-window-down :which-key nil)
    "w k" '(evil-window-up :which-key "window up")
    "w <up>" '(evil-window-up :which-key nil)
    "w l" '(evil-window-right :which-key "window right")
    "w <right>" '(evil-window-right :which-key nil)
    "w =" '(balance-windows :which-key "balance window split")))

;; Platform
;;
(use-package linux
  :disabled
  :load-path "vendor/"
  :ensure nil
  :if (eq system-type 'gnu/linux))

(use-package osx
  :load-path "vendor/"
  :if (eq system-type 'darwin))

(use-package windows
  :disabled
  :load-path "vendor/"
  :ensure nil
  :if (eq system-type 'windows-nt))

;; Auto-update packages.
;;
(use-package auto-package-update
  :load-path "vendor/"
  :config
  (auto-package-update-maybe)
  :custom
  (auto-package-update-interval 1)
  (auto-package-update-delete-old-versions t)
  (auto-package-update-hide-results t)
  (auto-package-update-prompt-before-update t)
  (apu--last-update-day-filename
   (no-littering-expand-var-file-name "auto-update-package-last-update-day")))

;; File settings
;;
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

;; Global Modes
;;
;;; ace-window (for better window switching)
(use-package ace-window
  :disabled)
;;; Enable which-key
(use-package which-key
  :delight
  :init (which-key-mode)
  :custom
  (which-key-sort-order 'which-key-key-order-alpha)
  (which-key-side-window-max-width 0.33)
  (which-key-idle-delay 0.05)
  (which-key-setup-side-window-right-bottom))

;;; File Tree
(use-package neotree
  :after all-the-icons
  :custom
  (neo-theme (if (display-graphic-p) 'icons 'arrow))
  (neo-window-width 25)
  (neo-create-file-auto-open t)
  (neo-modern-sidebar t)
  (neo-point-auto-indent t)
  :general
  (general-nmap neotree-mode-map

    "RET" 'neotree-enter
    "TAB" 'neotree-stretch-toggle
    "q" 'neotree-hide
    "|" 'neotree-enter-vertical-split
    "-" 'neotree-enter-horizontal-split
    "'" 'neotree-quick-look
    "c" 'neotree-create-node
    "C" 'neotree-copy-node
    "d" 'neotree-delete-node
    "gr" 'neotree-refresh
    "H" 'neotree-select-previous-sibling-node
    "j" 'neotree-next-line
    "J" 'neotree-select-down-node
    "k" 'neotree-previous-line
    "K" 'neotree-select-up-node
    "L" 'neotree-select-next-sibling-node
    "q" 'neotree-hide
    "o" 'neotree-enter
    "r" 'neotree-rename-node
    "R" 'neotree-change-root
    "I" 'neotree-hidden-file-toggle))

(use-package smex
  :init (smex-initialize))
;;; Ivy for completion
(use-package ivy
  :delight
  :init (ivy-mode)
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-count-format "(%d/%d) ")
  (ive-use-selectable-prompt t))
;;; Ado-ado
(use-package counsel
  :bind (("M-x" . counsel-M-x)))

(use-package counsel-projectile
  :requires (counsel projectile rg)
  :config (counsel-projectile-mode))

(use-package rg)

;; Search regex
(use-package swiper
  :bind (("M-s" . swiper)))

(use-package flycheck
  :custom
  (flycheck-rubocop-lint-only t)
  (flycheck-check-syntax-automatically '(mode-enabled save))
  (flycheck-disabled-checkers '(ruby-rubylint))
  :config (global-flycheck-mode))

(use-package flyspell
  :disabled ;; I don't like spell checking
  ;; Disable on Windows because `aspell' 0.6+ isn't available.
  :if (not (eq system-type 'windows-nt))
  :delight
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :custom
  (ispell-program-name "aspell")
  (ispell-extra-args '("--sug-mode=ultra")))

(use-package flyspell-correct-ivy
  :requires (flyspell ivy))

;;; Resize all buffers at once with C-M-= / C-M--
(use-package default-text-scale
  :disabled
  :init (default-text-scale-mode))
;;; Restart Emacs
(use-package restart-emacs
  :commands restart-emacs)
;;; TODO Shackle to keep pop-up windows under control
;; (use-package shackle)
;;; TODO Workspaces
;; (use-package persp-mode)
;;; TODO workgroups
;; (use-package workgroups)


(use-package js-editing
  :load-path "vendor/")

;; Development Modes

;;; ALL
;;;
;;; Projectile
(use-package projectile
  :requires ivy
  :delight '(:eval (concat " " (projectile-project-name)))
  :custom
  (projectile-indexing-method 'alien)
  (projectile-completion-system 'ivy)
  (projectile-enable-caching nil)
  (projectile-switch-project-action 'counsel-projectile-find-file)
  (projectile-sort-order 'recentf)
  :config
  (projectile-mode))
;;; Magit
(use-package magit)
;; May not be needed:
;; :custom
;; (magit-commit-show-diff nil)
;; :hook (magit-status-sections . magit-insert-worktrees)
;; :config
;; (put 'magit-clean 'disabled nil))

;;; EShell
(use-package eshell
  :commands eshell
  :custom
  (eshell-history-size 10000)
  (eshell-hist-ignoredups t)
  (eshell-scroll-to-bottom-on-output 'this)
  (eshell-scroll-to-bottom-on-input 'all))

(use-package repl-toggle
  :disabled
  :custom
  (rtog/mode-repl-alist
   '((emacs-lisp-mode . ielm)
     (ruby-mode . inf-ruby)
     (js2-mode . nodejs-repl)
     (rjsx-mode . nodejs-repl)))
  :config
  (repl-toggle-mode))

;;; Company
;;; Auto-completion framework for most modes
(use-package company
  :custom
  (company-idle-delay 0.5)
  (company-tooltip-limit 10)
  (company-minimum-prefix-length 2)
  (company-tooltip-flip-when-above t)
  :hook
  (after-init . global-company-mode))
(use-package company-quickhelp
  :requires company
  :config (company-quickhelp-mode))
(use-package company-flx
  :requires company
  :config (company-flx-mode))
;;; direnv
(use-package direnv
  :ensure-system-package direnv)
;;; EditorConfig
;;; Read files to set coding style options according to current project
(use-package editorconfig
  :disabled
  :config (editorconfig-mode 1))

;; Ruby
(use-package js-ruby
  :load-path "vendor/")

;; HTML / CSS
(use-package js-web
  :load-path "/vendor")

;; Javascript
(use-package js-javascript
  :load-path "/vendor")

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

;; C (via irony-mode)
(use-package irony
  :hook (c-mode . irony-mode))
(use-package company-irony
  :requires irony
  :config (add-to-list 'company-backends 'company-irony))
(use-package flycheck-irony
  :requires irony
  :hook (flycheck-mode . flycheck-irony-setup))

;; Go
(use-package go-mode
  :mode (("\\.go$" . go-mode)))
(use-package go-eldoc
  :hook (go-mode . go-eldoc-setup))
(use-package company-go
  :requires (company go-mode)
  :config (add-to-list 'company-backends 'company-go))
(use-package go-projectile
  :requires (projectile go-mode))

;; Elixir
(use-package elixir-mode
  :commands elixir-mode
  :hook (elixir-mode . alchemist))
(use-package alchemist
  :commands alchemist-mode
  :requires elixir-mode)

;;; Markdown Mode
(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode))
  :config (progn
            (add-hook 'markdown-mode-hook 'visual-line-mode)
            (add-hook 'markdown-mode-hook (lambda () (flyspell-mode 1)))))

;;; Ember Mode
;;; JSON Formatter
(use-package json-mode
  :custom
  (js-indent-level 2)
  :mode (("\\.json$" . json-mode)
         ("\\.jshintrc$" . json-mode)))
;;; Dockerfile
(use-package dockerfile-mode
  :mode "Dockerfile.*\\'")
;;; YAML mode
(use-package yaml-mode
  :mode "\\.ya?ml\'")
;;; Git Attributes
(use-package gitattributes-mode
  :disabled
  :mode ("/\\.gitattributes\\'"
         "/info/attributes\\'"
         "/git/attributes\\'"))
(use-package gitconfig-mode
  :disabled
  :mode ("/\\.gitconfig\\'"
         "/\\.git/config\\'"
         "/modules/.*/config\\'"
         "/git/config\\'"
         "/\\.gitmodules\\'"
         "/etc/gitconfig\\'"))
(use-package gitignore-mode
  :disabled
  :mode ("/\\.gitignore\\'"
         "/info/exclude\\'"
         "/git/ignore\\'"))

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
;; TODO: do I want emmet mode?
(use-package emmet-mode
  :disabled
  :custom (emmet-move-cursor-between-quotes t)
  :config (add-hook 'css-mode-hook  'emmet-mode))

;; Appearance
(if (display-graphic-p)
    (progn
      (tool-bar-mode 0)
      (scroll-bar-mode 0)
      (horizontal-scroll-bar-mode 0)))

;;; Theme
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))

(use-package powerline
  :init (powerline-default-theme))

(use-package all-the-icons
  :if window-system)

(use-package doom-themes
  :init (load-theme 'doom-molokai t)
  :config
  (doom-themes-org-config))

;; Font
(set-face-attribute 'default nil
                    :family "Fira Mono"
                    :height 130
                    :weight 'normal
                    :width 'normal)
;;; Highlight TODOs
(use-package hl-todo
  :init (global-hl-todo-mode))
;;; Better scrolling
(use-package smooth-scroll
  :if (eq system-type 'gnu/linux);;(display-graphic-p)
  :delight
  :custom (smooth-scroll/vscroll-step-size 8)
  :init (progn
          (require 'smooth-scroll)
          (smooth-scroll-mode 1)))



(use-package display-line-numbers
  :ensure nil
  :if (version<= "26.0.50" emacs-version)
  :hook (prog-mode . display-line-numbers-mode))

;;; Fix Annoyances

(use-package uniquify
  :ensure nil
  :demand t
  :custom (uniquify-buffer-name-style 'forward))

(defalias 'yes-or-no-p 'y-or-n-p)

;; Use Github as the standard
;; ref http://hilton.org.uk/blog/source-code-line-length
(customize-set-variable 'fill-column 125)

(customize-set-variable 'byte-compile-warnings nil)
(customize-set-variable 'blink-matching-paran nil)
(customize-set-variable 'create-lockfiles nil)
(customize-set-variable 'cua-mode t)
(customize-set-variable 'desktop-save-mode nil)
(customize-set-variable 'indent-tabs-mode nil)
(customize-set-variable 'inhibit-startup-screen t)
(customize-set-variable 'initial-scratch-message nil)
(customize-set-variable 'load-prefer-newer t)
(customize-set-variable 'sentence-end-double-space nil)
(customize-set-variable 'visible-bell nil)
(customize-set-variable 'ring-bell-function (lambda ()
                                              (invert-face 'mode-line)
                                              (run-with-timer 0.1 nil 'invert-face 'mode-line)))

;;; provide init package
(provide 'init)

;;; init.el ends here
