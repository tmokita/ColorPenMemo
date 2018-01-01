#!/bin/bash

# load .env / It's for debug on local machine
if [ -e .env ]; then
  for i in $(cat .env 2>/dev/null); do
    export $i
  done
fi

# enable error reporting to the console
set -e

# cleanup "_site"
rm -rf _site

# clone remote repo to "_site"
git clone --depth 1 https://${GH_TOKEN}@github.com/${REPO}.git --branch gh-pages _site

# build with Jazzy into "_site"
bundle exec sh ./scripts/generate_docs.sh

# push
cd _site
git config user.email "$USER_EMAIL"
git config user.name "$USER_NAME"
git add --all
git commit --all --message="Auto generate docs #$TRAVIS_BUILD_NUMBER"
git push --force origin gh-pages