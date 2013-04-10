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

