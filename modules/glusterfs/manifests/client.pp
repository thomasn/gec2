define glusterfs::client($server) {
  include glusterfs, autofs
  file { "/etc/glusterfs/glusterfs-client.vol":
    content => template("glusterfs/glusterfs-client.vol.erb"),
    before => Exec["glusterfs-$name-update"],
    require => Class["glusterfs"]
  }
  exec { "glusterfs-auto-master":
    command => '/bin/cat >>/etc/autofs/auto.master <<EOF
### vvv ###
/mnt/glusterfs /etc/autofs/auto.glusterfs --ghost
### ^^^ ###
EOF
',
    unless => "/bin/grep glusterfs /etc/autofs/auto.master 1>/dev/null",
    require => Class["autofs"]
  }
  exec { "glusterfs-$name-update":
    command => "/bin/cat >>/etc/autofs/auto.glusterfs <<EOF
$name -fstype=glusterfs :/etc/glusterfs/glusterfs-client.vol
EOF
",
    unless => "/bin/grep $name /etc/autofs/auto.glusterfs 1>/dev/null",
    notify => Service["autofs"]
  }
}
