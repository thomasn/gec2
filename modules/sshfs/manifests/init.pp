class sshfs inherits fuse {
  package { "sshfs-fuse": category => "sys-fs", require => Class["fuse"] }
}
