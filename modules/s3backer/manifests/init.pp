class s3backer inherits fuse {
  portage::overlay { "s3backer": category => "sys-fs", source => "s3backer" }
  portage::keywords { "s3backer":
    category => "sys-fs", require => Portage::Overlay["s3backer"]
  }
  package { "s3backer": category => "sys-fs", require => Class["fuse"] }
}
