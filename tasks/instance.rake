# Copyright 2008 Tim Dysinger
# http://www.opensource.org/licenses/mit-license.php

%w(hpricot erb aws/s3 EC2).each { |l| require(l) }

namespace(:instance) do
  task(:ec2 => :env) do
    @ec2 = EC2::Base.new(@env.to_hash)
  end

  desc("gimme access on ssh")
  task(:ingress => :ec2) do
    # create an ssh ingress for my ip
    cidr = Hpricot(open('http://checkip.dyndns.com').read).at('body').
      inner_text.gsub('Current IP Address: ', '') << '/32'
    begin
      @ec2.authorize_security_group_ingress(:group_name => 'default',
                                            :ip_protocol => 'tcp',
                                            :cidr_ip => cidr,
                                            :from_port => '22',
                                            :to_port => '22')
    rescue EC2::InvalidPermissionDuplicate ; end
  end

  desc("run an instance")
  task(:run, [:zone, :itype, :image, :master, :hostname] =>
       :ingress) do |t, args|
    unless instance_id(args.hostname)
      # create a keypair
      begin
        key = @ec2.create_keypair(:key_name => args.hostname).keyMaterial
        pem = File.expand_path("~/.ssh/#{args.hostname}.pem")
        File.open(pem, "w+") { |f| f.write(key) }
        File.chmod(0600, pem)
      rescue EC2::InvalidKeyPairDuplicate
        puts "Key-pair '#{args.hostname}' already exits"
      end
      # create a host group
      begin
        @ec2.create_security_group(:group_name => args.hostname,
                                   :group_description => args.hostname)
      rescue EC2::InvalidGroupDuplicate
        puts "Security Group '#{args.hostname}' already exits"
      end
      # setup the boothook script
      @env.hostname = args.hostname
      @env.master = args.master
      user_data = ERB.new(IO.read('boot.erb')).result(@env.binding)
      # run the instance
      @ec2.run_instances(:instance_type => args.itype,
                         :image_id => args.image,
                         :key_name => args.hostname,
                         :availability_zone => args.zone,
                         :group_id => ['default', args.hostname],
                         :min_count => 1,
                         :max_count => 1,
                         :user_data => user_data)
      puts(":)")
    end
  end

  def instance_id(name)
    unless @ec2.describe_instances.reservationSet.nil?
      @ec2.describe_instances.reservationSet.item.each do |r|
        r.instancesSet.item.each do |i|
          return i.instanceId if(i.keyName == name &&
                                 i.instanceState.name != 'terminated')
        end
      end
    end
    nil
  end
end
