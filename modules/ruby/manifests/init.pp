class ruby {
  package::keywords { "ruby": category => "dev-lang" }
  package::unmask { "ruby": category => "dev-lang" }
  package { "ruby": category => "dev-lang" }

  package::keywords { "rubygems": category => "dev-ruby" }
  package { "rubygems": category => "dev-ruby", require => Package["ruby"] }
}
