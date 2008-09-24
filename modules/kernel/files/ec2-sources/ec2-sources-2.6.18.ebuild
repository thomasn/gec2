# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

ETYPE="sources"
inherit kernel-2

PKG=xen-3.1.0-src-ec2-v1.0
DESCRIPTION="EC2 Kernel Sources"
HOMEPAGE="http://www.kernel.org"
SRC_URI="http://ec2-downloads.s3.amazonaws.com/${PKG}.tgz"

KEYWORDS="amd64 x86"
S=${WORKDIR}

src_unpack() {
    unpack ${A}
    cd ${S}/${PKG}
    make prep-kernels
    cp -rL ./linux-2.6.18-xen ../linux-2.6.18-ec2
}
