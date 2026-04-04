---
title: Web Project Setup (Vue)
description: Steps for setting up a Vue.js web front-end project.
tags:
  - setup
  - vue
  - web
  - frontend
---

# Web Project Setup (Vue)

1. First, make sure Docker Desktop is installed and running on your machine.

2. Run the following in the root directory of the project:

    ```shell
    docker run --rm -it \
        -v "$(pwd)":/opt \
        -w /opt \
        node:22 \
        npm create vue@latest
    ```

    Give the following responses (example uses a project named "Front End")
    ```yaml
    Project name: web
    TypeScript: yes
    Packages:
      [_] JSX Support
      [x] Router (SPA development)
      [x] Pinia (state management)
      [x] Vitest (unit testing)
      [_] End-to-End Testing
      [x] Linter (error prevention)
      [_] Prettier (code formatting)
    Experimental features: none
    Skip example code: yes
    ```

3. After the `web/` project gets created, you'll need to add this `server` block to your `vite.config.ts` file:

    ```typescript
    export default defineConfig({
      plugins: [ ... ],
      ...
      server: {
        host: '0.0.0.0',
        port: 50301,
        strictPort: true,
        hmr: {
          clientPort: 50301,
        },
      }
      ...
    }
    ```

4. Create a Docker-Compose file using the following command:

    ```shell
    cat <<'EOF' > web/docker-compose.yml
    services:
      vue:
        image: node:22-alpine
        working_dir: /app
        ports:
          - "50301:50301"
        volumes:
          - .:/app
          - /app/node_modules
        command: sh -c "npm install && npm run dev"
    EOF
    ```

5. To start up the Docker container, run the following:

    ```shell
    cd web
    docker compose up -d
    ```

6. Add some ESLint stuff

    * Run the following code to install some packages:
        ```shell
        cd web
        docker compose down
        docker compose run --rm vue npm install -D eslint-plugin-vuejs-accessibility
        ```

    * In the `web/eslint.config.ts` file, add this import:
        ```typescript
        import pluginVueA11y from 'eslint-plugin-vuejs-accessibility'
        ```

    * In that same `web/eslint.config.ts`, add this after the `vueTsConfigs.recommended` line:
        ```typescript
        ...pluginVueA11y.configs['flat/recommended'],
        ```

    * Verify the linter works by running:

        ```shell
        cd web && docker compose up -d && docker compose exec vue npm install && docker compose exec vue npx eslint --max-warnings 0 src/
        ```

6. Fill in the Environment (`.env`) file and Environment TypeScript definition (`env.d.ts`) with some basic info:

    ```shell
    cd /path/to/project/root

    cat <<'EOF' > web/.env
    VITE_API_URL=http://localhost:50300
    VITE_APP_NAME=Web App
    EOF

    cat <<'EOF' > web/env.d.ts
    /// <reference types="vite/client" />

    interface ImportMetaEnv {
      readonly VITE_API_URL: string
      readonly VITE_APP_NAME: string
    }

    interface ImportMeta {
      readonly env: ImportMetaEnv
    }
    EOF
    ```

    These values can now be accessed in your code by calling: `import.meta.env.VITE_API_URL`

7. Setup the `.gitignore` file for this sub-project:

    ```shell
    cd /path/to/project/root
    cp .gitignore web/.gitignore
    ```

