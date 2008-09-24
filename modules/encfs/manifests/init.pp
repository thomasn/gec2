class encfs inherits fuse {
  package::keywords { "rlog": category => "dev-libs" }
  package::keywords { "encfs": category => "sys-fs" }
  package { "rlog": category => "dev-libs", before => Package["encfs"] }
  package { "encfs": category => "sys-fs", require => Class["fuse"] }
}
