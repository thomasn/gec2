class nginx {
  package { "nginx":
    category => "www-servers", before => File["/etc/nginx"]
  }
  file { "/etc/nginx":
    source => "puppet:///nginx/nginx",
    recurse => true,
    before => Service["nginx"]
  }
  service { "nginx": enable => true, ensure => running }

  define setup($app, $servers = "3", $port = "3000") {
    include nginx
    file { "/etc/ssl/$name":
      source => "puppet:///nginx/ssl",
      recurse => true,
      before => Service["nginx"]
    }
    file { "/etc/nginx/nginx.conf.d/$name.conf":
      content => template("nginx/site.conf.erb"),
      notify => Service["nginx"],
      before => Service["nginx"]
    }
  }
}
