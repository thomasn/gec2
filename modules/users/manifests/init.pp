class users {
  define account($uid, $groups = []) {
    user { $name:
      uid => $uid,
      gid => 100,
      groups => $groups,
      shell => '/bin/bash',
      managehome => true,
      ensure => present,
      allowdupe => false,
      before => [ File["/home/$name/.ssh"],
                  File["/home/$name/.ssh/authorized_keys"] ],
      notify => Exec["scramble-password-$name"]
    }
    exec { "scramble-password-$name":
      command => "/usr/sbin/usermod -p \
      `dd if=/dev/urandom count=50 2>/dev/null | md5sum | cut -d ' ' -f1-1` \
      $name",
      refreshonly => true
    }
    file { "/home/$name/.ssh":
      ensure => directory, owner => $name, group => 'users', mode => 700
    }
    file { "/home/$name/.ssh/authorized_keys":
      owner => $name,
      group => 'users',
      source => "puppet:///users/$name.pub",
      mode => 600
    }
  }
}
