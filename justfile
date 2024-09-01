default:
  @just --list

pretty_js:
  @npx prettier --write assets/js/**/*.js
