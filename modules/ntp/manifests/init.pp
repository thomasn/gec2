class ntp {
  package { "openntpd": category => "net-misc" }
  service { "ntpd": enable => true, require => Package["openntpd"] }
}
