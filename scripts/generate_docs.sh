#!/bin/sh

mkdir -p _site
rm _site/*

jazzy \
  --output _site \
  --min-acl public \
  --podspec CanvasToolbar/CanvasToolbar.podspec
