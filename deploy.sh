#!/bin/bash

set -euxo

################################################
# This script deploys an already built website #
################################################

# Store commit message in a variable to reuse later
commit_message=$(git log -1 --pretty=%B)

# Create a temporary directory
tmp_dir=$(mktemp --tmpdir --directory chshersh.com-XXXX)

# Clone the 'main' branch to a temp location
clone_dir="$tmp_dir/chshersh.github.io"
git clone \
  --branch main \
  --depth 1 \
  https://github.com/chshersh/chshersh.github.io.git \
  "$clone_dir"

# Clean up repo before copy
rm -r "${clone_dir:?}"/*

# Copy file inside the cloned directory
copy_file() {
  local path="$1"
  cp "$path" "$clone_dir/$path"
}

# Copy all relevant files to the cloned repo
copy_file "CNAME"
copy_file "index.html"
copy_file "favicon.ico"

# Copy JS assets and minimise the main script
mkdir -p "$clone_dir/js"
terser js/main.js --output=js/main.min.js --compress --mangle
copy_file "js/main.min.js"
copy_file "js/article.js"

mkdir -p "$clone_dir/css"
copy_file "css/styles.css"
copy_file "css/article.css"

mkdir -p "$clone_dir/fonts"
copy_file "fonts/JetBrainsMono-Regular.woff2"
copy_file "fonts/Geist-Regular.woff2"

mkdir -p "$clone_dir/files"
copy_file "files/CV_Dmitrii_Kovanikov.pdf"

cp -r images/ "$clone_dir/images/"

mkdir -p "blog"
mkdir -p "$clone_dir/blog"
for file in posts/*; do
    file_name=$(basename "$file")
    article_name="${file_name%.*}"

    # Convert Markdown to HTML
    pandoc "$file" \
      --template=templates/article.html \
      --output "blog/${article_name}.html"

    copy_file "blog/${article_name}.html"
done

## Generate an Atom feed
pandoc -M updated="$(date --iso-8601='seconds')" \
  --metadata-file=feeds.yaml \
  --template=templates/atom.xml \
  -t html \
  -o atom.xml < /dev/null
copy_file "atom.xml"

## Generate an RSS feed
pandoc -M updated="$(date '+%a, %d %b %Y %T %z')" \
  --template=templates/rss.xml \
  --metadata-file=feeds.yaml \
  -t html \
  -o rss.xml < /dev/null
copy_file "rss.xml"

# Step into cloned dir and add all new files
cd "$clone_dir"
git add .

# Prepare repo and push
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git commit -m "$commit_message" || echo "No changes to commit"
git remote set-url --push origin "https://chshersh:$GITHUB_TOKEN@github.com/chshersh/chshersh.github.io"
git push origin main --force
