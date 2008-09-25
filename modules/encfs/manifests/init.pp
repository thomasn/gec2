class encfs inherits fuse {
  portage::keywords { "rlog": category => "dev-libs" }
  portage::keywords { "encfs": category => "sys-fs" }
  package { "rlog": category => "dev-libs", before => Package["encfs"] }
  package { "encfs": category => "sys-fs", require => Class["fuse"] }
}
