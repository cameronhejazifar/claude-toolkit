# Sail Commands

Run all commands from the `api/` directory. Pass `--no-interaction` to all Artisan commands.

## Port Mapping

| Service | Port |
|---------|------|
| App | 50300 |
| MySQL | 50302 |
| Redis | 50303 |
| Meilisearch | 50304 |
| Mailpit SMTP | 50305 |
| Mailpit UI | 50306 |

## Commands

```shell
./vendor/bin/sail up -d                          # start
./vendor/bin/sail down                           # stop
./vendor/bin/sail artisan <command>               # artisan
./vendor/bin/sail artisan migrate                 # migrate
./vendor/bin/sail artisan db:seed                 # seed
./vendor/bin/sail test                            # test
./vendor/bin/sail composer require <package>      # install package (never edit composer.json)
./vendor/bin/sail artisan make:model <Name> -mfs  # generate model + migration + factory + seeder
./vendor/bin/sail artisan make:controller <Name>Controller
./vendor/bin/sail artisan make:request <Name>Request
./vendor/bin/sail artisan make:resource <Name>Resource
./vendor/bin/sail artisan make:test <Name>Test
```

## After Significant Changes

```shell
./vendor/bin/sail down && ./vendor/bin/sail up -d && ./vendor/bin/sail artisan migrate && ./vendor/bin/sail artisan db:seed
```
