define mycluster::share_server() {
  file { "/mnt/$name":
    ensure => directory,
    before => Glusterfs::Server["/mnt/$name"]
  }
  glusterfs::server { "/mnt/$name": }
}
