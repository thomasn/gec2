class ddclient {
  package { "ddclient": category => "net-dns" }
  service { "ddclient": enable => true, require => Package["ddclient"] }
}
