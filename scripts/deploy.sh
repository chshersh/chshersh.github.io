#!/usr/bin/env bash
set -eo pipefail

# Clean rebuild
cabal new-exec site rebuild

# Create deploy environment inside of .deploy directory
mkdir .deploy
cd .deploy
git init
git remote add origin git@github.com:kowainik/kowainik.github.io.git
git pull -r origin master

# Add built site files
rsync -a ../_site/ .
git add .
git commit -m "$1"
git push origin master

# Cleanup .deploy directory after a successful push
cd ..
rm -rf .deploy
