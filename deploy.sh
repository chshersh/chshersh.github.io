#!/bin/bash

set -Eeuxo pipefail

################################################
# This script deploys an already built website #
################################################

# Create a temporary directory
tmp_dir=$(mktemp --tmpdir --directory chshersh.com-XXXX)

# Clone the 'main' branch to a temp location
clone_dir="$tmp_dir/chshersh.github.io"
git clone \
  --branch main \
  --depth 3 \
  https://github.com/chshersh/chshersh.github.io.git \
  "$clone_dir"

# Copy all relevant files to the cloned repo
cp index.html "$clone_dir/index.html"
cp CNAME "$clone_dir/CNAME"
cp build/main.js "$clone_dir/build/main.js"

# Step into cloned dir and add all new files
cd "$clone_dir"
git add index.html
git add build/main.js
git add CNAME

# Prepare repo and push
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git commit -m "Deploy latest build to main" || echo "No changes to commit"
git push origin main --force
