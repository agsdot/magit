;; basic adjustments for magit
(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))
(add-to-list 'load-path "~/.magit/el-get/el-get")
(unless (require 'el-get nil 'noerror)
  (url-retrieve
   "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el"
   (lambda (s)
     (goto-char (point-max))
     (eval-print-last-sexp))))
(add-to-list 'el-get-recipe-path "~/.magit/extra-el-get-user-recipes")
(let ((el-get-sources
       '(
         color-theme-zenburn
         drag-stuff
         emacs-neotree
         evil
         evil-magit
         flx
         general
         git-gutter
         git-timemachine
         ido-vertical-mode
         magit
         magit-rockstar
         no-littering
         seoul256-theme
         smex
         use-package
         )))
    (el-get 'sync el-get-sources))
(menu-bar-mode -1)
(line-number-mode t)
(column-number-mode t)
(global-linum-mode t)
(setq magit-cache-directory "~/.magit/.cache/" )
(setq no-littering-etc-directory
      (expand-file-name "config/" magit-cache-directory))
(setq no-littering-var-directory
      (expand-file-name "data/" magit-cache-directory))
(use-package no-littering)
(setq-default show-trailing-whitespace t)
(setq whitespace-style (quote (spaces tabs newline space-mark tab-mark newline-mark)))
(setq whitespace-display-mappings
  '((space-mark 32 [183] [46])
    (tab-mark 9 [9655 9] [92 9])))
(require 'whitespace)
(use-package ido-vertical-mode
   :config
   (setq ido-enable-flex-matching t)
   (setq ido-everywhere t)
   (ido-mode 1)
   (ido-vertical-mode t))
(use-package flx-ido
   :config
   (flx-ido-mode 1)
   (setq flx-ido-threshhold 1000)
   (setq gc-cons-threshold 20000000))
(use-package smex)
(use-package general
  :config
  (general-define-key
    :states '(normal motion emacs)
    :prefix ","
    "nf" 'neotree-find
    "nt" 'neotree-toggle)
  (general-define-key
    :states '(normal motion emacs)
    :prefix "<SPC>"
    "qq"     'evil-quit
    "<down>" 'drag-stuff-down
    "<up>"   'drag-stuff-up))
(use-package drag-stuff
  :config
  (drag-stuff-global-mode t))
(use-package neotree
  :demand t
  :config
  (setq-default neo-show-hidden-files t)
  ;; from https://github.com/kaushalmodi/.emacs.d/blob/master/setup-files/setup-neotree.el
  (setq neo-theme 'nerd) ; 'classic, 'nerd, 'ascii, 'arrow
  (setq neo-vc-integration '(face char))
  ;; Patch to fix vc integration
  (defun neo-vc-for-node (node)
    (let* ((backend (vc-backend node))
           (vc-state (when backend (vc-state node backend))))
      ;; (message "%s %s %s" node backend vc-state)
      (cons (cdr (assoc vc-state neo-vc-state-char-alist))
            (cl-case vc-state
              (up-to-date       neo-vc-up-to-date-face)
              (edited           neo-vc-edited-face)
              (needs-update     neo-vc-needs-update-face)
              (needs-merge      neo-vc-needs-merge-face)
              (unlocked-changes neo-vc-unlocked-changes-face)
              (added            neo-vc-added-face)
              (removed          neo-vc-removed-face)
              (conflict         neo-vc-conflict-face)
              (missing          neo-vc-missing-face)
              (ignored          neo-vc-ignored-face)
              (unregistered     neo-vc-unregistered-face)
              (user             neo-vc-user-face)
              (t                neo-vc-default-face)))))
  ;; from https://github.com/kaushalmodi/.emacs.d/blob/master/setup-files/setup-neotree.el
  ;; from https://github.com/andrewmcveigh/emacs.d
  ;; get keybindings to work better in neotree with evil
  (defun neotree-copy-file ()
    (interactive)
    (let* ((current-path (neo-buffer--get-filename-current-line))
           (msg (format "Copy [%s] to: "
                        (neo-path--file-short-name current-path)))
           (to-path (read-file-name msg (file-name-directory current-path))))
      (dired-copy-file current-path to-path t))
    (neo-buffer--refresh t)))
(use-package evil
  :config
  (evil-mode 1)
  (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
  (define-key evil-visual-state-map (kbd "C-u") 'evil-scroll-up)
  (define-key evil-normal-state-map ";" 'evil-ex)
  (define-key evil-normal-state-map ":" 'smex)
  ;; for use in smex
  (defalias 'w 'evil-write)
  (defalias 'wq 'evil-save-and-close)
  (defalias 'wq! 'evil-save-and-close)
  (defalias 'q 'evil-quit)
  (defalias 'q! 'evil-quit)
  (defalias 'st 'magit-status)
  (define-key evil-motion-state-map "j" 'evil-next-visual-line)
  (define-key evil-motion-state-map "k" 'evil-previous-visual-line)
  ;; https://stackoverflow.com/questions/20882935/how-to-move-between-visual-lines-and-move-past-newline-in-evil-mode
  ;; Make horizontal movement cross lines
  (setq-default evil-cross-lines t)
  (define-key evil-normal-state-map (kbd "C-w ]") 'evil-window-rotate-downwards)
  (define-key evil-normal-state-map (kbd "C-w [") 'evil-window-rotate-upwards)
  (define-key evil-normal-state-map (kbd "C-h")   'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-j")   'evil-window-down)
  (define-key evil-normal-state-map (kbd "C-k")   'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-l")   'evil-window-right)
  (evil-ex-define-cmd "Q"  'evil-quit)
  (evil-ex-define-cmd "Qa" 'evil-quit-all)
  (evil-ex-define-cmd "QA" 'evil-quit-all)
  (define-minor-mode neotree-evil
    "Use NERDTree bindings on neotree."
    :lighter " NT"
    :keymap (progn
              (evil-make-overriding-map neotree-mode-map 'normal t)
              (evil-define-key 'normal neotree-mode-map
                "C" 'neotree-change-root
                "U" 'neotree-select-up-node
                "r" 'neotree-refresh
                "o" 'neotree-enter
                (kbd "<return>") 'neotree-enter
                "i" 'neotree-enter-horizontal-split
                "s" 'neotree-enter-vertical-split
                "n" 'evil-search-next
                "N" 'evil-search-previous
                "ma" 'neotree-create-node
                "mc" 'neotree-copy-file
                "md" 'neotree-delete-node
                "mm" 'neotree-rename-node
                "gg" 'evil-goto-first-line)
              neotree-mode-map)))
(use-package magit
  :config
  (magit-auto-revert-mode 0) ;; magit auto revert mode seemed to take some time on startup
  (use-package magit-rockstar)
  (use-package evil-magit
    :config
    (add-hook 'with-editor-mode-hook 'evil-insert-state)
    )
  (defadvice magit-status (around magit-fullscreen activate)
    (window-configuration-to-register :magit-fullscreen)
    ad-do-it
    (delete-other-windows))
  (defun magit-quit-session ()
    "Restores the previous window configuration and kills the magit buffer"
    (interactive)
    (kill-buffer)
    (jump-to-register :magit-fullscreen)))
(use-package git-gutter
  :diminish git-gutter-mode
  :config
  (global-git-gutter-mode 1))
(use-package git-timemachine)
(use-package seoul256-theme
  :init
  (setq seoul256-background 235)
  (load-theme 'seoul256 t))
(kill-buffer "*scratch*")
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(magit-status)
(delete-other-windows)
