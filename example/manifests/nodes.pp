node default { include base }

node mycluster inherits default {
  mycluster { "mycluster.com":
    owner_id => '309622156161',
    access_key_id => '0A4612CSG11CGSFQFA8B',
    secret_access_key => 'x8hN/tc60Y1gAvoxxIHxiCBKpEH88w921y7uhxdm'
  }
}

node "curly.ec2" inherits mycluster {
  mycluster::website { "website": env => "production" }
  mycluster::share_client { "data": server => "larry" }
}

node "larry.ec2" inherits mycluster {
  mycluster::share_server { "data": }
}

node "moe.ec2" inherits mycluster {
  mycluster::database { "production": password => "roor4Qui" }
}
