default:
  @just --list
  @echo "\n\nAvailabe rake tasks:\n" && bundle exec rake --tasks

dev:
  @docker buildx build -f Dockerfile . -t labra && docker run --rm -it -p"9292:9292" --name labra labra

reset_default_memos:
  @bundle exec rake reset_default_memos

test:
  @docker buildx build -f Dockerfile.test . -t labra-test && docker run --rm -it --name labra-test labra-test

pretty_js:
  @npx prettier --write assets/js/**/*.js
