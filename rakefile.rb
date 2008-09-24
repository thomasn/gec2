# Copyright 2008 Tim Dysinger
# http://www.opensource.org/licenses/mit-license.php

%w(rubygems open-uri ostruct hpricot erb aws/s3 EC2 facter yaml).each do |l|
  require(l)
end

######################################################################
# Monkey Patches
######################################################################

class OpenStruct
  def merge(other) ; OpenStruct.new(@table.merge(other.to_hash)) end
  def merge!(other) ; @table.merge!(other.to_hash) ; self end
  def to_hash ; @table.dup end
end

@env = OpenStruct.new
def method_missing(m) ; @env.send(m) end

######################################################################
# Image
######################################################################

desc('bootstrap, configure, bundle and upload')
task(:image => :upload)

def chroot(*a)
  script = ['env-update', 'source /etc/profile', a].flatten.join(" && \n")
  File.open('/mnt/gentoo/tmp/rake.sh', 'w')  { |f| f.write script }
  sh('chroot /mnt/gentoo /bin/bash /tmp/rake.sh')
ensure
  rm('/mnt/gentoo/tmp/rake.sh')
end

task(:env) do
  @env.merge!(YAML.load(IO.read("env.yml")))
  @ec2 = EC2::Base.new(@env.to_hash)
end

task(:facts => :env) do
  Facter.search('modules/base/plugins/facter')
  Facter.loadfacts
  Facter.collection.each { |k, v| @env.send("#{k}=", v) }
end

file_create('/tmp/stage3-2008.0.tar.bz2' => :facts) do
  sh('wget -O /tmp/stage3-2008.0.tar.bz2 ' <<
     'http://gentoo.osuosl.org/releases/' <<
     "#{@env.architecture =~ /i386/ ? 'x86' : 'amd64'}/current/stages/" <<
     "stage3-#{@env.architecture =~ /i386/ ? 'i686' : 'amd64'}-2008.0.tar.bz2")
end

file_create('/mnt/gentoo' => '/tmp/stage3-2008.0.tar.bz2') do
  mkdir_p('/mnt/gentoo')
  sh('tar -vxjf /tmp/stage3-2008.0.tar.bz2 -C /mnt/gentoo')
  cp('/etc/mtab', '/mnt/gentoo/etc')
  cp('/etc/resolv.conf', '/mnt/gentoo/etc')
  File.open('/mnt/gentoo/etc/make.conf', 'w') do |f|
    f.write(ERB.new(IO.read('modules/system/templates/make.conf.erb')).
            result(binding))
  end
  mkdir('/mnt/gentoo/etc/portage')
  mkdir('/mnt/gentoo/usr/local/portage')
  cp('modules/system/files/exclude', '/mnt/gentoo/etc/portage')
  File.open('/mnt/gentoo/etc/portage/package.keywords', 'w') do |f|
    f.write("app-admin/puppet\n")
    f.write("dev-lang/ruby\n")
    f.write("dev-ruby/facter\n")
    f.write("dev-ruby/rubygems\n")
  end
  File.open('/mnt/gentoo/etc/portage/package.unmask', 'w') do |f|
    f.write("dev-lang/ruby\n")
  end
end

file_create('/mnt/gentoo/proc/cpuinfo' => '/mnt/gentoo') do
  sh('mount -t proc none /mnt/gentoo/proc')
end

file_create('/mnt/gentoo/dev/random' => '/mnt/gentoo') do
  sh('mount -o bind /dev /mnt/gentoo/dev')
end

desc('bootstrap gentoo for ec2')
task(:bootstrap => '.bootstrap.')
file_create('.bootstrap.' => ['/mnt/gentoo/proc/cpuinfo',
                              '/mnt/gentoo/dev/random']) do
  chroot('rm -rf /tmp && ln -sf /var/tmp /tmp',
         'groupmems -p -g users',
         "usermod -p `dd if=/dev/urandom count=50 2>/dev/null" <<
         " | md5sum | cut -d ' ' -f1-1` root",
         'emerge --sync',
         'echo CONFIG_PROTECT=\"-*\" >>/etc/make.conf',
         'emerge -e -k system',
         "perl -p -i -e 's/^CONFIG_PROTECT.*//g' /etc/make.conf",
         'update-ca-certificates',
         'python-updater',
         'hash -r',
         'emerge -k gentoolkit',
         'revdep-rebuild',
         'emerge --depclean',
         'eclean packages',
         'eclean distfiles',
         'emerge -k vixie-cron rubygems',
         'emerge -k puppet')
  touch('.bootstrap.')
end

desc('configure gentoo with the basics')
task(:configure => '.configure.')
file_create('.configure.' => '.bootstrap.') do
  unless File.exists?('/mnt/gentoo/tmp/ge2c')
    cp_r(Dir.pwd, "/mnt/gentoo/tmp/")
    cp("modules/puppet/files/fileserver.conf",
       "/mnt/gentoo/tmp/gec2/")
  end
  unless File.exists?('/mnt/gentoo/tmp/gec2/run/puppetmasterd.pid')
    chroot('puppetmasterd -vd --confdir /tmp/gec2 --vardir /tmp/gec2 \
            --autosign true')
  end
  chroot('puppetd --confdir /tmp/gec2 --vardir /tmp/gec2 \
          --server `hostname -f` --no-daemonize --test -d \
          --pluginsync true --factpath /tmp/gec2/lib/facter')
  if File.exists?('/mnt/gentoo/tmp/gec2/run/puppetmasterd.pid')
    sh('kill `cat /mnt/gentoo/tmp/gec2/run/puppetmasterd.pid`')
  end
  touch('.configure.')
end

desc('bundle the gentoo image for ec2')
task(:bundle => '/mnt/gentoo/tmp/image.manifest.xml')
file_create('/mnt/gentoo/tmp/image.manifest.xml' => '.configure.') do
  File.open('/mnt/gentoo/tmp/key.pem', 'w') do |f|
    f.write(@env.key.strip)
  end
  File.open('/mnt/gentoo/tmp/cert.pem', 'w') do |f|
    f.write(@env.cert.strip)
  end
  chroot("ec2-bundle-vol -b -u #{@env.owner_id} " <<
         "-k /tmp/key.pem -c /tmp/cert.pem " <<
         "-a -e /root,/dev,/proc,/sys,/tmp,/var/tmp,/mnt " <<
         "--no-inherit -r #{@env.architecture} " <<
         "--fstab /etc/fstab --kernel #{@env.ec2_kernel_id} -d /tmp")
end

desc('upload the gentoo bundle to s3')
task(:upload => '.upload.')
file_create('.upload.' => '/mnt/gentoo/tmp/image.manifest.xml') do
  bname = "gentoo-#{@env.ec2_instance_type}-#{@env.ec2_instance_cpu}"<<
    "-#{Time.now.to_f}"
  AWS::S3::Base.establish_connection!(:access_key_id =>
                                      @env.access_key_id,
                                      :secret_access_key =>
                                      @env.secret_access_key)
  AWS::S3::Bucket.create(bname)
  chroot("ec2-upload-bundle -b #{bname} -a #{@env.access_key_id} " <<
         "-s #{@env.secret_access_key} -m /tmp/image.manifest.xml ",
         "ec2-register -K /tmp/key.pem -C /tmp/cert.pem " <<
         "#{bname}/image.manifest.xml")
  touch('.upload.')
end
