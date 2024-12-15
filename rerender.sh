#!/bin/bash

set -euo

for file in posts/*; do
    file_name=$(basename "$file")
    article_name="${file_name%.*}"

    # Convert Markdown to HTML
    pandoc "$file" \
      --template=templates/article.html \
      --output "blog/${article_name}.html"

    echo "$file -> blog/${article_name}.html"
done
