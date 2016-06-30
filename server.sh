#!/usr/bin/env bash

bundle check

bundle exec jekyll server --host $IP --port $PORT --baseurl ''
