;;; bilby.el --- Check bilby job status              -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Md Arif Shaikh

;; Author:  <arifshaikh.astro@gmail.com>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:
(require 'cl)

(defun bilby--get-last-line (file-name)
  "Get the last line in FILE-NAME."
  (let* ((base-name (file-name-base file-name))
	 (extension (file-name-extension file-name))
	 (buffer-name (concat base-name "." extension))
	 (last-line))
    (setq last-line (with-current-buffer (find-file-noselect file-name)
		      (goto-char (point-max))
		      (string-trim (thing-at-point 'line t))))
    (kill-buffer buffer-name)
    last-line))

(defun bilby--get-out-status (out-dir)
  "Check status of run in OUT-DIR."
  (let* ((data-analysis-dir (file-name-concat out-dir "log_data_analysis"))
	 (out-files (file-expand-wildcards (file-name-concat data-analysis-dir "*.out") t))
	 (out-status))
    (setq out-status (cl-loop for out-file in out-files
			      collect (list (file-name-directory out-file) (file-name-base out-file) (bilby--get-last-line out-file))))
    out-status))

(defun bilby-check-out-status (out-dir)
  "Check status of run in OUT-DIR."
  (interactive (list (read-directory-name "Enter outdir for Bilby run: ")))
  (let ((status (bilby--get-out-status out-dir))
	(previous-dir ""))
   (with-current-buffer (generate-new-buffer (string-replace "/" "-" out-dir))
     (dolist (stat status)
       (unless (string-equal (nth 0 stat) previous-dir)
	 (insert "------------------------------------------------------------------------------------------------------------------------------------\n")
	 (insert (format "Status of chains in %s\n" (nth 0 stat)))
	 (insert "------------------------------------------------------------------------------------------------------------------------------------\n"))
       (setq previous-dir (nth 0 stat))
       (insert (nth 1 stat) " " (let ((last-line (nth 2 stat)))
				  (if (string-search "100%" last-line) "Finished" last-line)) "\n"))
     (switch-to-buffer-other-frame (string-replace "/" "-" out-dir)))))

(bilby-check-out-status "/home1/md.shaikh/eccimrct/nr1359/flow20/golden_mass/nlive_2048_nact_10_zero-noise*/injection_0/05Nov2022/*inspiral")

(provide 'bilby)
;;; bilby.el ends here
