class ddclient::dyndns inherits ddclient {
  file { "/etc/ddclient/ddclient.conf":
    content => template("ddclient/dyndns.conf.erb"),
    notify => Service["ddclient"],
    require => Class["ddclient"]
  }
}
