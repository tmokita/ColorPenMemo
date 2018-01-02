#!/bin/sh

mkdir -p _site
rm -Rf _site/*

(
cd CanvasToolbar &&
jazzy \
  --output "../_site/CanvasToolbar" \
  --podspec "CanvasToolbar.podspec"
)
