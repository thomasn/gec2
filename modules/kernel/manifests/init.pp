class kernel {
  file { "/usr/local/portage/sys-kernel": ensure => directory }
  file { "/usr/local/portage/sys-kernel/ec2-sources":
    source => "puppet:///kernel/ec2-sources",
    recurse => true,
    notify => Exec["update-eix-kernel"],
    before => Portage::Keywords["ec2-sources"],
    require => File["/usr/local/portage/sys-kernel"]
  }
  exec { "update-eix-kernel":
    command => "/usr/bin/update-eix",
    before => Portage::Keywords["ec2-sources"],
  }
  portage::keywords { "ec2-sources": category => "sys-kernel" }
  portage::use { "ec2-sources": category => "sys-kernel", use => "symlink" }
  package { "ec2-sources":
    category => "sys-kernel", before => Exec["ec2-sources-conf"]
  }
  exec { "ec2-sources-conf":
    cwd => "/usr/src/linux",
    command => "/bin/zcat /proc/config.gz >.config && \
                /usr/bin/make oldconfig && \
                /usr/bin/make prepare && \
                /usr/bin/make headers_install",
    creates => "/usr/src/linux/.config"
  }
  file { "/lib/modules":
    ensure => directory,
    before => Exec["ec2-modules-install"]
  }
  exec { "ec2-modules-install":
    command => "/usr/bin/wget -q -O - \
      http://s3.amazonaws.com/ec2-downloads/ec2-modules-$kernelrelease-$hardwaremodel.tgz \
      | tar xzoC /",
    creates => "/lib/modules/$kernelrelease",
    notify => Exec["ec2-modules-depmod"]
  }
  exec { "ec2-modules-depmod":
    command => "/sbin/depmod $kernelrelease",
    refreshonly => true
  }
}
