# wordpress-research

## Architecture

## Initial setup

1. Install docker engine and docker compose 2. You can reference this [document](https://docs.docker.com/compose/install/).
2. Run command `docker network create proxy`
3. Launch all docker compose service for dirs: `db`, `proxy`, `apache-wp`, `ng-wp` **sequentially**.

## How to create a new wordpress site?

Take `example.com` as the example. Before config these docker compose, you need to setup DNS record that point `example.com` to curren server public IP, and make sure that ports 80 and 443 are opened.

1. Generate SSL certification file form Let's Encrypt via our docker compose.
   1. Go to dir [proxy](./proxy) and execute the following command: `./create-cert.sh`
   2.  Restart HA proxy server via command: `docker compose restart proxy`
2. Create Database "example_wp":
   1. Login to database docker container via command: `docker exec -it wp_mysql mysql -u root -p`, then keyin password of mysql root.
   2. Type the following command in database CLI:
      ```mysql
      CREATE DATABASE IF NOT EXISTS example_wp CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
      
      -- grant access rights to user
      GRANT ALL PRIVILEGES ON example_wp.* TO 'wp_user'@'%';
      
      flush privileges;
      ```
   3. Update ./db/init.sql with:
      ```sql
      CREATE DATABASE IF NOT EXISTS example_wp CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
      GRANT ALL PRIVILEGES ON example_wp.* TO 'wp_user'@'%';
      ```
3. Create a wordpress container for wordpress:
   1. Go to dir [ng-wp](./ng-wp), add the following config in the service part of docker-compose.yml
      ```docker
      example_wp:
        image: wordpress:php8.1-fpm-alpine
        volumes:
          - ./data/html/example_wp:/var/www/html
          - ./fpm-www.conf:/usr/local/etc/php-fpm.d/www.conf:ro
        depends_on:
          - mysql
        environment:
          WORDPRESS_DB_HOST: mysql
          MYSQL_ROOT_PASSWORD: mysql_root_pass
          WORDPRESS_DB_NAME: example_wp
          WORDPRESS_DB_USER: wp_user
          WORDPRESS_DB_PASSWORD: wp_pass
        restart: always
        networks:
          - proxy
      ```
  1. Launch docker container via command `docker compose up -d --build example_wp`
4. Add Nginx VirtualHost
   1. Go to dir [/ng-wp/nginx_conf/nginx](./ng-wp/nginx_conf/nginx), then create a new VirtualHost configuration file example.com.conf
      ```conf
      server {
        listen 80;
        listen [::]:80;
        access_log off;
        root /var/www/html/example_wp;
        index index.php;
        server_name example.com;
        server_tokens off;
        location / {
          # First attempt to serve request as file, then
          # as directory, then fall back to displaying a 404.
          try_files $uri $uri/ /index.php?$args;
        }
        # pass the PHP scripts to FastCGI server listening on wordpress:9000
        location ~ \.php$ {
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_pass example_wp:9000;
          fastcgi_index index.php;
          include fastcgi_params;
          fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
        }
      }
      ```
  2. Restart nginx server via command `docker compose restart nginx`

## Regular maintenance