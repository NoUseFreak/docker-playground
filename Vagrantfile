VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "docker" do |docker|
    docker.vm.box = "ubuntu/trusty64"
    docker.vm.provision "shell", path: "provision.sh", privileged: false
    docker.ssh.forward_agent = true
    docker.vm.network :private_network, ip: "33.33.33.30"
    docker.vm.hostname = 'docker'
    docker.vm.provider :virtualbox do |vb|
        vb.memory = 2048
        vb.cpus = 2
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    docker.vm.synced_folder "./", "/vagrant", nfs: true
  end

end
