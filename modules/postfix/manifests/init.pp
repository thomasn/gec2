class postfix {
  portage::use { "postfix": category => "mail-mta", use => "sasl" }
  package { "postfix": category => "mail-mta", before => Service["postfix"] }
  exec { "postfix-reload":
    command => "/usr/sbin/postfix reload", refreshonly => true
  }
  exec { "postfix-aliases":
    command => "/usr/bin/newaliases",
    refreshonly => true,
    notify => Exec["postfix-reload"]
  }
  exec { "postmap-virtual":
    command => "/usr/sbin/postmap /etc/postfix/virtual",
    refreshonly => true,
    notify => Exec["postfix-reload"]
  }
  service { "postfix": enable => true, ensure => running }
}
