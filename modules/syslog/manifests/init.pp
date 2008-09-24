class syslog {
  package { [ "logrotate", "syslog-ng" ]: category => "app-admin" }
  service { "syslog-ng": enable => true, require => Package["syslog-ng"] }
}
