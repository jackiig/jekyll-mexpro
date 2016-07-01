#!/usr/bin/env bash

# TODO: Remove these once Cloud9 fixes environment bugs.
export GEM_HOME=/usr/local/rvm/gems/ruby-2.3.0
export GEM_PATH=/usr/local/rvm/gems/ruby-2.3.0:/usr/local/rvm/gems/ruby-2.3.0@global

bundle check

bundle exec jekyll server --host $IP --port $PORT --baseurl ''
