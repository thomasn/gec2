class autofs {
  package { "autofs": category => "net-fs" }
  service { "autofs": enable => true, require => Package["autofs"] }
}
