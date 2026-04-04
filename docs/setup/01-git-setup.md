---
title: Git Setup
description: Steps for initializing Git and configuring .gitignore for a new project.
tags:
  - setup
  - git
  - gitignore
---

# Git Setup

1. In Terminal, from within your project directory, run:

    ```shell
    git init
    ```

2. Create a `.gitignore` file by going to Toptal's [gitignore.io](https://www.toptal.com/developers/gitignore?templates=macos,windows,linux,phpstorm+all,intellij,androidstudio,webstorm,jetbrains,xcode,visualstudio,visualstudiocode,dbeaver,obsidian,sublimetext,notepadpp,git,node,laravel,symfony,vue,vuejs,react,reactnative,swift,objective-c,flutter,java,kotlin,composer,swiftpackagemanager,wordpress) and enter the following OSs, packages, languages, etc:

    - macOS
    - Windows
    - Linux
    - PhpStorm
    - Intellij
    - AndroidStudio
    - WebStorm
    - JetBrains
    - nova
    - Xcode
    - VisualStudio
    - VisualStudioCode
    - DBeaver
    - Obsidian
    - SublimeText
    - NotepadPP
    - Git
    - Node
    - Laravel
    - Symfony
    - Vuejs
    - Vue
    - react
    - ReactNative
    - Swift
    - Objective-C
    - Flutter
    - Java
    - Kotlin
    - Composer
    - SwiftPackageManager
    - yarn
    - dotenv
    - PHPUnit
    - WordPress

3. Once you've generated the `.gitignore` file, there are some additional things to add to it that the Toptal site doesn't account for:

    ```gitignore
    # Start of custom .gitignore attributes

    ### Claude ###
    # Claude Code
    .claude/
    .claudeignore

    ### Docker ###
    docker-compose.override.yml
    .docker/
    *.tar

    ### Redis ###
    dump.rdb

    ### MariaDB / MySQL ###
    *.sql.gz

    ### PHP ###
    .php-cs-fixer.cache
    .phpunit.cache/

    ### Laravel IDE Helper ###
    _ide_helper.php
    _ide_helper_models.php
    .phpstorm.meta.php

    ### Vite ###
    *.local

    ### Additional configuration ###
    .env.backup
    .env.production
    .phpactor.json
    /.fleet
    /.zed
    /auth.json
    /public/build
    /storage/pail

    # End of custom .gitignore attributes
    ```

    > [!tip]
    > You can also use this project's `.gitignore` file as an example. BUT if you do, make sure to remove the bottom section that only applies to this specific project.
