##### Setup for Alpine #####

FROM ruby:3.4 AS builder

ENV LANG=C.UTF-8
ENV WORKDIR="/app/"
WORKDIR ${WORKDIR}

RUN apk add --no-cache \ 
    linux-headers \
    build-base \
    sqlite-dev \
    libffi-dev \
    yaml-dev \   
    gcc

##### Ruby Gem Management #####

FROM builder AS gembuilder

ARG bundler_jobs=2

ENV WORKDIR="/app/"
WORKDIR ${WORKDIR}

COPY Gemfile* ${WORKDIR}

RUN bundle config set without 'development test' 
RUN bundle install -j${bundler_jobs}

##### MAIN CONTAINER #####

FROM ruby:3.4-alpine

RUN apk update && apk upgrade

RUN apk add nodejs npm \
    && rm -rf /var/cache/apk/*; \
    npm install -g prettier;

ENV LANG=C.UTF-8
ENV RUBY_YJIT_ENABLE=1
ENV NODEJS_VERSION=22
ENV RACK_ENV=production
# Database configuration (in-memory by default, can override with DATABASE_TYPE=file)
ENV DATABASE_TYPE=memory

# replace labradorite with your username on your server
ARG USERNAME=labradorite
RUN adduser -D ${USERNAME}
USER ${USERNAME}
ENV WORKDIR=/home/${USERNAME}
WORKDIR /home/${USERNAME}

EXPOSE 9292

COPY --from=gembuilder /usr/local/bundle/ /usr/local/bundle/
COPY --chown=${USERNAME} . ${WORKDIR}

CMD ["bundle", "exec rackup -o0 -Eproduction"]
