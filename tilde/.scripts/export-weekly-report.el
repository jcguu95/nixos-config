(progn (require 'cl-lib)

; backup variables
(setq backup-org-agenda-start-with-log-mode org-agenda-start-with-log-mode)
(setq backup-org-agenda-start-with-clockreport-mode org-agenda-start-with-clockreport-mode)
(setq backup-org-agenda-start-on-weekday org-agenda-start-on-weekday)
(setq backup-org-agenda-files org-agenda-files)

; adjust variables temporarily for export
(setq org-agenda-start-with-log-mode t)
(setq org-agenda-start-with-clockreport-mode t)
(setq org-agenda-start-on-weekday 1)
(append org-agenda-files (list (concat org-gtd-directory "someday.org")))

; export
(org-agenda-list nil nil 7 nil)

(cl-loop for week from 1 to 52 do (progn
	(org-agenda-week-view week)
	(org-agenda-write (concat "W" (number-to-string week) "report.html"))))

; restore variables
(setq org-agenda-start-with-log-mode backup-org-agenda-start-with-log-mode)
(setq org-agenda-start-with-clockreport-mode backup-org-agenda-start-with-clockreport-mode)
(setq org-agenda-start-on-weekday backup-org-agenda-start-on-weekday)
(setq org-agenda-files backup-org-agenda-files))
