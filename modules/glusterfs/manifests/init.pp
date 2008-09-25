class glusterfs inherits fuse {
  file { "/usr/local/portage/sys-fs/glusterfs":
    source => "puppet:///glusterfs/glusterfs",
    recurse => true,
    notify => Exec["update-eix"],
    before => Portage::Keywords["glusterfs"],
    require => Class["fuse"]
  }
  portage::keywords { "glusterfs": category => "sys-fs" }
  portage::use { "glusterfs": category => "sys-fs", use => "client" }
  package { "glusterfs": category => "sys-fs", require => Class["fuse"] }
}
