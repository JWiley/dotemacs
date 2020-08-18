;; garbage colleciton
(setq gc-cons-threshold 20000000 )

;; repos
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-archives
   '(("marmalade" . "https://marmalade-repo.org/packages/")
     ("melpa" . "https://melpa.org/packages/")
     ("elpa" . "https://elpa.gnu.org/packages/")))
 '(package-selected-packages
   '(color-theme-sanityinc-tomorrow
     auctex ess treemacs-persp treemacs-magit
     treemacs-icons-dired treemacs-projectile treemacs yasnippet
     poly-R poly-markdown markdown-mode magit
     projectile company helm wc-mode diminish
     smooth-scrolling use-package))
 '(read-buffer-completion-ignore-case t)
 '(read-file-name-completion-ignore-case t)
 ;; get column numbers on by default
 '(column-number-mode t)
 ;; no splash screen
 '(inhibit-startup-message t)
 ;; Make completion case-insensitive. 
 '(completion-ignore-case t)
 ;; where is the Rterm located?
 '(inferior-R-program-name "c:/usr/R/R-4.0.2/bin/x64/Rterm.exe")
 ;; do not restore or ask to save workspace
 '(inferior-R-args "--no-restore --no-save")
 
 ;; ;; julia lang location if using
 ;; '(inferior-julia-program-name "C:/usr/julia/julia-d6f7c7c781/bin/julia-basic.exe")

 ;; spelling program exe location
 ;; https://sourceforge.net/projects/ezwinports/files/
 '(ispell-program-name "c:/usr/hunspell/bin/hunspell.exe")
 ;; location of pandoc for rendering / converting markdown
 '(markdown-command "C:/usr/Pandoc/pandoc.exe")
 )

