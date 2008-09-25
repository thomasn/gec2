class mysql::ruby {
  include ruby
  package { "mysql-ruby": category => "dev-ruby" }
}
