# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

inherit eutils

PKG=${PN}-1.3-21885

DESCRIPTION="Amazon EC2 AMI Tools"
SRC_URI="http://s3.amazonaws.com/ec2-downloads/${PKG}.zip"
HOMEPAGE="http://developer.amazonwebservices.com"
KEYWORDS="x86 amd64"
SLOT="0"
LICENSE="commercial"
IUSE=""

S=${WORKDIR}/${PKG}
DEPEND="app-arch/unzip"
RDEPEND="dev-lang/ruby net-misc/rsync net-misc/curl"

src_install () {
    rm -rf ${S}/bin/*.cmd
    dodir /opt/${P}
    insinto /opt/${P}/lib
    doins -r ${S}/lib/*
    exeinto /opt/${P}/bin
    doexe ${S}/bin/*
    insinto /usr/bin
    for exe in ${S}/bin/*; do
        target="$(basename ${exe})"
        base="$(basename ${exe})"
        ln -s /opt/${P}/bin/${target} ${D}/usr/bin/${base}
    done
    insinto /opt/${P}/etc
    doins -r ${S}/etc/*
    dodir /etc/env.d
    echo "EC2_AMITOOL_HOME=/opt/${P}" > ${D}/etc/env.d/99ec2-ami-tools
}
