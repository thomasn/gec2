define glusterfs::server {
  include glusterfs
  file { "/etc/glusterfs/glusterfs-server.vol":
    content => template("glusterfs/glusterfs-server.vol.erb"),
    before => Service["glusterfs-server"],
    require => Class["glusterfs"]
  }
  service { "glusterfs-server":
    enable => true,
    ensure => running,
    require => Class["glusterfs"]
  }
}
