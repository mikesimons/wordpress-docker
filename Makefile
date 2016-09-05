wp_content = public_html/wp-content
wp_plugins = $(wp_content)/plugins

.PHONY: all wp-plugins docker-images
all: wp-plugins docker-images

wp-plugins: $(wp_plugins)/redis-cache $(wp_content)/object-cache.php

$(wp_plugins)/redis-cache:
	wget https://downloads.wordpress.org/plugin/redis-cache.1.3.3.zip -O $(wp_plugins)/redis-cache.zip && \
	rm -rf $(wp_plugins)/redis-cache
	unzip redis-cache.zip -d $(wp_plugins)
	rm redis-cache.zip

$(wp_content)/object-cache.php: $(wp_plugins)/redis-cache
	cp $(wp_plugins)/redis-cache/includes/object-cache.php $(wp_content)

docker-images: dockerfiles/wordpress.sha dockerfiles/nginx.sha

wp_files := $(shell find dockerfiles/wordpress/ -print)
dockerfiles/wordpress.sha: $(wp_files)
	cd dockerfiles/wordpress && docker build -t wp-wordpress .
	docker inspect -f '{{.Id}}' wp-wordpress > dockerfiles/wordpress.sha

nginx_files := $(shell find dockerfiles/nginx/ -print)
dockerfiles/nginx.sha: $(nginx_files)
	cd dockerfiles/nginx && docker build -t wp-nginx .
	docker inspect -f '{{.Id}}' wp-nginx > dockerfiles/nginx.sha