class apache::passenger inherits apache {
  portage::keywords { "passenger":
    category => "www-apache", require => Class["ruby"]
  }
  package { "passenger": category => "www-apache" }
  file { "/u": ensure => directory }
  file { "/u/apps": ensure => "/var/www" }
  file { "/var/www": owner => "root", group => "apache", mode => 2775 }

  define setup($rails_env = "production", $public_dir) {
    file { "/etc/apache2/vhosts.d/$name.conf":
      content => template("apache/vhost.conf.erb"),
      notify => Service["apache2"],
      before => Service["apache2"]
    }
  }
}
