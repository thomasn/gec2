class glusterfs inherits fuse {
  portage::overlay { "glusterfs": category => "sys-fs", source => "glusterfs" }
  portage::keywords { "glusterfs":
    category => "sys-fs", require => Portage::Overlay["glusterfs"]
  }
  portage::use { "glusterfs": category => "sys-fs", use => "client" }
  package { "glusterfs": category => "sys-fs", require => Class["fuse"] }
}
