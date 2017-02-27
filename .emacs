(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

; get the mouse behaving normally!
;(setq mouse-wheel-progressive-speed nil)
;(setq mouse-wheel-scroll-amount '(2 ((shift) . 1) ((control) . nil)))

(package-initialize)

(require 'package)
(setq package-archives
      `(("gnu" . "http://elpa.gnu.org/packages/")
	("melpa" . "http://melpa.org/packages/")
	("marmalade" . "https://marmalade-repo.org/packages/")))

; (when (memq window-system '(mac ns))
;   (exec-path-from-shell-initialize))

(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)

(if window-system
    (set-default-font
     (if (> (x-display-pixel-width) 2000)
         "Inconsolata 11" ;; Cinema Display
       "Fira Code R")))

; (mac-auto-operator-composition-mode)

;;;###Autoload
(autoload 'cuda-mode      "cuda-mode")
(autoload 'chpl-mode      "chpl-mode" "Chpl enhanced cc-mode" t)
(autoload 'ws-butler-mode "ws-butler")
(autoload 'julia-mode     "julia-mode")

(add-to-list 'auto-mode-alist '("\\.cu$"   . cuda-mode))
(add-to-list 'auto-mode-alist '("\\.m$"    . octave-mode))
(add-to-list 'auto-mode-alist '("\\.chpl$" . chpl-mode))
(add-to-list 'auto-mode-alist '("\\.jl\\'" . julia-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'"       . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

;(add-hook 'typescript-mode-hook #'setup-tide-mode)

;; Pull from PRIMARY (same as middle mouse click)
(defun get-primary ()
  (interactive)
  (insert
   (gui-get-primary-selection)))
(global-set-key "\C-c\C-y" 'get-primary)

;; format options
(setq tide-format-options '(:insertSpaceAfterFunctionKeywordForAnonymousFunctions t :placeOpenBraceOnNewLineForFunctions nil))


(setq inferior-julia-program-name "julia")

(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-agenda-files '("~/Sync/org"))
(setq org-log-done t)

(load-theme 'sanityinc-tomorrow-night t)

(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")

(with-eval-after-load "ispell"
  (setq ispell-program-name "hunspell")
  (setq ispell-dictionary "en_GB")
  (add-to-list 'ispell-dictionary-alist
	       '("en_GB" "[[:alpha:]]" "[^[:alpha:]]" "[']" t
		 ("-d" "en_GB-large")
		 nil utf-8)))

; (setq sql-postgres-program "/usr/local/bin/psql")
(setq sql-postgres-options '("-P" "pager=off"
                             "-P" "title= "
                             "-n"
                             "-v" "PROMPT1=> "
                             "-v" "PROMPT2=+ "
                             "-v" "PROMPT3=C+ "))

(with-eval-after-load "sql"
  (add-to-list 'sql-postgres-login-params '(port :default 5432)))

(defun insert-dateiso ()
  "Insert string for today's date nicely formatted in ISO 8601 style"
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "%Y-%m-%d %H:%M:%S")))

;; Allow hash to be entered
(define-key global-map (kbd "M-3")
  (lambda ()
    (interactive)
    (insert "#")))

(define-key global-map (kbd "C-c d")
  'ispell-word)

(add-hook 'prog-mode-hook
	  (lambda ()
	    (ws-butler-mode)
	    (flyspell-prog-mode)))

(add-hook 'text-mode-hook
	  (lambda ()
	    (turn-on-flyspell)
	    (turn-on-auto-fill)))

;; get web-mode setup nicely
(add-hook 'web-mode-hook
	  (lambda ()
	    (setq web-mode-code-indent-offset 4)
	    (setq web-mode-css-indent-offset 2)
            (setq web-mode-markup-indent-offset 2)
            (setq require-final-newline 'ask)
            (setq mode-require-final-newline 'ask)))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; get flyspell working with web-mode
(defun web-mode-flyspefll-verify ()
  (let ((f (get-text-property (- (point) 1) 'face)))
    (not (memq f '(web-mode-html-attr-value-face
                   web-mode-html-tag-face
                   web-mode-html-attr-name-face
                   web-mode-doctype-face
                   web-mode-keyword-face
                   web-mode-function-name-face
                   web-mode-variable-name-face
                   web-mode-css-property-name-face
                   web-mode-css-selector-face
                   web-mode-css-color-face
                   web-mode-type-face
                   )
               ))))
(put 'web-mode 'flyspell-mode-predicate 'web-mode-flyspefll-verify)

(add-hook 'tex-mode-hook
	  (lambda ()
	    (fset 'tex-font-lock-suscript 'ignore)))

(require 'server)
(unless (server-running-p)
  (server-start))

(require 'ess-site)

; from Dirk's response to:
;  http://stackoverflow.com/questions/7502540/make-emacs-ess-follow-r-style-guide
(add-hook 'ess-mode-hook
	  (lambda ()
	    (ess-set-style 'C++ 'quiet)
	    ;; Because
	    ;;                                 DEF GNU BSD K&R  C++
	    ;; ess-indent-level                  2   2   8   5  4
	    ;; ess-continued-statement-offset    2   2   8   5  4
	    ;; ess-brace-offset                  0   0  -8  -5 -4
	    ;; ess-arg-function-offset           2   4   0   0  0
	    ;; ess-expression-offset             4   2   8   5  4
	    ;; ess-else-offset                   0   0   0   0  0
	    ;; ess-close-brace-offset            0   0   0   0  0
	    (add-hook 'local-write-file-hooks
		      (lambda ()
			(ess-nuke-trailing-whitespace)))))

; ask whether to append a newline to the end of the file, options are
; t, nil, or "anything else"
(setq-default require-final-newline 'ask)

(defun mutt-mail-mode-hook ()
  ; (flush-lines "^\\(> \n\\)*> -- \n\\(\n?> .*\\)*") ; kill quoted sigs
  (not-modified)
  (mail-text)
  (setq make-backup-files nil))
(or (assoc "mutt-" auto-mode-alist)
    (setq auto-mode-alist (cons '("/var/folders/.*/mutt.*" . mail-mode) auto-mode-alist)))
(add-hook 'mail-mode-hook 'mutt-mail-mode-hook)

; finally disable the "welcome" startup message and leave it open on
; my todo file
(setq inhibit-startup-message t)

; don't want to open this any more, I'm using Wunderlist instead
; (find-file "~/Sync/todo.txt")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (color-theme-sanityinc-tomorrow fish-mode yaml-mode company tide web-mode rw-ispell rw-language-and-country-codes rw-hunspell ws-butler solarized-theme markdown-mode ess)))
 '(safe-local-variable-values (quote ((eval web-mode-set-engine "django")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
