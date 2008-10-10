define mycluster::website($env) {
  include mysql::ruby

  nginx::setup { "mycluster.com": app => "website" }
  thin::setup { "website": env => $env }

  # http://rmagick.rubyforge.org/install-linux.html
  portage::use { 'imagemagick':
    category => 'media-gfx',
    use => "-X -bzip2 -djvu -doc fontconfig -fpx -graphviz gs -cups -hdri -jbig jpeg -jpeg2k -lcms -mpeg nocxx -openexr -openmp -perl png -q32 q8 -svg -tiff truetype wmf xml zlib"
  }
  package { 'imagemagick':
    category => 'media-gfx', before => Ruby::Gem["rmagick"]
  }
  ruby::gem { 'acts_as_reportable': version => "1.1.1" }
  ruby::gem { 'fastercsv':
    version => "1.2.3",
    before => Ruby::Gem["acts_as_reportable"]
  }
  ruby::gem { 'hpricot': version => "0.6.161" }
  ruby::gem { 'rmagick': version => "2.6.0" }
  ruby::gem { 'timedcache': version => "0.2" }
}
