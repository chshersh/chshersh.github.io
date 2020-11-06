#!/usr/bin/env bash
set -eo pipefail

# Clean rebuild
cabal run site rebuild

# Create deploy environment inside of .deploy directory
mkdir .deploy
cd .deploy
git init --initial-branch=main
git remote add origin git@github.com:chshersh/chshersh.github.io.git
git pull -r origin main

# Add built site files
rsync -a ../_site/ .
git add .
git commit -m "$1"
git push origin main

# Cleanup .deploy directory after a successful push
cd ..
rm -rf .deploy
