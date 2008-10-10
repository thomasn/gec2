class thin {
  include god
  file { "/etc/god/god.conf.d/thin.god":
    source => "puppet:///thin/thin.god.rb", require => Class["god"]
  }

  file { "/u": ensure => directory }
  file { "/u/apps": ensure => "/var/www" }

  file { "/var/www":
    ensure => directory, owner => "nobody", group => "nobody", mode => 2775
  }

  ruby::gem { "thin": }
  file { "/etc/thin": ensure => directory }

  define setup($env = "production", $servers = 3, $port = 3000) {
    include thin
    file { "/etc/thin/$name.yml": content => template("thin/thin.yml.erb") }
  }
}
