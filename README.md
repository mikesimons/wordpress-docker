# Wordpress in docker

I'm experimenting with wordpress in docker to produce both a solid deployment basis and workflow.

Right now the setup consists of WP4.6, MariaDB 10.x, Redis 3.x, the latest blackfire probe and agent and nginx 1.11.

You should be able to start it yourself (if you have docker & docker-compose available locally) with:

```
docker-compose up
```

The site should be available on `https://localhost:3000`.
If that doesn't work and there are no errors, try adding `local.dev` to the `127.0.0.1` entry in your hosts file and trying `https://local.dev:3000`.

## Components
### Wordpress

No specific tuning has been done to wordpress other than installing the redis-object cache extension.
One of the aims of this experiment is to maximize dynamic performance before resorting to a static cache so no cache plugins are installed.

Plugin installation is performed in the Makefile.

### Nginx

Nginx is configured for HTTP2 and HTTPS. It will not serve HTTP. This is so we can leverage all the SPDY / H2 goodness.
Certs were generated with certstrap for `local.dev`; if you'd like to generate a self signed cert for something else:

```
go get github.com/square/certstrap
certstrap --depot-path ssl request-cert --cn my-domain.dev
certstrap --depot-path ssl sign my-domain.dev --CA local-ca
```

### Wordpress

The wordpress container is dervied from the stock php7-fpm dockerhub image with a few tweaks.

- MySQLi / PDO MySQL extensions enabled
- Blackfire probe installed
- OpCache enabled
- wp-cli installed for cli inspection

php-fpm runs as www-data so it does not have write perms on any folders.
My intention is to keep it that way as far as possible and specifically use a volume for uploads.
I may experiment with a writable FS & periodic `docker commit` / `docker diff` commands to keep track of changes.
If the filesystem is kept read-only then admin functions that attempt disk writes will be hidden.
This may also require some mechanism to periodically check / update the plugin versions as part of the build process.

There is a custom pool config but nothing major has been tweaked.

### Docker

I'm testing with docker engine 1.12 on ubuntu 16.04. The only change to docker config I have made is to enable hairpin nat (`--userland-proxy false` option to `dockerd`).

While load testing I found that `docker-proxy` was consuming a fair amount of CPU cycles (~30%) trying to keep up.

### Others
Redis, MariaDB & Blackfire agent are all stock images from dockerhub.

## Process / pipeline
So far the entire build process is happening with Make.
I've rigged the docker builds so that any changes to dockerfiles or context files will cause a rebuild.
