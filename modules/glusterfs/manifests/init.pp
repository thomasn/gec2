class glusterfs inherits fuse {
  file { "/usr/local/portage/sys-fs/glusterfs":
    source => "puppet:///glusterfs/glusterfs",
    recurse => true,
    before => Portage::Keywords["glusterfs"],
    require => Class["fuse"]
  }
  exec { "update-eix-glusterfs":
    command => "/usr/bin/update-eix",
    refreshonly => true,
    subscribe => File["/usr/local/portage/sys-fs/glusterfs"],
    before => Portage::Keywords["glusterfs"]
  }
  portage::keywords { "glusterfs": category => "sys-fs" }
  portage::use { "glusterfs": category => "sys-fs", use => "client" }
  package { "glusterfs": category => "sys-fs", require => Class["fuse"] }
}
