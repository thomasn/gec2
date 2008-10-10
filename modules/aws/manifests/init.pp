class aws {
  portage::overlay { [ "ec2-ami-tools", "ec2-api-tools" ]:
    category => "sys-cluster", source => "aws"
  }
  portage::keywords { [ "ec2-ami-tools", "ec2-api-tools" ]:
    category => "sys-cluster",
    require => [
      Class["ruby"],
      Portage::Overlay["ec2-ami-tools"],
      Portage::Overlay["ec2-api-tools"]
    ]
  }
  package { [ "ec2-ami-tools", "ec2-api-tools" ]: category => "sys-cluster" }
  exec { "module-loop":
    command => "/bin/echo loop >>/etc/modules.autoload.d/kernel-2.6",
    unless => "/bin/grep loop /etc/modules.autoload.d/kernel-2.6 1>/dev/null"
  }
  exec { "modprobe-loop":
    command => "/sbin/modprobe loop",
    unless => "/sbin/lsmod | grep loop 1>/dev/null",
    require => Class["kernel"]
  }
}
