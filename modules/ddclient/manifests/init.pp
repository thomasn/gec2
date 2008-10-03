class ddclient {
  package { "ddclient": category => "net-dns" }
  service { "ddclient": enable => true, require => Package["ddclient"] }

  define dyndns($login, $password, add=[]) {
    file { "/etc/ddclient/ddclient.conf":
      content => template("ddclient/dyndns.conf.erb"),
      group => 'ddclient',
      mode => 640,
      before => Service["ddclient"],
      notify => Service["ddclient"]
    }
  }
}
