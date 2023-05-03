# chshersh.com

[![GitHub CI](https://github.com/chshersh/chshersh.github.io/workflows/CI/badge.svg)](https://github.com/chshersh/chshersh.github.io/actions)

My personal web page:

+ [chshersh.com](http://chshersh.com/)

## How to update this web page

If you want to change the content of the ChShersh's web page you need to perform
the following steps:

1. Make sure that you are on the `develop` branch
2. Create new branch from `develop`, implement desired changes and open a pull request

## How to deploy

```
./scripts/deploy.sh "Some meaningful message"
```

## How to add a blog post

Create a markdown file in the `posts/`
folder. The name of this file should contain the date of the post and some
meaningful name. For example: `2019-11-05-new-cool-post.md`.

In the `.md` file you should add next info in the following format:

```
---
title: Some really meaningful title that will appear at the page
description: Some short description
tags: haskell, stack, cabal, build-tools, tutorial
---

DO NOT COPY TITLE HERE!
Here comes the body of the post itself

## Important rules!!!

* Use only `##` and upper for headers.
* Avoid special characters in the headers names (including `\``).
* Tags should be one-worders.

...

```
