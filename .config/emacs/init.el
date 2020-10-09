;;; init.el ---  Initialization file for Emacs
;;; Commentary:
;;  Emacs Startup File --- initialization for Emacs
;;; Code:

(setq gc-cons-threshold (* 1024 1024))

(require 'package)
(setq package-archives '(("org" . "http://orgmode.org/elpa/")
                         ("melpa" . "http://melpa.org/packages/")
                         ;; ("melpa-stable" . "http://stable.melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))

(setq package-enable-at-startup nil)
(package-initialize)

;;Inhibit custom littering my init file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

(require 'org)
(org-babel-load-file (expand-file-name "settings.org" user-emacs-directory))

;;; init.el ends here
