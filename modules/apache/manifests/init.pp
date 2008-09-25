class apache inherits base {
  portage::keywords { "passenger":
    category => "www-apache", require => Class["ruby"]
  }
  file { "/etc/conf.d/apache2":
    source => "puppet:///apache/apache2", before => Service["apache2"]
  }
  package { "passenger": category => "www-apache" }
  service { "apache2": ensure => running, enable => true }

  define rails($env, $dir) {
    file { "/etc/apache2/vhosts.d/$name.conf":
      content => template("apache/vhost.conf.erb"),
      notify => Service["apache2"],
      before => Service["apache2"]
    }
  }
}
