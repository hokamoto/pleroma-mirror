# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "forwarded_port", guest: 4000, host: 4000
  
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    wget -P /tmp/ https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i /tmp/erlang-solutions_1.0_all.deb
    sudo apt-get update
    sudo apt-get install -y postgresql postgresql-contrib build-essential openssl ssh sudo elixir erlang-dev erlang-parsetools erlang-xmerl erlang-tools

    cd /vagrant
    mix local.hex --force
    mix local.rebar --force
    mix deps.get
	
	# TODO: do we need this, or can we fake one up?
    mix generate_dev_config
    cp config/generated_config.exs config/dev.secret.exs
    sudo su postgres -c 'psql -f config/setup_db.psql'
    mix ecto.migrate
  SHELL
  
  config.vm.provision "shell", run: 'always', privileged: false, inline: <<-SHELL
    echo "To start server:"
	echo '$ vagrant ssh -c "cd /vagrant && mix phx.server"'
  SHELL
end
