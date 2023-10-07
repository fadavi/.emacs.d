;;; init.el --- Emacs configuration -*- lexical-binding: t -*-
;; Copyright (c) 2023 - Mohamad Fadavi <fadavi.mohamad@gmail.com>

;;; Commentary:
;; Based on many awesome ideas that I adapted from other Emacs configurations
;; and also my own ideas.
;; Topics are separated by horizontal lines (---------------------------------).
;; OK it's an old-school and obsolete approach for organizing code, but still
;; works!

;;; Code:

;; -----------------------------------------------------------------------------
;; (very) basic configurations

;; tune garbage collector
(setq gc-cons-threshold (* 2 1024 1024)
      gc-cons-percentage 0.5)

;; (en)coding
(prefer-coding-system 'utf-8-unix)
(set-language-environment "UTF-8")
(setq iso-transl-char-map nil)

;; don't care about native-comp's async concerns!
(setq-default native-comp-async-report-warnings-errors nil)

;; eh well, I really don'y care about warnings at all
(defvar byte-compile-warnings nil)

;; don't load outdated byte code
(setq load-prefer-newer t)

;; c'mon we can handle bigger chunks!
(setq read-process-output-max (* 1024 1024))

;; disable default settings
(setq inhibit-default-init t)

;; keep init.el clean
(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

;; -----------------------------------------------------------------------------
;; `package' / `use-package' / `straight'

;; add melpa to the package archives
(package-initialize)
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;; straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; ensure `use-package' is installed
(when (fboundp 'straight-use-package)
  (straight-use-package 'use-package))

;; `use-package' default setup
;; (defvar use-package-always-pin "melpa")
;; (defvar use-package-always-ensure 't)
;;(defvar use-package-always-defer t)
(defvar straight-use-package-by-default t)

;; -----------------------------------------------------------------------------
;; utility functions / macros

(defun ensure-directory-exists (directory)
  "Create DIRECTORY if it does't exist."
  (when (not (file-directory-p directory))
    (make-directory directory t)))

(defun kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))

(defun my-zoom-in ()
  "Simulates zoom in by increasing tht font size."
  (interactive)
  (set-face-attribute 'default nil :height
                      (+ (face-attribute 'default :height) 10)))

(defun my-zoom-out ()
  "Simulates zoom out by increasing tht font size."
  (interactive)
  (set-face-attribute 'default nil :height
                      (- (face-attribute 'default :height) 10)))

(defun my-first-installed-font (&rest fonts)
  "Find the first installed font among FONTS."
  (if (find-font (font-spec :name (car fonts)))
      (car fonts)
    (apply #'my-first-installed-font (cdr fonts))))

(defun my-choose-font ()
  "Try to choose a suitable font(s)."
  (let* ((font-size 17)
         (font-name (my-first-installed-font
                     "IBM Plex Mono" ;; <-- Preferred font
                     "SF Mono" "Moncao" "Intel One Mono" "Victor Mono"
                     "Intel One Mono" "JetBrains Mono" "Fira Code" "Ubuntu Mono"
                     "Iosevka" "Consolas" "Menlo" "Inconsolata"
                     "Source Code Pro" "Fira Mono" "Andale Mono" "Hack"
                     "DejaVu Sans Mono" "Roboto Mono" "Noto Mono"
                     "Droid Sans Mono" "Terminus" "Courier New" "Courier")))
    (when font-name
      (set-frame-font (format "%s %d" font-name font-size))
      (set-face-font 'default (font-spec :family font-name :size font-size)))))

(defun my-may-delete-trailing-whitespace ()
  "Clean whitespaces if current mode does not need them."
  (unless (or (derived-mode-p 'markdown-mode)
              (derived-mode-p 'org-mode))
    (delete-trailing-whitespace)))

(defun my-customize-display-table ()
  "Customize display table characters."
  (let ((tbl (or buffer-display-table
                 standard-display-table)))
    ;; all valid slots:
    ;; truncation, wrap, escape, control, selective-display, vertical-border
    (ignore-errors (set-display-table-slot tbl 'vertical-border ?┃))
    (ignore-errors (set-display-table-slot tbl 'truncation ?↔))
    (ignore-errors (set-display-table-slot tbl 'wrap ?↲))
    (set-window-display-table (selected-window) tbl)))

(defun my-ensure-ts-grammar-installed (lang)
  "Install tree-sitter grammar for LANG if it's not installed."
  (unless (treesit-language-available-p lang)
    (treesit-install-language-grammar lang)))

(defun my-treesit-available-p ()
  "Check if tree-sitter is supported."
  (and (fboundp #'treesit-available-p) (treesit-available-p)))

;; -----------------------------------------------------------------------------
;; now basic configurations

;; check minimum (recommended) requirements
(when (version< emacs-version "28")
  (warn "This configuration recommends to install v28 or later"))
(unless (my-treesit-available-p)
  (warn "This Emacs is not compiled with tree-sitter support."))

;; I'd rather a simple greeting :D
(setq-default inhibit-splash-screen t
              inhibit-startup-message t
              initial-scratch-message ";; Happy Hacking C[_]")

;; please simply be quiet!
;;(put 'inhibit-startup-echo-area-message 'saved-value t)
;;(setq inhibit-startup-echo-area-message (user-login-name))

;; hey emacs, please do not resize yourself!
(setq frame-inhibit-implied-resize t)

;; Save where we were editing
(save-place-mode t)

;; parens...
(electric-pair-mode t)

;; Show the column number
(column-number-mode t)

;; indicate empty lines
(setq-default indicate-empty-lines t)

;; thicker window divider
(setq window-divider-default-right-width 4)
(window-divider-mode t)

;; trust all themes!
(setq-default custom-safe-themes t)

;; moveBetweenWords
(global-subword-mode t)

;; show a ruler
(setq-default display-fill-column-indicator-column 80)
(global-display-fill-column-indicator-mode t)

;; wanna see docs in minibuffer
(global-eldoc-mode t)

;; y/n instead of yes/no
(fset 'yes-or-no-p 'y-or-n-p)

;; setup font
(when (display-graphic-p)
  (my-choose-font))

;; highlight current nline
;;(global-hl-line-mode t)

;; smooth(ish) scroll
(setq-default scroll-margin 8
              scroll-step 1
              scroll-conservatively 10000
              scroll-preserve-screen-position 1)

;; Disable UI "features"...
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (and (fboundp 'menu-bar-mode)
           (not (eq window-system 'ns)))
  (menu-bar-mode -1))

(when (eq system-type 'darwin)
  ;; customize frame look and feel on macOS
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  (when (memq window-system '(mac ns))
    (add-to-list 'default-frame-alist '(ns-appearance . dark)) ; nil: dark text
    (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))

  ;; no icon
  (setq ns-use-proxy-icon nil)

  ;; no title
  (setq frame-title-format nil)

  ;; use spotlight on macOS
  (defvar locate-command "mdfind"))

;; be quiet :)
;;(setq-default visible-bell t)

;; auto-refresh the buffers
(global-auto-revert-mode t)

;; Display line numbers
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(setq-default display-line-numbers-width-start t)

;; clean whitespaces on save
(add-hook 'before-save-hook #'my-may-delete-trailing-whitespace)

;; better window divider
(unless (display-graphic-p)
  (add-hook 'window-configuration-change-hook #'my-customize-display-table)
  (my-customize-display-table))

;; zoom in/out
(define-key global-map (kbd "C-1") #'my-zoom-in)
(define-key global-map (kbd "C-0") #'my-zoom-out)

;; mouse in terminal
(unless (display-graphic-p)
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line)
  (xterm-mouse-mode t))

;; Use TAB for both indentation and completion
(setq tab-always-indent 'complete)

;; collect backups / autosaves somewhere
(setq backup-by-copying t
      delete-old-versions t
      version-control t
      kept-new-versions 5
      kept-old-versions 2)

(let ((backup-dir (concat user-emacs-directory "/backups")))
  (ensure-directory-exists backup-dir)
  (setq backup-directory-alist `(("." . ,backup-dir)))
  (defvar tramp-backup-directory-alist `((".*" . ,backup-dir))))

(let ((auto-saves-dir (concat user-emacs-directory "/autosaves")))
  (ensure-directory-exists auto-saves-dir)
  (setq auto-save-file-name-transforms `((".*" ,auto-saves-dir t)))
  (setq auto-save-list-file-prefix (concat auto-saves-dir ".saves-"))
  (defvar tramp-auto-save-directory auto-saves-dir))

;; indentation
(setq-default indent-tabs-mode nil
              py-indent-offset 4
              python-indent-offset 4
              ruby-indent-level 2
              scala-indent:step 2
              scala-mode-indent:step 2
              css-indent-offset 2
              nxml-child-indent 2
              coffee-tab-width 2
              js-indent-level 2
              js2-basic-offset 2
              sws-tab-width 2
              web-mode-markup-indent-offset 2
              web-mode-html-offset 2
              c-basic-offset 2
              cperl-indent-level 2
              sgml-basic-offset 2
              typescript-idnent-level 2
              js-jsx-indent-level 2
              yaml-indent-offset 2
              elixir-smie-indent-basic 2
              lisp-body-indent 2
              cobol-tab-width 2
              tab-width 2
              standard-indent 2
              indent-bars-spacing-override 2
              sh-basic-offset 2
              sh-indentation 2)
(add-hook 'sh-mode-hook
          #'(lambda ()
              (defvar sh-basic-offset 2)
              (defvar sh-indentation 2)))

;; -----------------------------------------------------------------------------
;; from now on, everything should be configured in a `use-package' block

(use-package bind-key
  :straight t
  :demand t)

(use-package flyspell
  :straight t
  :commands (flyspell-mode flyspell-correct-word-before-point)
  :bind ("C-c s" . flyspell-correct-word-before-point)
  :config (flyspell-mode t))

(use-package paren
  :straight nil
  :custom (blink-matching-paren t)
  :custom-face (show-paren-match ((t (:bold t))))
  :init (show-paren-mode t))

(use-package magit
  :straight t
  :bind (("C-x g" . magit)))

(use-package which-key
  :straight t
  :commands which-key-mode
  :init (which-key-mode t))

(use-package editorconfig
  :straight t
  :commands editorconfig-mode
  :config (editorconfig-mode t))

(use-package xclip
  :straight t
  :unless (display-graphic-p)
  :commands xclip-mode
  :init (xclip-mode t))

(use-package git-gutter
  :straight t
  :hook (prog-mode . git-gutter-mode)
  :custom ((git-gutter:modified-sign " ")
           (git-gutter:deleted-sign " ")
           (git-gutter:added-sign " ")
           (git-gutter:visual-line t)))

(use-package dashboard
  :straight t
  :custom ((dashboard-center-content t)
           (dashboard-startup-banner 2))
  :init (dashboard-setup-startup-hook))

(use-package mode-line-bell
  :straight t
  :commands mode-line-bell-mode
  :init (mode-line-bell-mode t))

(use-package telephone-line
  :straight t
  :commands telephone-line-mode
  :init (telephone-line-mode t))

(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package mic-paren
  :straight t
  :custom (paren-highlight-offscreen t)
  :commands paren-activate
  :init (paren-activate))

(use-package vertico
  :straight t
  :custom (vertico-cycle t)
  :commands (vertico-mode vertico-reverse-mode)
  :init
  (vertico-mode t)
  (vertico-reverse-mode t))

(use-package consult
  :straight t
  :bind (("C-c M-x" . consult-mode-command)
	       ("C-c h" . consult-history)
	       ("C-c k" . consult-kmacro)
	       ("C-c m" . consult-man)
	       ("C-c i" . consult-info)
	       ([remap Info-search] . consult-info)
	       ("C-x M-:" . consult-complex-command)
	       ("C-x b" . consult-buffer)
	       ("C-x 4 b" . consult-buffer-other-window)
	       ("C-x 5 b" . consult-buffer-other-frame)
	       ("C-x r b" . consult-bookmark)
	       ("C-x p b" . consult-project-buffer)
	       ("M-#" . consult-register-load)
	       ("M-'" . consult-register-store)
	       ("C-M-#" . consult-register)
	       ("M-y" . consult-yank-pop)
	       ("M-g e" . consult-compile-error)
	       ("M-g f" . consult-flymake)
	       ("M-g g" . consult-goto-line)
	       ("M-g M-g" . consult-goto-line)
	       ("M-g o" . consult-outline)
	       ("M-g m" . consult-mark)
	       ("M-g k" . consult-global-mark)
	       ("M-g i" . consult-imenu)
	       ("M-g I" . consult-imenu-multi)
	       ("M-s d" . consult-find)
	       ("M-s D" . consult-locate)
	       ("M-s g" . consult-grep)
	       ("M-s G" . consult-git-grep)
	       ("M-s r" . consult-ripgrep)
	       ("M-s l" . consult-line)
	       ("M-s L" . consult-line-multi)
	       ("M-s k" . consult-keep-lines)
	       ("M-s u" . consult-focus-lines)
	       ("M-s e" . consult-isearch-history)
	       :map isearch-mode-map
	       ("M-e" . consult-isearch-history)
	       ("M-s e" . consult-isearch-history)
	       ("M-s l" . consult-line)
	       ("M-s L" . consult-line-multi)
	       :map minibuffer-local-map
	       ("M-s" . consult-history)
	       ("M-r" . consult-history))
  :custom ((register-preview-delay 0.5)
           (register-preview-function #'consult-register-format)
           (xref-show-xrefs-function #'consult-xref)
           (xref-show-definitions-function #'consult-xref))
  :commands consult-register-window
  :init (advice-add #'register-preview :override #'consult-register-window))

(use-package savehist
  :straight t
  :commands savehist-mode
  :init (savehist-mode t))

(use-package marginalia
  :straight t
  :after vertico
  :custom (marginalia-annotators '(marginalia-annotators-heavy
                                   marginalia-annotators-light
                                   nil))
  :commands marginalia-mode
  :init (marginalia-mode t))

(use-package lsp-mode
  :straight t
  :custom ((lsp-keymap-prefix "C-c l")
           (lsp-enable-snippet nil))
  :commands lsp
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (typescript-mode . lsp)
         (typescript-ts-mode . lsp)
         (js-json-mode . lsp)
         (js-ts-mode . lsp)
         (python-mode . lsp)))

(use-package yafolding
  :straight t
  :commands yafolding-mode
  :hook (js-json-mode . yafolding-mode)
  :bind (:map yafolding-mode-map
              ("C-c RET" . yafolding-toggle-element)))

(use-package flycheck
  :straight t
  :hook ((prog-mode . flycheck-mode))
  :custom-face (flycheck-error ((t (:foreground "indianred3" :italic t)))))

(use-package modern-fringes
  :straight t
  :commands modern-fringes-mode
  :init (modern-fringes-mode))

(use-package indent-bars
  :straight (indent-bars :type git :host github :repo "jdtsmith/indent-bars")
  :custom
  ((indent-bars-no-stipple-char ?╎) ;; ┊
   (indent-bars-prefer-character t)
   (indent-bars-treesit-support t)
   (indent-bars-no-descend-string t)
   (indent-bars-color '(highlight :face-bg t :blend .2))
   (indent-bars-color-by-depth '(:regexp "outline-\\([0-9]+\\)" :blend 1))
   ;;(indent-bars-treesit-ignore-blank-lines-types '("module"))
   ;;(indent-bars-treesit-wrap
   ;; '((python argument_list parameters list list_comprehension dictionary
   ;;           dictionary_comprehension parenthesized_expression subscript)))
   )
  :hook (prog-mode . indent-bars-mode))

(use-package modus-themes
  :disabled
  :init
  (setq-default modus-themes-italic-constructs t
               modus-themes-bold-constructs nil
               modus-themes-subtle-line-numbers nil
               modus-themes-intense-mouseovers t
               modus-themes-mode-line '(accented)
               modus-themes-syntax '(green-strings all-syntax))
  (load-theme 'modus-vivendi t))

(use-package kaolin-themes
  :straight t
  :init
  (setq-default kaolin-themes-italic-comments t
                kaolin-themes-modeline-padded t
                kaolin-themes-distinct-parentheseos t
                kaolin-themes-distinct-fringe t
                kaolin-theme-linum-hl-line-style t)
  ;; galaxy, shiva, dark, ocean
  (load-theme 'kaolin-shiva t))

(use-package vterm
  :straight t)

(use-package projectile
  :straight t
  :commands projectile-mode
  :init (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))

;; Install documentations using `devdocs-install'
(use-package devdocs
  :straight t
  :bind ("C-h D" . devdocs-lookup))

;; Run the current buffer using `quickrun'.
(use-package quickrun
  :straight t)

(use-package beacon
  :straight t
  :commands beacon-mode
  :init (beacon-mode t))

(use-package key-quiz
  :straight t)

(use-package exec-path-from-shell
  :straight t
  :commands exec-path-from-shell-initialize
  :init
  ;;(setq exec-path-from-shell-arguments nil)
  (exec-path-from-shell-initialize))

(use-package mini-frame
  :straight t
  :custom ((mini-frame-color-shift-step 10)
           (mini-frame-show-parameters '((top . 10)
                                         (width . 0.7)
                                         (left . 0.5))))
  :commands mini-frame-mode
  :init (mini-frame-mode t))

(use-package treesit
  :hook
  ((yaml-mode . yaml-ts-mode)
   (bash-mode . bash-ts-mode)
   (javascript-mode . js-ts-mode)
   (js-mode . js-ts-mode)
   (js2-mode . js-ts-mode)
   (typescript-mode . typescript-ts-mode)
   (json-mode . json-ts-mode)
   (css-mode . css-ts-mode)
   (python-mode . python-ts-mode))

  :mode
  (("\\.ts\\'" . typescript-ts-mode)
   ("\\.tsx\\'" . tsx-ts-mode)
   ("\\.jsx?\\'" . js-ts-mode)
   ("\\.yml\\'" . yaml-ts-mode)
   ("Dockerfile.*\\'" . dockerfile-ts-mode))

  :init
  (defvar treesit-language-source-alist
    '((bash "https://github.com/tree-sitter/tree-sitter-bash")
      (cmake "https://github.com/uyha/tree-sitter-cmake")
      (css "https://github.com/tree-sitter/tree-sitter-css")
      (elisp "https://github.com/Wilfred/tree-sitter-elisp")
      (go "https://github.com/tree-sitter/tree-sitter-go")
      (html "https://github.com/tree-sitter/tree-sitter-html")
      (javascript "https://github.com/tree-sitter/tree-sitter-javascript"
                  "master" "src")
      (json "https://github.com/tree-sitter/tree-sitter-json")
      (make "https://github.com/alemuller/tree-sitter-make")
      (markdown "https://github.com/ikatyang/tree-sitter-markdown")
      (python "https://github.com/tree-sitter/tree-sitter-python")
      (toml "https://github.com/tree-sitter/tree-sitter-toml")
      (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
           "master" "tsx/src")
      (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                  "master" "typescript/src")
      (yaml "https://github.com/ikatyang/tree-sitter-yaml")
      (c "https://github.com/tree-sitter/tree-sitter-c")
      (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
      (clojure "https://github.com/sogaiu/tree-sitter-clojure")
      (php "https://github.com/tree-sitter/tree-sitter-php")
      (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")))

  (mapc #'my-ensure-ts-grammar-installed
        (mapcar #'car treesit-language-source-alist)))

;; -----------------------------------------------------------------------------
;; TODO list:
;; - avy
;; - corfu & cape
;; - embark
;; - dumb-jump (not sure. is it deprecated?)
;; - yasnippets
;; - smartparens (not sure)
;; - ace-window (not sure)
;; - winner-mode (not sure)

;;; ----------------------------------------------------------------------------
;;; init.el ends here.
