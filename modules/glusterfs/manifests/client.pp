define glusterfs::client($server) {
  include glusterfs
  file { "/etc/conf.d/glusterfs-client":
    content => template("glusterfs/glusterfs-client.erb"),
    before => Service["glusterfs-client"],
    require => Class["glusterfs"]
  }
  file { "/etc/glusterfs/glusterfs-client.vol":
    content => template("glusterfs/glusterfs-client.vol.erb"),
    before => Service["glusterfs-client"],
    require => Class["glusterfs"]
  }
  service { "glusterfs-client": enable => true, ensure => running }
}
