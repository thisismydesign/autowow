FROM ruby:2.6.0-alpine

RUN apk --update add --no-cache git build-base

WORKDIR /app

COPY . /app

RUN bundle install