;; use-package to auto get packages
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))
(when (not (package-installed-p 'use-package))
  (package-install 'use-package))
(require 'use-package)

;; use utf 8 throughout
(set-language-environment "UTF-8")
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

;; show line numbers
(use-package display-line-numbers
  :ensure t
  :config
  (global-display-line-numbers-mode))

;; hightlight matching parens
(show-paren-mode)

;; scroll one line at a time
(use-package smooth-scrolling
  :ensure t  
  :config
  (smooth-scrolling-mode 1))

;; manage key bindings
;; comes with use-package ?
(require 'bind-key)

;; M-g to go to a specific line in a file
(bind-key "M-g" 'goto-line)

;; org mode configuration
(use-package org
  :ensure t)

;;; setup org-mode and org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((R   .t)
   (org .t) ))

;; fontify code in code blocks
(setq org-src-fontify-natively t)

(add-hook 'org-babel-after-execute-hook 'org-display-inline-images)
(add-hook 'org-mode-hook 'org-display-inline-images)

;; diminish
(use-package diminish
  :ensure t)

;; included with emacs
;; help tell different file names apart
(use-package uniquify
  :ensure nil
  :custom
  (uniquify-after-kill-buffer-p t)
  (uniquify-buffer-name-style 'post-forward)
  (uniquify-strip-common-suffix t))

;; show recent files / buffers used
(use-package recentf
  :ensure t
  :config
  (recentf-mode 1)
  (setq recentf-max-menu-items 25)
  (global-set-key "\C-x\ \C-r" 'recentf-open-files))

;; word counts
(use-package wc-mode
  :ensure t
  :hook
  (org-mode . wc-mode))


;; https://zzamboni.org/post/my-emacs-configuration-with-commentary/
;; copied as trying out and not familiar with helm
(use-package helm
  :ensure t
  :diminish helm-mode
  :bind
  (("C-x C-f"       . helm-find-files)
   ("C-x C-b"       . helm-buffers-list)
   ("C-x b"         . helm-multi-files)
   ;; ("M-x"           . helm-M-x)
   :map helm-find-files-map
   ("C-<backspace>" . helm-find-files-up-one-level)
   ("C-f"           . helm-execute-persistent-action)
   ([tab]           . helm-ff-RET))
  :config
  (defun daedreth/helm-hide-minibuffer ()
    (when (with-helm-buffer helm-echo-input-in-header-line)
      (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
        (overlay-put ov 'window (selected-window))
        (overlay-put ov 'face
                     (let ((bg-color (face-background 'default nil)))
                       `(:background ,bg-color :foreground ,bg-color)))
        (setq-local cursor-type nil))))
  (add-hook 'helm-minibuffer-set-up-hook 'daedreth/helm-hide-minibuffer)
  (setq helm-autoresize-max-height 0
        helm-autoresize-min-height 40
        helm-M-x-fuzzy-match t
        helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match t
        helm-semantic-fuzzy-match t
        helm-imenu-fuzzy-match t
        helm-split-window-in-side-p nil
        helm-move-to-line-cycle-in-source nil
        helm-ff-search-library-in-sexp t
        helm-scroll-amount 8
        helm-echo-input-in-header-line nil
        completion-styles '(helm-flex))
  :init
  (helm-mode 1))

(require 'helm-config)
(helm-autoresize-mode 1)

(use-package helm-flx
  :ensure t
  :custom
  (helm-flx-for-helm-find-files t)
  (helm-flx-for-helm-locate t)
  :config
  (helm-flx-mode +1))

(use-package swiper-helm
  :ensure t
  :bind
  ("C-s" . swiper))

;; company mode for auto-completion
(use-package company
  :ensure t
  :defer t
  :diminish company-mode
  :hook
  (after-init . global-company-mode)
  :config
  (setq company-idle-delay 0.0 ;; delay before pop-up
	company-require-match nil) ;; cancel if input doesn't match
  ;; complete using C-TAB
  (global-set-key (kbd "<C-tab>") 'company-complete)
  (define-key company-mode-map (kbd "<C-tab>") 'company-complete)

  (require 'company-capf)
  (setq company-backends
	(delete-dups (cons 'company-capf company-backends)))

  ;; theme
  (set-face-attribute 'company-scrollbar-bg nil
		      :background "gray")
  (set-face-attribute 'company-scrollbar-fg nil
		      :background "black")
  (set-face-attribute 'company-tooltip nil
		      :foreground "black"
		      :background "lightgray")
  (set-face-attribute 'company-tooltip-selection nil
		      :foreground "white"
		      :background "steelblue")
  (add-hook 'after-init-hook 'global-company-mode)
  )

;; use projectile for project management
(use-package projectile
  :ensure t
  :defer t
  :diminish projectile-mode
  :init
  (projectile-global-mode))

(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; on the fly spell checking
(use-package flyspell
  :ensure t
  :diminish
  :config
  ;; turn on flyspell checking by default
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode))


;; git interface
(use-package magit
  :ensure t
  :diminish auto-revert-mode
  :bind
  (("C-x g" . magit-status)
   :map magit-status-mode-map
   ("q"       . magit-quit-session))
  :config
  (defadvice magit-status (around magit-fullscreen activate)
    "Make magit-status run alone in a frame."
    (window-configuration-to-register :magit-fullscreen)
    ad-do-it
    (delete-other-windows))

  (defun magit-quit-session ()
    "Restore the previous window configuration and kill the magit buffer."
    (interactive)
    (kill-buffer)
    (jump-to-register :magit-fullscreen)))

;; markdown mode
(use-package markdown-mode
  :ensure t)

;; various poly modes
(use-package poly-markdown
  :ensure t)

;; sufficient for R + markdown?
(use-package poly-R
  :ensure t)

;; expand snippets of text
(use-package yasnippet
  :ensure t
  :init
  (yas-global-mode 1))

;; tree dir / file viewer
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-move-forward-on-expand        nil
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-user-mode-line-format         nil
          treemacs-user-header-line-format       nil
          treemacs-width                         35)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;; (treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package treemacs-icons-dired
  :after treemacs dired
  :ensure t
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)

(use-package treemacs-persp
  :after treemacs persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

;; emacs speaks statistics --- central to using R in Emacs!
(use-package ess
  :ensure t
  :custom
  (ess-ask-for-ess-directory . nil))

;; only R features, not all ESS by default
(require 'ess-r-mode)

;; for latex stuff
(use-package tex
  :defer t
  :ensure auctex
  :config
  (setq TeX-auto-save t))

(add-to-list 'ess-style-alist
             '(my-style
               (ess-indent-level . 2)
               ))

(setq ess-style 'my-style)

(define-key ess-r-mode-map "_" #'ess-insert-assign)
(define-key inferior-ess-r-mode-map "_" #'ess-insert-assign)

;; sanityinc tomorrow night theme
(use-package color-theme-sanityinc-tomorrow
  :ensure t)
(load-theme 'sanityinc-tomorrow-night t)

;; no tool bar and add column numbers
(tool-bar-mode -1)

