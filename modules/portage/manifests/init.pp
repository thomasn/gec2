class portage {
  file { "/etc/make.conf": content => template("portage/make.conf.erb") }

  file { "/usr/local/portage": ensure => directory }
  package { "portage":
    category => "sys-apps",
    require => [ File["/etc/make.conf"], File["/usr/local/portage"] ]
  }

  package { [ "eix", "gentoolkit" ]:
    category => "app-portage", require => Package["portage"]
  }
  cron { "eix-sync":
    command => "/usr/bin/eix-sync 1>&2>/dev/null",
    user => root,
    hour => 7, # UTC 0700 is night in the US
    minute => 0,
    require => Package["eix"]
  }
  exec { "update-eix":
    command => "/usr/bin/update-eix 1>&2>/dev/null",
    refreshonly => true,
    require => Package["eix"]
  }

  file { "/etc/portage/package.use": ensure => file }
  exec { "emerge-newuse":
    command => "/usr/bin/emerge --deep --newuse --update world",
    refreshonly => true,
    subscribe => File["/etc/portage/package.use"],
    notify => Exec["emerge-revdep"]
  }
  exec { "emerge-revdep":
    command => "/usr/bin/revdep-rebuild",
    require => Package["gentoolkit"],
    refreshonly => true
  }

  define keywords($category, $keywords="") {
    exec { "$name-keywords":
      command => "/usr/bin/perl -p -i -e 's/^.*$category.$name.*//g' \
                      /etc/portage/package.keywords && \
                  /bin/echo '$category/$name $keywords' \
                      >>/etc/portage/package.keywords && \
                  /bin/sed '/^$/d' /etc/portage/package.keywords | \
                      /usr/bin/sort >/etc/portage/package.keywords.tmp && \
                  /bin/mv /etc/portage/package.keywords.tmp \
                      /etc/portage/package.keywords",
      unless => "/bin/grep '$category/$name $keywords' \
                     /etc/portage/package.keywords 1>/dev/null",
      before => Package[$name]
    }
  }

  define use($category, $use) {
    exec { "$name-use":
      command => "/usr/bin/perl -p -i -e 's/^.*$category.$name.*//g' \
                      /etc/portage/package.use && \
                  /bin/echo '$category/$name $use' >>/etc/portage/package.use && \
                  /bin/sed '/^$/d' /etc/portage/package.use | \
                      /usr/bin/sort >/etc/portage/package.use.tmp && \
                  /bin/mv /etc/portage/package.use.tmp /etc/portage/package.use",
      unless => "/bin/grep '$category/$name $use' /etc/portage/package.use \
                     1>/dev/null",
      before => Package[$name]
    }
  }

  define unmask($category) {
    exec { "$name-unmask":
      command => "/usr/bin/perl -p -i -e 's/^.*$category.$name.*//g' \
                      /etc/portage/package.unmask && \
                  /bin/echo '$category/$name' >>/etc/portage/package.unmask && \
                  /bin/sed '/^$/d' /etc/portage/package.unmask | \
                      /usr/bin/sort >/etc/portage/package.unmask.tmp && \
                  /bin/mv /etc/portage/package.unmask.tmp \
                      /etc/portage/package.unmask",
      unless => "/bin/grep '$category/$name' /etc/portage/package.unmask \
                     1>/dev/null",
      before => Package[$name]
    }
  }
}
