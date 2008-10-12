# Copyright 2008 Tim Dysinger
# http://www.opensource.org/licenses/mit-license.php

%w(rubygems ostruct yaml).each { |l| require(l) }

class OpenStruct
  public(:binding)
  def binding ; super end
  def to_hash ; @table.dup end
end
@env = OpenStruct.new

task(:env) do
  @env.merge!(YAML.load(IO.read("env.yml")))
end

Dir['**/*.rake'].each { |f| load(f) }
