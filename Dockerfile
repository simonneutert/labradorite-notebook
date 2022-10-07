FROM ruby:3.0.4-alpine3.16

ENV WORKDIR="/app"
WORKDIR ${WORKDIR}

RUN apk add --update-cache \ 
    build-base \
    linux-headers \
    gcc \
    rust \
    cargo

COPY Gemfile* ${WORKDIR}/
# ENV BUNDLE_WITHOUT="development test"
RUN bundle install -j4

COPY . ${WORKDIR}/
CMD bundle exec rackup -o0 -Eproduction