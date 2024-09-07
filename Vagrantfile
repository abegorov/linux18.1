# -*- mode: ruby -*-
# vi: set ft=ruby :

MACHINES = {
  :'selinux' => {
    :domain => 'internal',
    :box => 'almalinux/9/v9.4.20240805',
    :cpus => 1,
    :memory => 1024,
    :networks => [
      [
        :forwarded_port, {
          :guest => 4881,
          :host_ip => '127.0.0.1',
          :host => 4881
        }
      ]
    ]
  }
}

Vagrant.configure("2") do |config|
  MACHINES.each do |host_name, host_config|
    config.vm.define host_name do |host|
      host.vm.box = host_config[:box]
      host.vm.host_name = host_name.to_s + '.' + host_config[:domain].to_s

      host.vm.provider :virtualbox do |vb|
        vb.cpus = host_config[:cpus]
        vb.memory = host_config[:memory]
      end

      host_config[:networks].each do |network|
        host.vm.network(network[0], **network[1])
      end

      host.vm.provision :shell do |shell|
        shell.path = 'provision.sh'
        shell.privileged = true
      end
    end
  end
end
