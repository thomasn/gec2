class mycluster::mailserver inherits mycluster::codewell {
  class rm_ssmtp inherits ssmtp {
    Package["ssmtp"] { ensure => absent, before => Package["postfix"] }
  }
  include rm_ssmtp

  package { "postfix": category => "mail-mta", before => Service["postfix"] }
  service { "postfix": enable => true, ensure => running }
}
