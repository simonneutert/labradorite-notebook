##### Setup for Alpine #####

FROM ruby:3.0.5-alpine3.16 AS builder

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

RUN gem install bundler:2.4.3
COPY Gemfile* ${WORKDIR}

RUN bundle config set without 'development test' 
RUN bundle install -j${bundler_jobs}

##### MAIN CONTAINER #####

FROM ruby:3.0.5-alpine3.16
RUN apk add --no-cache npm && npm install -g prettier
# replace labradorite with your username on your server
ARG USERNAME=labradorite
RUN adduser -D ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENV RACK_ENV=production
EXPOSE 9292

COPY --from=gembuilder /usr/local/bundle/ /usr/local/bundle/
COPY --chown=${USERNAME} . ${WORKDIR}

CMD bundle exec rackup -o0 -Eproduction
