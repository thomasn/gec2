class s3fs inherits fuse {
  package::keywords { "s3fs": category => "sys-fs" }
  package { "s3fs": category => "sys-fs", require => Class["fuse"] }
}
