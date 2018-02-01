FROM exegete46/jekyll:onbuild
CMD jekyll server -P 3000 -H 0.0.0.0 -w --incremental --baseurl ''
