class s3fs inherits fuse {
  include autofs

  portage::keywords { "s3fs": category => "sys-fs" }
  package { "s3fs": category => "sys-fs", require => Class["fuse"] }
  exec { "s3fs-auto-master":
    command => '/bin/cat >>/etc/autofs/auto.master <<EOF
### vvv ###
/mnt/s3fs /etc/autofs/auto.s3fs --ghost
### ^^^ ###
EOF
',
    unless => "/bin/grep s3fs /etc/autofs/auto.master 1>/dev/null"
  }

  define mount($access_key_id, $secret_access_key) {
    exec { "s3fs-$name-update":
      command => "/bin/cat >>/etc/autofs/auto.s3fs <<EOF
$name -fstype=fuse,uid=0,gid=100,umask=002,default_permissions,allow_other,accessKeyId=$access_key_id,secretAccessKey=$secret_access_key :s3fs\#$name
EOF
",
      unless => "/bin/grep $name /etc/autofs/auto.s3fs 1>/dev/null",
      notify => Service["autofs"]
    }
  }
}
