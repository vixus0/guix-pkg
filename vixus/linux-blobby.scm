(define-module (vixus linux-blobby)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages linux)
  #:use-module (srfi srfi-1))

(define kernel-config (local-file "./kernel.config"))

(define-public linux-blobby
  (package
    (inherit linux-libre)
    (name "linux-blobby")
    (description "Filthy linux")
    (version "5.0.7")
    (source
      (origin
        (method url-fetch)
        (uri
          (string-append
            "https://cdn.kernel.org/pub/linux/kernel/v5.x/"
            "linux-" version ".tar.xz"))
        (sha256 (base32 "1v2lxwamnfm879a9qi9fwp5zyvlzjw9qa0aizidjbiwz5dk7gq8n"))))
    (native-inputs
      `(("kcconfig" ,kernel-config)
        ,@(alist-delete "kconfig"
                        (package-native-inputs linux-libre))))))

(define (linux-firmware-version) "67b75798ea88f4b1d6ee6a3b5a0634d29620c094")
(define (linux-firmware-source version)
  (origin
    (method git-fetch)
    (uri (git-reference
	  (url (string-append 
           "https://git.kernel.org/pub/scm/linux/kernel"
			     "/git/firmware/linux-firmware.git"))
	  (commit version)))
    (file-name (string-append "linux-firmware-" version "-checkout"))
    (sha256 (base32 "06lyv422yfc09488dp4sj708ypww3rpg05ndmpl9wrhxp0g2lwp4"))))

(define-public linux-firmware-iwlwifi
  (package
    (name "linux-firmware-iwlwifi")
    (version (linux-firmware-version))
    (source (linux-firmware-source version))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder (begin
       (use-modules (guix build utils))
       (let ((source (assoc-ref %build-inputs "source"))
       (fw-dir (string-append %output "/lib/firmware/")))
         (mkdir-p fw-dir)
         (for-each (lambda (file)
         (copy-file file
              (string-append fw-dir (basename file))))
             (find-files source
             "iwlwifi-.*\\.ucode$|LICENSE\\.iwlwifi_firmware$"))
         #t))))
    (home-page "https://wireless.wiki.kernel.org/en/users/drivers/iwlwifi")
    (synopsis "Non-free firmware for Intel wifi chips")
    (description "Non-free iwlwifi firmware")
    (license (license:non-copyleft
        "https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/tree/LICENCE.iwlwifi_firmware?id=HEAD"))))
