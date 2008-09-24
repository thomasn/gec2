class portage {
  file { "/etc/make.conf": content => template("portage/make.conf.erb") }
  file { "/etc/portage/exclude": source => "puppet:///portage/exclude" }
  file { "/usr/local/portage": ensure => directory }
  package { "portage":
    category => "sys-apps",
    require => [ File["/etc/make.conf"],
                 File["/etc/portage/exclude"],
                 File["/usr/local/portage"] ]
  }
  package { "eix": category => "app-portage", require => Package["portage"] }
  cron { "eix-sync":
    command => "/usr/bin/eix-sync 1>&2>/dev/null",
    user => root,
    hour => 7,
    minute => 0,
    require => Package["eix"]
  }
  exec { "update-eix":
    command => "/usr/bin/update-eix 1>&2>/dev/null",
    refreshonly => true,
    require => Package["eix"]
  }
}