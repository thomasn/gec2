class ruby {
  portage::keywords { "ruby": category => "dev-lang" }
  portage::unmask { "ruby": category => "dev-lang" }
  package { "ruby": category => "dev-lang" }

  portage::keywords { "rubygems": category => "dev-ruby" }
  package { "rubygems": category => "dev-ruby", require => Package["ruby"] }

  define gem($version = installed) {
    package { $name: provider => gem, ensure => $version }
  }
}
