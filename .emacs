(tool-bar-mode -1)
(scroll-bar-mode -1)

; get the mouse behaving normally!
;(setq mouse-wheel-progressive-speed nil)
;(setq mouse-wheel-scroll-amount '(2 ((shift) . 1) ((control) . nil)))

(package-initialize)

(require 'package)
(setq package-archives
      `(("gnu" . "http://elpa.gnu.org/packages/")
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
	 "Menlo 12" ;; Cinema Display
       "Fira Code")))

(mac-auto-operator-composition-mode)

; (set-default-font "Menlo 12")

(add-to-list 'load-path "~/Library/Emacs")
(add-to-list 'load-path "~/Library/Emacs/ess-13.05/lisp")

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

(setq inferior-julia-program-name "julia")

(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-agenda-files '("~/Sync/org"))
(setq org-log-done t)

(add-to-list 'custom-theme-load-path "~/Library/emacs/color-theme-solarized")
(load-theme 'solarized-light t)

(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")

(setq-default ispell-program-name "hunspell")
(setq ispell-dictionary "british"
      ispell-local-dictionary-alist '(("british"
				       "[[:alpha:]]"
				       "[^[:alpha:]]"
				       "['’]" t ("-d" "en_GB") nil utf-8)))

(setq sql-postgres-program "/usr/local/bin/psql")
(setq sql-postgres-options '("-P" "pager=off"
                             "-P" "title= "
                             "-n"
                             "-v" "PROMPT1=> "
                             "-v" "PROMPT2=+ "
                             "-v" "PROMPT3=C+ "))

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
	    (setq indent-tabs-mode nil)
	    (setq web-mode-code-indent-offset 4)
	    (setq web-mode-css-indent-offset 2)
	    (setq web-mode-markup-indent-offset 2)))

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

(add-hook 'js-mode-hook
	  (lambda ()
	    (setq indent-tabs-mode nil)))

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
(setq require-final-newline 'ask)

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
