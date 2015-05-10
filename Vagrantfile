VAGRANTFILE_API_VERSION = "2"

$script = <<SCRIPT
# Update system and install dependencies
echo "Installing dependencies"
sudo apt-get update #>> /dev/null
sudo apt-get upgrade -y #>> /dev/null

# Install docker
echo "Installing docker"
wget -qO- https://get.docker.com/ | sh #>> /dev/null

# Docker configuration
sudo usermod -aG docker vagrant

# Echo welcome
#sudo docker run hello-world

# Prepare data dir
sudo mkdir -m 777 -p /var/docker/data

# Install compose
sudo wget https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` -O /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "docker" do |docker|
    docker.vm.box = "ubuntu/trusty64"
    docker.vm.provision "shell", inline: $script, privileged: false
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
