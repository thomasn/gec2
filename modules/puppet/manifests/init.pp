class puppet {
  file { "/etc/puppet/puppet.conf": source => "puppet:///puppet/puppet.conf" }
  file { "/etc/puppet/fileserver.conf":
    source => "puppet:///puppet/fileserver.conf"
  }
  package::keywords { "facter": category => "dev-ruby" }
  package { "facter": category => "dev-ruby", require => Class["ruby"] }
  package::keywords { "puppet": category => "app-admin" }
  package { "puppet": category => "app-admin", require => Package["facter"] }
}
