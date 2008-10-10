define mycluster::share_client($server) {
  glusterfs::client { $name:
    server => $server,
    before => File["/mnt/$name"]
  }
}
