---
title: Claude Setup
description: Steps for setting up Claude Code configuration in a project.
tags:
  - setup
  - claude
---

# Claude Setup

This guide covers how to configure Claude Code for the monorepo. It utilizes a root `CLAUDE.md` and then more `CLAUDE.md` files within each sub-repo for specific instructions that relate to that stack. The `api/CLAUDE.md` will get generated automatically by Laravel Boost, so we'll instead put those instructions inside the `api/.ai/guidelines` files so Boost will auto-integrate them into the generated file.

## 1. Copy files

Copy the CLAUDE.md and guideline files to your project root

```shell
cp .claude/docs/config/base-claude.md CLAUDE.md
cp .claude/docs/config/vue-claude.md web/CLAUDE.md
mkdir -p api/.ai/guidelines
cp -r .claude/docs/config/laravel-ai-guidelines/* api/.ai/guidelines/
```

The `settings.json` file is already where it should be, assuming you have this project checked out in the `.claude` directory.

## 2. Laravel Boost

This will use Laravel Boost to generate a CLAUDE.md file for the `api` project. To do this, run:

```shell
cd api
./vendor/bin/sail composer require laravel/boost --dev
./vendor/bin/sail artisan boost:install
```

When presented with questions during the installation, use these settings:
- Which Boost features would you like to configure?
  - [x] AI Guidelines
  - [x] Agent Skills
  - [x] Boost MCP Server Configuration
- Which AI agents would you like to configure?
  - [ ] Amp
  - [x] Claude code
  - [ ] Codex
  - [ ] Cursor
  - [ ] Gemini CLI
  - [ ] GitHub Copilot
  - [ ] Junie
  - [ ] OpenCode


To update Laravel Boost later on, you can run:

```shell
cd api && ./vendor/bin/sail artisan boost:update
```


## 3. Plugins / Skills / Commands

1. [GSD / Get Shit Done](https://github.com/gsd-build/get-shit-done)

    Follow the instructions [here](https://github.com/gsd-build/get-shit-done?tab=readme-ov-file#getting-started) to install this via `npx`. Commands should be available using the Claude CLI. A list of commands can be found [here](https://github.com/gsd-build/get-shit-done?tab=readme-ov-file#commands).

2. [Context7 MCP](https://github.com/upstash/context7)

    Install the package by running:

    ```shell
    claude mcp add context7 --transport stdio --scope project -- npx -y @upstash/context7-mcp@latest
    ```

    This will add to your `.mcp.json` file. We've already allowed it in the `.claude/settings.json` file and the `web/CLAUDE.md` already has instructions on how to use it.

3. [Excalidraw](https://github.com/coleam00/excalidraw-diagram-skill)

    Clone the repo, then copy it into the project's skills directory:

    ```shell
    git clone https://github.com/coleam00/excalidraw-diagram-skill.git
    mkdir -p .claude/skills
    cp -r excalidraw-diagram-skill .claude/skills/excalidraw-diagram
    rm -fdr excalidraw-diagram-skill
    ```

    Colors can be modified in the `color-palette.md` file in the skill.

    You can now create diagrams by running something like:

    ```text
    Create an Excalidraw diagram that maps out everything defined in the .claude/docs/specs/foundation.md file
    ```

## 4. Hooks

We need to setup some post-edit hooks that format code. We'll use `pint` for PHP and `eslint` for the frontend js/vue/css stuff.

First, you'll need to make the hooks executable:

```shell
chmod +x .claude/hooks/post-edit-pint.sh
chmod +x .claude/hooks/post-edit-eslint.sh
```

The hooks should already be added to your `settings.json` file, so you should be good to go now.

You can test pint by running this and the output should be "0":

```shell
echo "{\"tool_input\":{\"file_path\":\"$(pwd)/api/app/Models/User.php\"},\"cwd\":\"$(pwd)\"}" | .claude/hooks/post-edit-pint.sh
echo $?
```

You can test ESLint by running this and the output should be "0":

```shell
echo "{\"tool_input\":{\"file_path\":\"$(pwd)/web/src/App.vue\"},\"cwd\":\"$(pwd)\"}" | .claude/hooks/post-edit-eslint.sh
echo $?
```

## 5. Finish Project Initialization

Now that everything is setup, we need to make sure that the project adheres to all of the specifications and instructions that we've defined.

There are some spec files in `.claude/docs/specs` that can be copied to your project and used to do this.

Now we can open claude by running `claude` from the project directory and execute this prompt to initialize the project with the specs defined in the `foundation` document:

```text
Read .claude/docs/specs/foundation.md and implement everything defined in it. This is the first development task after manual project setup — no feature code exists yet.

Work through the spec in order: API first (sections 1-16), then Web (sections 1-11). Write tests before implementation per our TDD approach. Run the full test suite after completing each sub-project to verify everything passes before moving to the next.

Do not skip any section. If something is unclear or you need a decision, stop and ask.
```

> [!todo]
> skills, commands, etc.
>
> Plugins:
> - Firecrawl — [Docs](https://www.firecrawl.dev/blog/firecrawl-official-claude-plugin)
> - GitHub CLI — [Setup Instructions](https://youtu.be/OFyECKgWXo8?si=9oyi58zaq6Fi7SGJ)
> - Playwright CLI — [Setup Instructions](https://youtu.be/OFyECKgWXo8?si=9oyi58zaq6Fi7SGJ)
> - Obsidian Integration — [Setup Instructions](https://youtu.be/OFyECKgWXo8?si=9oyi58zaq6Fi7SGJ)
