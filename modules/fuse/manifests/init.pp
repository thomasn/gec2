class fuse {
  file { "/usr/local/portage/sys-fs": ensure => directory }
  package { "fuse": category => "sys-fs", require => Class["kernel"] }
  exec { "module-fuse":
    command => "/bin/echo fuse >>/etc/modules.autoload.d/kernel-2.6",
    unless => "/bin/grep fuse /etc/modules.autoload.d/kernel-2.6 1>/dev/null"
  }
  exec { "modprobe-fuse":
    command => "/sbin/modprobe fuse",
    unless => "/sbin/lsmod | grep loop 1>/dev/null",
    require => Class["kernel"]
  }
}
