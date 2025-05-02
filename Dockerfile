# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev libyaml-dev pkg-config git curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BUNDLE_PATH="/bundle"
ENV BUNDLE_DEPLOYMENT="1"
ENV RAILS_ENV="development"

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

ADD . /app
