Why this overlay
================

This Portage overlay aims to improve the current systemd (and indirectly openrc)
situation in Gentoo Linux, by making both systemd and openrc coexist on the
same system. This has, among many, the goal of making a systemd transition
smooth and simple, without the need of recompiling obscure packages, placing
weird blockers in package dependencies and ending up with whacky ebuild code
that removes files from the install target directory depending on USE=systemd.
I believe that USE=systemd is bad and whatever conflict is present should
be addressed at runtime.

How to make this overlay effective
==================================
Very simple.

  1.  Enable USE=systemd globally (in make.conf)
  2.  Replace udev with systemd:
        $ emerge -C sys-fs/udev && emerge sys-apps/systemd::systemd-love
  3.  Recompile all the installed packages with the new USE=systemd. Make
      sure to use the packages from the systemd-love overlay, in particular:
      openrc-settingsd, sysvinit, systemd, eselect-sysvinit, eselect-settingsd.
  4.  Now you can decide wheter to boot your system with openrc or systemd.
      For systemd: eselect sysvinit set systemd && eselect settingsd set systemd.
      For openrc: eselect sysvinit set sysvinit && eselect settingsd set openrc.
  5.  Have fun!
