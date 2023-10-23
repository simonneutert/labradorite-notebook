##### Setup for Alpine #####

FROM ruby:3.2-alpine AS builder

ENV LANG C.UTF-8
ENV WORKDIR="/app/"
WORKDIR ${WORKDIR}

RUN apk add --no-cache \ 
    linux-headers \
    build-base \
    gcc \
    rust \
    cargo

##### Ruby Gem Management #####

FROM builder AS gembuilder

ARG bundler_jobs=2

ENV WORKDIR="/app/"
WORKDIR ${WORKDIR}

COPY Gemfile* ${WORKDIR}

RUN bundle config set without 'development test' 
RUN bundle install -j${bundler_jobs}

##### MAIN CONTAINER #####

FROM ruby:3.2-alpine

ENV LANG C.UTF-8
ENV RUBY_YJIT_ENABLE=1
ENV NODEJS_VERSION=18
ENV RACK_ENV=production

# replace labradorite with your username on your server
ARG USERNAME=labradorite
RUN adduser -D ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}

EXPOSE 9292

COPY --from=gembuilder /usr/local/bundle/ /usr/local/bundle/
COPY --chown=${USERNAME} . ${WORKDIR}

RUN set -uex; \
    apt-get update; \
    apt-get install -y ca-certificates curl gnupg; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
     | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODEJS_VERSION.x nodistro main" \
     > /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install nodejs -y;    
RUN npm install -g prettier;

CMD bundle exec rackup -o0 -Eproduction
