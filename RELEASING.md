# Relasing a new package version

## Docker setup

```bash
$ docker buildx create \
  --name container-builder \
  --driver docker-container \
  --use --bootstrap
```

## Publish package

Please release the current version of the package by following the steps below:

- have everything you want in `main` branch
- create a release and tag it with the new version number (set as latest release)
- build the tag
  - `$ docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/simonneutert/labradorite-notebook:<VERSIONTAG> --push .
- build latest **main**
  - `docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/simonneutert/labradorite-notebook:main --push .`

The new version should now be available on the [GitHub Container Registry](https://github.com/simonneutert/labradorite-notebook/pkgs/container/labradorite-notebook).

Celebrate 🎉
