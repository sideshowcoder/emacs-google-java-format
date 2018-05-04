;;; google-java-format.el --- Format java file according to google style

;; Copyright (C) 2018 Philipp Fehre

; Author: Philipp Fehre <philipp@fehre.co.uk>

;; Version: 1.0.0
;; Keywords: java, google, format

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
;; `(add-hook 'java-mode-hook 'gjf-indention-settings)'
;;

;;; Code:

(require 'url)
(require 'cc-vars)

(defvar gjf-jar-name
  "google-java-format-1.5-all-deps.jar"
  "Jar name for google-java-format.")

(defvar gjf-release-url
  "https://github.com/google/google-java-format/releases/download/google-java-format-1.5/"
  "URL to jar to use for google-java-format jar download.")

(defvar gjf-fail-token
  "GJF4711FAIL"
  "Token used to detect if the formatter failed for format the content.")

(defvar gjf-jar-path
  (concat user-emacs-directory "google-java-format/")
  "Full path to google-format-jar.")

(defun gjf-setup-formatter ()
  "Download google-java-format from `gjf-release-url' use into `gjf-jar-path'."
  (interactive)
  (make-directory gjf-jar-path 't)
  (let ((download-url (concat gjf-release-url gjf-jar-name))
        (store-path (concat gjf-jar-path gjf-jar-name)))
    (url-copy-file download-url store-path)))

(defun gjf--formatter-failed-p (result)
  "Detect google-java-format failure in RESULT based on `gjf-fail-token'."
  (string-match-p (regexp-quote gjf-fail-token) result))

(defun gjf-reformat-buffer ()
  "Run the google formatter on the current file."
  (interactive)
  (let ((content (shell-command-to-string
                  (concat "java -jar " gjf-jar-path gjf-jar-name " " buffer-file-name " || echo " gjf-fail-token))))
    (if (gjf--formatter-failed-p content)
        (message "Format failed: %s" (car (split-string content gjf-fail-token)))
      (save-excursion
        (setf (buffer-string) content)))))

(defun gjf-indention-settings ()
  "Setup java indention rules according to google-java-format standard.

Use this via `(add-hook 'java-mode-hook 'gjf-indention-settings)'"
  (setq c-basic-offset 2)
  (c-set-offset 'case-label '+)
  (c-set-offset 'statement-cont '++))

(provide 'emacs-google-java-format)
;;; google-java-format.el ends here
