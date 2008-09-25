class base {
  include autofs, aws, cron, ddclient, encfs, fuse, git, glusterfs,
    kernel, ntp, portage, puppet, ruby, s3backer, s3fs, ssh, sshfs,
    sudo, syslog

  file { "/etc/motd": source => "puppet:///base/motd" }

  file { "/etc/fstab": content => template("base/fstab.erb") }

  file { "/etc/conf.d/local.start": source => "puppet:///base/local.start" }

  file { "/etc/conf.d/clock": source => "puppet:///base/clock" }
  file { "/etc/localtime": ensure => "/usr/share/zoneinfo/GMT" }

  file { "/etc/env.d/02locale": source => "puppet:///base/02locale" }
  file { "/etc/locale.gen": source => "puppet:///base/locale.gen" }
  exec { "locale-gen":
    command => "/usr/sbin/locale-gen",
    subscribe => File["/etc/locale.gen"],
    refreshonly => true
  }

  file { "/etc/sysctl.conf":
    source => "puppet:///base/sysctl.conf",
    mode => 640
  }
  exec { "sysctl":
    command => "/sbin/sysctl -p",
    subscribe => File["/etc/sysctl.conf"],
    refreshonly => true
  }

  service { "net.eth0": enable => true }
  package { "dhcpcd": category => "net-misc" }
  file { "/usr/local/sbin/hosts":
    source => "puppet:///base/hosts",
    mode => 700
  }
}
