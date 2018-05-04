;;; emacs-google-java-format.el --- Format java file according to google style

;; Copyright (C) 2018 Philipp Fehre

;; Author: Philipp Fehre <philipp@fehre.co.uk>
;; Homepage: https://github.com/sideshowcoder/emacs-google-java-format

;; Version: 1.0.0
;; Keywords: tools

;; Copyright 2018 Philipp Fehre
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;
;; 1. Redistributions of source code must retain the above copyright notice,
;; this list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright notice,
;; this list of conditions and the following disclaimer in the documentation
;; and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.

;;; Commentary:

;; Format Java code according to google style, using the google formatter
;; See https://github.com/google/google-java-format/releases
;;
;; This works best with the formatting rules set up via
;; `(add-hook 'java-mode-hook 'emacs-google-java-format-indention-settings)'
;;

;;; Code:

(require 'url)
(require 'cc-vars)

(defvar emacs-google-java-format-jar-name
  "google-java-format-1.5-all-deps.jar"
  "Jar name for google-java-format.")

(defvar emacs-google-java-format-release-url
  "https://github.com/google/google-java-format/releases/download/google-java-format-1.5/"
  "URL to jar to use for google-java-format jar download.")

(defvar emacs-google-java-format-fail-token
  "EMACS-GOOGLE-JAVA-FORMAT4711FAIL"
  "Token used to detect if the formatter failed for format the content.")

(defvar emacs-google-java-format-jar-path
  (concat (file-name-as-directory user-emacs-directory) "google-java-format/")
  "Full path to google-format-jar.")

(defun emacs-google-java-format-setup-formatter ()
  "Download google-java-format from `emacs-google-java-format-release-url' use into `emacs-google-java-format-jar-path'."
  (interactive)
  (make-directory emacs-google-java-format-jar-path 't)
  (let ((download-url (concat emacs-google-java-format-release-url emacs-google-java-format-jar-name))
        (store-path (concat emacs-google-java-format-jar-path emacs-google-java-format-jar-name)))
    (url-copy-file download-url store-path)))

(defun emacs-google-java-format--formatter-failed-p (result)
  "Detect google-java-format failure in RESULT based on `emacs-google-java-format-fail-token'."
  (string-match-p (regexp-quote emacs-google-java-format-fail-token) result))

(defun emacs-google-java-format-reformat-buffer ()
  "Run the google formatter on the current file."
  (interactive)
  (let ((content (shell-command-to-string
                  (concat "java -jar " emacs-google-java-format-jar-path emacs-google-java-format-jar-name " " buffer-file-name " || echo " emacs-google-java-format-fail-token))))
    (if (emacs-google-java-format--formatter-failed-p content)
        (message "Format failed: %s" (car (split-string content emacs-google-java-format-fail-token)))
      (save-excursion
        (setf (buffer-string) content)))))

(defun emacs-google-java-format-indention-settings ()
  "Setup java indention rules according to google-java-format standard.

Use this via `(add-hook 'java-mode-hook 'emacs-google-java-format-indention-settings)'"
  (setq c-basic-offset 2)
  (c-set-offset 'case-label '+)
  (c-set-offset 'statement-cont '++))

(provide 'emacs-google-java-format)

;;; emacs-google-java-format.el ends here
