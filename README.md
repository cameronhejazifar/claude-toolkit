---
title: Claude Toolkit
description: A development toolkit for Claude Code that provides stack setup guides, installation instructions, and enhanced context to improve AI-assisted development workflows for personal projects.
---

## Installation

To start a project, create the root directory you want to work out of and add this project to the `.claude` directory within that:
```shell
mkdir /path/to/my/project
cd /path/to/my/project
git clone git@github.com:cameronhejazifar/claude-toolkit.git .claude
```

Once you have that added to your `.claude` directory, follow the [Project Setup](docs/setup/00-project-setup.md) guide for creating a project from scratch

## Deployment Scripts

These scripts can be used after installation and setup to quickly reference the commands for starting up each environment.

* API (Laravel Backend)

    ```shell
    cd api && ./vendor/bin/sail up -d && ./vendor/bin/sail artisan migrate
    ```

* Web (Vue Frontend)
    ```shell
    cd web && docker compose up -d
    ```
