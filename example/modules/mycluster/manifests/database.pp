define mycluster::database($password) {
  mysql::setup { "mycluster_$name":
    db_user => "mycluster", db_pass => $password
  }
}
