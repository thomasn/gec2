class sudo {
  package { "sudo": category => "app-admin" }
  file { "/etc/sudoers":
    source => "puppet:///sudo/sudoers",
    mode => 440,
    require => Package["sudo"]
  }
}
