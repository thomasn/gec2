class mysql inherits base {
  package { "mysql": category => "dev-db" }
  exec { "/usr/bin/mysql_install_db": before => Service["mysql"] }
  service { "mysql": ensure => running, enable => true }
}
