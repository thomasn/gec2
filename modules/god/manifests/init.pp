class god {
  ruby::gem { "god": before => Service["god"] }
  file { "/etc/god":
    source => "puppet:///god/god", recurse => true, before => Service["god"]
  }
  file { "/etc/init.d/god":
    source => "puppet:///god/runscript", before => Service["god"], mode => 755
  }
  service { "god": ensure => running, enable => true }
}
