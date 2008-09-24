class cron {
  package { "vixie-cron": category => "sys-process" }
  service { "vixie-cron": enable => true, require => Package["vixie-cron"] }
}
