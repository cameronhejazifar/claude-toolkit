---
title: API Project Setup (Laravel)
description: Steps for setting up a Laravel API project using Docker and Sail.
tags:
  - setup
  - laravel
  - docker
  - sail
  - api
---

# API Project Setup (Laravel)

1. First, make sure Docker Desktop is installed and running on your machine.

2. Run the following in the root directory of the project:

    ```shell
    docker run --rm \
        -v "$(pwd)":/opt \
        -w /opt \
        laravelsail/php84-composer:latest \
        bash -c "laravel new api && cd api && composer require laravel/sail --dev && php artisan sail:install --with=mysql,redis,meilisearch,mailpit && sed -i 's|APP_URL=http://localhost|APP_URL=http://localhost:50300\nAPP_PORT=50300\nVITE_PORT=50301\nFORWARD_DB_PORT=50302\nFORWARD_REDIS_PORT=50303\nFORWARD_MEILISEARCH_PORT=50304\nFORWARD_MAILPIT_PORT=50305\nFORWARD_MAILPIT_DASHBOARD_PORT=50306|' .env"
    ```

3. Now that a Laravel project has been created using Sail in the `api/` directory, run the Docker containers using the sail command:

    ```shell
    cd api
    ./vendor/bin/sail up -d
    ```

    This will start all of the specified containers in Docker with the following ports assigned:

    | Service          | Port  |
    | ---------------- | ----- |
    | App          | 50300 |
    | *Vite        | 50301 |
    | MySQL        | 50302 |
    | Redis        | 50303 |
    | Meilisearch  | 50304 |
    | Mailpit SMTP | 50305 |
    | Mailpit UI   | 50306 |

    > [!note]
    > * **Vite**: port 50301 gets assigned to Vite, but we'll remove this later in [this guide](03-web-project-setup.md) since a front-end isn't needed for the API.

4. At this point, you'll want to go into the `.env` and change the DB_ to something else so that it doesn't use the standard `laravel` database and overwrite or get overwritten by data from another project, since this local database is shared.

    ```yaml
    DB_DATABASE=your_project_name
    ```

    We still need to make sure a few things are done on the first time:

    ```shell
    cd api
    ./vendor/bin/sail up -d
    ./vendor/bin/sail exec mysql mysql -u"root" -p"$(grep '^DB_PASSWORD=' .env | cut -d'=' -f2)" -e "CREATE DATABASE $(grep '^DB_DATABASE=' .env | cut -d'=' -f2); GRANT ALL PRIVILEGES ON $(grep '^DB_DATABASE=' .env | cut -d'=' -f2).* TO '$(grep '^DB_USERNAME=' .env | cut -d'=' -f2)'@'%'; FLUSH PRIVILEGES;"
    ./vendor/bin/sail artisan migrate:fresh
    ```

    The website should now be accessible from `http://localhost:50300`.

5. API Configuration — we need to make sure Laravel is only used as an API, as the web app will be served from a different front-end project (`web`). Run the following to create a `api.php` route file and install Laravel Sanctum:

    ```shell
    cd api

    # Remove web routes
    ./vendor/bin/sail artisan install:api --no-interaction
    rm -fdr routes/web.php
    sed -i '' "/web:.*routes\/web.php/d" bootstrap/app.php

    # Remove Blade files
    rm -fdr resources/views

    # Remove Vue / Vite front-end
    rm -fdr vite.config.js package.json package-lock.json resources/js resources/css node_modules
    ./vendor/bin/sail composer remove laravel/vite-plugin
    sed -i '' "/VITE_PORT/d" compose.yaml
    sed -i '' "/VITE_PORT/d" .env
    ```

    Restart Docker to reflect the changes

    ```shell
    cd api
    ./vendor/bin/sail down
    ./vendor/bin/sail up -d
    ```

6. Setup the `.gitignore` file for this sub-project:

    ```shell
    cd path/to/project/root
    cp .gitignore api/.gitignore
    ```
