class portage {
  file { "/etc/make.conf": content => template("portage/make.conf.erb") }
  file { "/etc/portage/exclude": source => "puppet:///portage/exclude" }
  file { "/usr/local/portage": ensure => directory }
  package { "portage":
    category => "sys-apps",
    require => [ File["/etc/make.conf"],
                 File["/etc/portage/exclude"],
                 File["/usr/local/portage"] ]
  }
  package { "eix": category => "app-portage", require => Package["portage"] }
  cron { "eix-sync":
    command => "/usr/bin/eix-sync 1>&2>/dev/null",
    user => root,
    hour => 7,
    minute => 0,
    require => Package["eix"]
  }
  exec { "update-eix":
    command => "/usr/bin/update-eix 1>&2>/dev/null",
    refreshonly => true,
    require => Package["eix"]
  }

  define keywords($category, $keywords="") {
    exec { "$name-keywords-del":
      command => "/usr/bin/perl -p -i -e 's/^.*$category.$name.*//g' \
                  /etc/portage/package.keywords",
      unless => "/bin/grep '$category/$name $keywords' \
                 /etc/portage/package.keywords 1>/dev/null",
      before => [ Exec["$name-keywords-add"], Package[$name] ],
      notify => Exec["$name-keywords-add"]
    }
    exec { "$name-keywords-add":
      command => "/bin/echo '$category/$name $keywords' \
                  >>/etc/portage/package.keywords",
      refreshonly => true,
      before => [ Exec["$name-keywords-clean"], Package[$name] ],
      notify => Exec["$name-keywords-clean"]
    }
    exec { "$name-keywords-clean":
      command => "/bin/sed '/^$/d' /etc/portage/package.keywords \
                  | /usr/bin/sort >/etc/portage/package.keywords.tmp && \
                  /bin/mv /etc/portage/package.keywords.tmp \
                  /etc/portage/package.keywords",
      refreshonly => true,
      before => Package[$name]
    }
  }

  define use($category, $use) {
    exec { "$name-use-del":
      command => "/usr/bin/perl -p -i -e 's/^.*$category.$name.*//g' \
                  /etc/portage/package.use",
      unless => "/bin/grep '$category/$name $use' /etc/portage/package.use \
                 1>/dev/null",
      notify => Exec["$name-use-add"],
      before => [ Exec["$name-use-add"], Package[$name] ]
    }
    exec { "$name-use-add":
      command => "/bin/echo '$category/$name $use' >>/etc/portage/package.use",
      refreshonly => true,
      notify => Exec["$name-use-clean"],
      before => [ Exec["$name-use-clean"], Package[$name] ]
    }
    exec { "$name-use-clean":
      command => "/bin/sed '/^$/d' /etc/portage/package.use \
                  | /usr/bin/sort >/etc/portage/package.use.tmp && \
                  /bin/mv /etc/portage/package.use.tmp \
                  /etc/portage/package.use",
      refreshonly => true,
      before => Package[$name]
    }
  }

  define unmask($category) {
    exec { "$name-unmask-del":
      command => "/usr/bin/perl -p -i -e 's/^.*$category.$name.*//g' \
                  /etc/portage/package.unmask",
      unless => "/bin/grep '$category/$name' /etc/portage/package.unmask \
                 1>/dev/null",
      notify => Exec["$name-unmask-add"],
      before => [ Exec["$name-unmask-add"], Package[$name] ]
    }
    exec { "$name-unmask-add":
      command => "/bin/echo '$category/$name' >>/etc/portage/package.unmask",
      refreshonly => true,
      notify => Exec["$name-unmask-clean"],
      before => [ Exec["$name-unmask-clean"], Package[$name] ]
    }
    exec { "$name-unmask-clean":
      command => "/bin/sed '/^$/d' /etc/portage/package.unmask \
                  | /usr/bin/sort >/etc/portage/package.unmask.tmp && \
                  /bin/mv /etc/portage/package.unmask.tmp \
                  /etc/portage/package.unmask",
      refreshonly => true,
      before => Package[$name]
    }
  }
}