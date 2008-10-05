class aws {
  file { "/usr/local/portage/sys-cluster": ensure => directory }
  file { "/usr/local/portage/sys-cluster/ec2-ami-tools":
    source => "puppet:///aws/ec2-ami-tools",
    recurse => true,
    notify => Exec["update-eix"],
    before => Portage::Keywords["ec2-ami-tools"],
    require => File["/usr/local/portage/sys-cluster"]
  }
  file { "/usr/local/portage/sys-cluster/ec2-api-tools":
    source => "puppet:///aws/ec2-api-tools",
    recurse => true,
    notify => Exec["update-eix"],
    before => Portage::Keywords["ec2-api-tools"],
    require => File["/usr/local/portage/sys-cluster"]
  }
  portage::keywords { [ "ec2-api-tools", "ec2-ami-tools" ]:
    category => "sys-cluster", require => Class["ruby"]
  }
  package { [ "ec2-api-tools", "ec2-ami-tools" ]: category => "sys-cluster" }
  exec { "module-loop":
    command => "/bin/echo loop >>/etc/modules.autoload.d/kernel-2.6",
    unless => "/bin/grep loop /etc/modules.autoload.d/kernel-2.6 1>/dev/null"
  }
  exec { "modprobe-loop":
    command => "/sbin/modprobe loop",
    unless => "/sbin/lsmod | grep loop 1>/dev/null",
    require => Class["kernel"]
  }
  ruby::gem { [ "aws-sdb", "aws-s3", "amazon-ec2", "SQS" ]:
    require => Class["ruby"]
  }
}
