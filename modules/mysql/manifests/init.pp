class mysql {
  package { "mysql":
    category => "dev-db",
    before => File["/etc/mysql/my.cnf"]
  }
  file { "/etc/mysql/my.cnf":
    source => "puppet:///mysql/my.cnf",
    before => Exec["mysql-init"]
  }
  exec { "mysql-init":
    command => "/usr/bin/mysql_install_db",
    creates => "/var/lib/mysql/mysql",
    before => Service["mysql"]
  }
  service { "mysql": ensure => running, enable => true }

  define setup($db_user, $db_pass) {
    include mysql
    exec { "mysql-create-db":
      command => "/usr/bin/mysqladmin create $name",
      unless => "/usr/bin/test -d /var/lib/mysql/$name",
      notify => Exec["mysql-create-user"],
      before => Exec["mysql-create-user"],
      require => Service["mysql"]
    }
    exec { "mysql-create-user":
      command => "/usr/bin/mysql -e \"\
      GRANT ALL ON $name.* to '$db_user'@'10.%.%.%' IDENTIFIED BY '$db_pass'; \
      GRANT ALL ON $name.* to '$db_user'@'localhost' IDENTIFIED BY '$db_pass'; \
      FLUSH PRIVILEGES;\"",
      refreshonly => true
    }
  }
}
