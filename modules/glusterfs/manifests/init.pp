class glusterfs inherits fuse {
  file { "/usr/local/portage/sys-fs/glusterfs":
    source => "puppet:///glusterfs/glusterfs",
    recurse => true,
    notify => Exec["update-eix"],
    before => Package::Keywords["glusterfs"],
    require => Class["fuse"]
  }
  package::keywords { "glusterfs": category => "sys-fs" }
  package::use { "glusterfs": category => "sys-fs", use => "client" }
  package { "glusterfs": category => "sys-fs", require => Class["fuse"] }
}
