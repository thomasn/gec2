class apache::passenger inherits apache {
  portage::keywords { "passenger":
    category => "www-apache", require => Class["ruby"]
  }
  package { "passenger": category => "www-apache" }
  file { "/u": ensure => directory }
  file { "/u/apps": ensure => "/var/www" }
  file { "/var/www": owner => "root", group => "apache", mode => 2775 }

  define app($env, $dir) {
    file { "/etc/apache2/vhosts.d/$name.conf":
      content => template("apache/vhost.conf.erb"),
      notify => Service["apache2"],
      before => Service["apache2"]
    }
  }
}
