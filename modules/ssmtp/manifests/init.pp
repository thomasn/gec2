class ssmtp {
  package { "ssmtp": category => "mail-mta" }

  define setup($login, $password) {
    file { "/etc/ssmtp/ssmtp.conf":
      content => template("ssmtp/ssmtp.conf.erb"), mode => 600
    }
  }
}
