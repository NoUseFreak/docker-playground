docker-playground
=================

# Setup

```bash
$ vagrant up
$ vagrant ssh
```

Every time the box is booted it will start the configuration.

Now you can access the project at `http://33.33.33.30/`.

# Configure

See the `docker-compose.yml` for all info about the running containers.

You can alter the file and reload the containers using:

```bash
$ docker-compose -f /vagrant/docker-compose.yml up -d
```

# Tests

```bash
$ docker run -v /vagrant:/code composer composer install
$ docker run -v /vagrant:/code phpunit phpunit
```

# Logs

```bash
$ docker-compose -f /vagrant/docker-compose.yml logs
```
