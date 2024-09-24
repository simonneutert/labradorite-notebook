# Labradorite Notebook<!-- omit in toc -->

<img align="right" src="https://github.com/simonneutert/labradorite-notebook/blob/main/public/labradorite.jpg?raw=true" alt="Labradorite dreamed by openai's Dall-E2: A brown labrador shooting a lazer from a blue crystal on its forehead, digital art">

> Labradorite rightfully belongs to the group of wisdom crystals, because it promotes a free flow of mental energy as it awakens intuition and allows us to get mentally unstuck.
>
> _\- every esoteric out there_

---

[![Ruby 3.3 Rust 1.76.0](https://github.com/simonneutert/labradorite-notebook/actions/workflows/ruby.yml/badge.svg)](https://github.com/simonneutert/labradorite-notebook/actions/workflows/ruby.yml)
[![Docker](https://github.com/simonneutert/labradorite-notebook/actions/workflows/docker-publish.yml/badge.svg?branch=main&event=push)](https://github.com/simonneutert/labradorite-notebook/actions/workflows/docker-publish.yml)

---

> [!IMPORTANT]
> [Tantiny](https://github.com/baygeldin/tantiny) has died this summer (most probably) ... 
>
> This project heavily depends on Tantiny, and as a result, we anticipate releasing our final updates in the near future.  
> I am committed to maintaining the project's functionality for as long as feasible. However, I will not be investing additional time or resources into its further development. 😔
> 🥲 It will continue to work though! As it is fulfilling what it was built for in the first place.
> Dependabot will help keep security vulnerabilities closed and containerization will do the rest.

---

- [Rationale](#rationale)
- [Features / User Info](#features--user-info)
- [Technical Prerequisites](#technical-prerequisites)
- [Architecture](#architecture)
- [Folder Structure](#folder-structure)
- [Major Dependencies](#major-dependencies)
- [Run/Deploy with Docker](#rundeploy-with-docker)
  - [Docker Compose](#docker-compose)
- [Development](#development)
- [Run it](#run-it)
- [Follow-up: Inspiration, Knowledge](#follow-up-inspiration-knowledge)
    - [Tantiny](#tantiny)
    - [Rails Multi-Model Search](#rails-multi-model-search)

---

## Rationale

Most Notetaking apps do either too much (Notion), too little (Apple Notes) and lock me in (all options ever).

I wanted something that does **just-enough**™, in the spirit of a _flat file cms_. Let me try and wrap it up in a few bullets:

- **ownership** of the notes (flat files)  
  markdown, yaml, attachments all in one place in directories
- **easy** on the eyes/mind  
  I don't want to see all the old stuff I may not need anymore
- a search that shows me **snips** in the notes  
  not just the notes in a sidebar
- a very simple **tagging** support
- basic **file uploads**  
  keeping the originals side by side with notes

I like to keep things simple, so I once again fell for [Roda](https://roda.jeremyevans.net) as the Web Layer. [Tantiny](https://github.com/baygeldin/tantiny) is the kicker for this project. I was curious, if I could come up with something useful quickly, not having to deal with a complicated setup or Postgres as a requirement.

---

## Features / User Info

**Markdown Editor**

- Preview
- Supports auto-formatting with/around saving (on page refresh)

**Attachments**

- supported attachments for uploads
  - txt
  - pdf
  - md
  - png
  - jpg
  - jpeg
  - heic
  - webp
  - yml
  - yaml
  - json

**Screenshots**

<img src="assets/docs/images/search_results.png">

---

<img src="assets/docs/images/edit.png">

---

<img src="assets/docs/images/show.png">

## Technical Prerequisites

- Ruby v3.x are tested and ready to roll
- Install a stable version of [Rust](https://www.rust-lang.org/) with [Cargo](https://github.com/rust-lang/cargo)

## Architecture

Little experiment on how it rolls:

- all GET gets HTML
- all POST sends FORMS/JSON gets JSON back
- all links/navigation are plain HTML `a` tags 🤯

## Folder Structure

- `lib`: Library Code / Business Logic
- `views`: ERB Views
- `memos`: the Memos/Notes in subdirectories `YYYY/MM/DD/random-string`
- `public`: css/js/media
- `.tantiny`: the local index data created by the [tantiny](https://github.com/baygeldin/tantiny) gem

## Major Dependencies

- Roda
- Tantiny
- RedCarpet

## Run/Deploy with Docker

The included `Dockerfile` and the `docker-compose.yml` are more a stub to build upon.

Currently the Dockerfile support passing the USERNAME as an `build-arg`.

- `$ docker build . --build-arg USERNAME=$(whoami) -t labba`
- `$ docker run --rm -p9292:9292 labba`

Either this way, or you adapt the Dockerfile to your needs.

Let's say your username on the server you run (or your machine) is `johndoe`, then your Dockerfile should look something like this:

```Dockerfile
# in your version of the Dockerfile, replace labradorite at the ARG USERNAME
ARG USERNAME=johndoe
```

That will help you both secure the service and have the files being created with the proper rights on the host system.

### Docker Compose

build and/or up using: `$ USERNAME=$(whoami) docker-compose build`

**Volumes**

- this `memos` directory has all your created content in it. Having it mounted from your host should make easy for you to backup (if you don't use a private gitrepo for that 😉)
- fyi: having tantiny's index (`.tantiny`) as a volume has no benefit. Beware, it can easily have a negative impact.

## Development

From v0.5.0 on, the project can only be run native on a Linux machine or in a Docker container. See the Dockerfiles and `justfile` for more information.

- `$ rake test` runs the test suite
- `$ rake reset_default_memos` resets the files to the repos defaults (e.g. for testing)
- `$ rake reset_memos` clears ALL memos

Before pushing code, you should always run `rake reset` and `rake test`,  
**therefore have a repo you work on AND another you use JUST for running the software.**

## Run it

Example docker-compose file:

```docker-compose
version: '3'
services:
  app:
    user: "${UID}:${GID}"
    environment:
      - USERNAME=yourusername # REPLACE THIS WITH YOUR VPS user's USERNAME
    image: ghcr.io/simonneutert/labradorite-notebook:v0.2.0
    # ports:
    #  - 9292:9292
    command: bundle exec rackup -o0 -Eproduction
    volumes:
      - ./memos:/home/labradorite/memos:cached
```

## Follow-up: Inspiration, Knowledge

#### Tantiny

https://github.com/baygeldin/tantiny

#### Rails Multi-Model Search

https://stevepolito.design/blog/search-across-multiple-models-in-rails/

Gist: a searchable table is to be added and kept updated using commit_hooks
