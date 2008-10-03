class apache {
  package { "apache": category => "www-apache" }
  file { "/etc/conf.d/apache2":
    source => "puppet:///apache/apache2",
    before => Service["apache2"],
    require => Package["apache"]
  }
  service { "apache2": ensure => running, enable => true }
}
