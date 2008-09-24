class puppet::master inherits puppet {
  file { "/etc/puppet/fileserver.conf":
    source => "puppet:///puppet/fileserver.conf"
  }
  service { "puppetmaster":
    enable => true,
    before => Service["puppet"],
    require => [ Package["puppet"], File["/etc/puppet/fileserver.conf"] ]
  }
}
