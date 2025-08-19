# Upgrading Labradorite

## To Version v0.6.0

The `tantiny` dependency and Rust are dropped in favor of a new implementation using SQLite3 and FTS5.

Everything should work as before, but beware that bugs may pop up due to the new implementation.

No migration or dataloss is expected, but it is always a good idea to back up your data before upgrading.

## To Version v0.5.0

Development on Mac OS X is no longer supported. 

See https://github.com/baygeldin/tantiny/issues/21 for more information.

Please use a Linux machine for development (or Docker).

When using Docker, you can run the following command to test the development environment:

```bash
just test
```

running the project:

```bash
just dev
```
