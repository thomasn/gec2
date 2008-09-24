class ssh {
  package { "openssh": category => "net-misc", before => Service["sshd"] }
  file { "/etc/ssh/sshd_config":
    source => "puppet:///ssh/sshd_config",
    mode => 600,
    before => Service["sshd"]
  }
  service { "sshd": enable => true }
}
