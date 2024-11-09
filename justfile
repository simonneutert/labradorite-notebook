default:
  @just --list
  @echo "\n\nAvailabe rake tasks:\n" && bundle exec rake --tasks

dev:
  @docker buildx build -f Dockerfile . -t labra && docker run --rm -it -p"9292:9292" --name labra labra

reset_default_memos:
  @bundle exec rake reset_default_memos

test:
  @docker build -f Dockerfile.test . -t labra-test && docker run --rm -it labra-test

pretty_js:
  @npx prettier --write assets/js/**/*.js

[doc("Publish a new version to ghcr.io with the tag 'main'")]
publish_ghcr_main:
  docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/simonneutert/labradorite-notebook:main --push .

[confirm("Are you sure you want to publish a new version? Please use `just publish_ghcr_version v0.8.9` to specify the version.")]
[doc("Publish a new version to ghcr.io with the specified version including the tag 'latest'")]
publish_ghcr_version version:
  docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/simonneutert/labradorite-notebook:{{version}} -t ghcr.io/simonneutert/labradorite-notebook:latest --push .