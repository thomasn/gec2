define mycluster($owner_id, $access_key_id, $secret_access_key) {
  # users - this is here to dynamically assign groups
  class tim inherits users::tim {
    Account["tim"] { groups => [ "wheel", "nobody" ] }
    realize(Account["tim"])
  }
  include tim

  # dns - dyndns & ec2 metadata do the trick
  Ddclient::Dyndns { login => "myclusterdyndns", password => "faiyah4D" }
  ddclient::dyndns { "$hostname.mycluster.com": }
  cron { "hosts":
    command => "/usr/local/sbin/hosts \
                  -a $access_key_id -s $secret_access_key >/etc/hosts",
    user => root,
    minute => 0
  }

  # use gmail for outgoing mail
  ssmtp::setup { $name: login => "mygmailuser", password => "OoQu4rei" }

  # s3 mounts - simple filesystem over s3
  S3fs::Mount {
    access_key_id => $access_key_id, secret_access_key => $secret_access_key
  }
  s3fs::mount { $name: }

  # backup (make an automatic backup image each week)
  file { "/etc/ec2":
    source => "puppet:///mycluster/ec2", recurse => true, mode => 700
  }
  file { "/mnt/tmp": ensure => directory }
  cron { "backup":
    command => "/usr/bin/ec2-bundle-vol -b \
                  -d /mnt/tmp -p $hostname-`date -I` \
                  -u $owner_id -k /etc/ec2/key.pem -c /etc/ec2/cert.pem && \
                /usr/bin/ec2-upload-bundle -b $name \
                  -a $access_key_id -s $secret_access_key \
                  -m /mnt/tmp/$hostname.`date -I`.manifest.xml \
                  --url http://s3.amazonaws.com && \
                /bin/rm -rf /mnt/tmp/$hostname*",
    user => root,
    weekday => 0,
    hour => 7,
    minute => 30
  }
}
