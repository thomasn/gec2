class puppet {
  file { "/etc/init.d/puppet":
    source => "puppet:///puppet/runscript",
    mode => 755
  }
  file { "/etc/puppet/puppet.conf": source => "puppet:///puppet/puppet.conf" }
  package::keywords { "facter": category => "dev-ruby" }
  package { "facter": category => "dev-ruby", require => Class["ruby"] }
  package::keywords { "puppet": category => "app-admin" }
  package { "puppet": category => "app-admin", require => Package["facter"] }
  service { "puppet":
    enable => true,
    require => [ Package["puppet"],
                 File["/etc/init.d/puppet"],
                 File["/etc/puppet/puppet.conf"] ]
  }
}
