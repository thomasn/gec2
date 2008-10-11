class postfix {
  portage::use { "postfix": category => "mail-mta", use => "sasl" }
  package { "postfix": category => "mail-mta", before => Service["postfix"] }
  service { "postfix": enable => true, ensure => running }
}
