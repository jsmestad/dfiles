;;; linux.el -- Linux specific configuration

;;; Commentary:
;;; Use Super-S to save like I am on macOS

;;; Code:

;; (when (member "Symbola" (font-family-list))
(set-fontset-font t 'unicode "Twitter Color Emoji" nil 'prepend)

(when (display-graphic-p)
  (global-set-key (kbd "s-s") (lambda ()
                                (interactive)
                                (call-interactively (key-binding "\C-x\C-s")))))

(provide 'linux)

;;; linux.el ends here.
