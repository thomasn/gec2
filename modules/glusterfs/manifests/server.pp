class glusterfs::server inherits glusterfs {
  service { "glusterfs":
    enable => true,
    ensure => running,
    require => Class["glusterfs"]
  }
}
