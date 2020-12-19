---
title: Dead simple cross-platform GitHub Actions for Haskell
description: GitHub Actions CI settings for Haskell projects with Cabal and Stack
tags: haskell, ci, github-actions, cabal, stack
shortName: github-actions
---

I have been looking for the perfect Continuous Integration (CI) for my
Haskell projects for a while and found
[Github Actions](https://github.com/features/actions) to be absolute
gold for that. I have been going back and forth between different CI
platforms (Travis, AppVeyor, CircleCI), until recently I finally
figured out the settings that include everything I need.

So, in this short blog post, I would like to present the easiest way
to set up the GitHub Actions CI for Haskell projects I come up with.

## Motivation

In one of my previous blog posts I've described
[Dead simple Travis CI settings](https://kodimensional.dev/posts/2019-02-25-haskell-travis)
for Haskell projects. There I've also explained why it's important to
support both build tools and multiple GHC versions on CI. However,
it's tricky to define Travis CI config with a matrix for multiple GHC
versions, multiple operating systems and multiple build tools at the
same time. This is where GitHub Actions come to play!

The resulting GitHub Actions configuration has the following features:

* It is fast
* It is short
* Works on Linux, macOS and Windows
* Supports multiple GHC versions
* Builds your project with both `cabal` and `stack`
* Contains only single copy-pasteable file: the file doesn't have any
  project-specific properties or variables
* Can be enabled automatically: no need to visit some third-party site
  to start CI, just push a single file to your repo
* It is free for open-source projects

## The Config

To not beat around the bush and just get to the point, below is the
full config:

```yaml
name: CI

# Trigger the workflow on push or pull request, but only for the main branch
on:
  pull_request:
  push:
    branches: [main]

jobs:
  cabal:
    name: ${{ matrix.os }} / ghc ${{ matrix.ghc }}
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macOS-latest, windows-latest]
        cabal: ["3.2"]
        ghc:
          - "8.6.5"
          - "8.8.4"
          - "8.10.2"
        exclude:
          - os: macOS-latest
            ghc: 8.8.4
          - os: macOS-latest
            ghc: 8.6.5
          - os: windows-latest
            ghc: 8.10.2
          - os: windows-latest
            ghc: 8.6.5

    steps:
    - uses: actions/checkout@v2
      if: github.event.action == 'opened' || github.event.action == 'synchronize' || github.event.ref == 'refs/heads/main'

    - uses: actions/setup-haskell@v1.1.4
      id: setup-haskell-cabal
      name: Setup Haskell
      with:
        ghc-version: ${{ matrix.ghc }}
        cabal-version: ${{ matrix.cabal }}

    - name: Configure
      run: |
        cabal configure --enable-tests --enable-benchmarks --test-show-details=direct

    - name: Freeze
      run: |
        cabal freeze

    - uses: actions/cache@v2.1.3
      name: Cache ~/.cabal/store
      with:
        path: ${{ steps.setup-haskell-cabal.outputs.cabal-store }}
        key: ${{ runner.os }}-${{ matrix.ghc }}-${{ hashFiles('cabal.project.freeze') }}

    - name: Install dependencies
      run: |
        cabal build all --only-dependencies

    - name: Build
      run: |
        cabal build all

    - name: Test
      run: |
        cabal test all

  stack:
    name: stack / ghc ${{ matrix.ghc }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        stack: ["2.3.1"]
        ghc: ["8.8.4"]

    steps:
    - uses: actions/checkout@v2
      if: github.event.action == 'opened' || github.event.action == 'synchronize' || github.event.ref == 'refs/heads/main'

    - uses: actions/setup-haskell@v1.1.4
      name: Setup Haskell Stack
      with:
        ghc-version: ${{ matrix.ghc }}
        stack-version: ${{ matrix.stack }}

    - uses: actions/cache@v2.1.3
      name: Cache ~/.stack
      with:
        path: ~/.stack
        key: ${{ runner.os }}-${{ matrix.ghc }}-stack

    - name: Install dependencies
      run: |
        stack build --system-ghc --test --bench --no-run-tests --no-run-benchmarks --only-dependencies

    - name: Build
      run: |
        stack build --system-ghc --test --bench --no-run-tests --no-run-benchmarks

    - name: Test
      run: |
        stack test --system-ghc
```

Enabling such CI for your projects is completely effortless. All you
need to do is create a file named `.github/workflows/ci.yml` with the
above content and push it to your repository. That's all! GitHub takes
care of everything else for you.

The above config is implemented as a
[workflow template](https://github.blog/2020-06-22-promote-consistency-across-your-organization-with-workflow-templates/),
and can be enabled in one click in all Kowainik repositories (you can
copy-paste the file to your projects as well):

* [kowainik/.github: Dead-simple CI](https://github.com/kowainik/.github/blob/main/workflow-templates/ci.yml)

![Suggested workflow](https://user-images.githubusercontent.com/4276606/86161652-788da200-bb05-11ea-8757-46c03a9e3c53.png)

Once all build errors are fixed, you can enjoy your well-deserved
green CI 💚

![All CI checks pass](https://user-images.githubusercontent.com/4276606/81208666-54ab5580-8fc7-11ea-9464-80e67ade7d7a.png)

### Badge

After you enable GitHub Actions CI for your project, you can also add
a cute badge to your `README.md`. Copy the following line and replace
`userName` and `repoName` with your own settings:

```
[![GitHub CI](https://github.com/userName/repoName/workflows/CI/badge.svg)](https://github.com/userName/repoName/actions)
```

And it will look like this:

[![GitHub CI](https://github.com/kowainik/validation-selective/workflows/CI/badge.svg)](https://github.com/kowainik/validation-selective/actions)

## Configuration explanation

If you want to understand why the configuration looks like it looks,
below is a short explanation:

1. The configuration is powered by two GitHub Actions:
   [setup-haskell](@github(actions)) and
   [cache](@github(actions)). The `setup-haskell`
   action is responsible for installing GHC, cabal and stack on
   different operating systems and providing some convenient
   utilities. The `cache` action is responsible for caching your built
   artefacts as you might guess.
2. It builds your project using `cabal` with different GHC versions on
   Ubuntu. The GitHub Actions virtual environment comes with GHC,
   Cabal and Stack already pre-installed in there, so the CI is faster
   on Linux than on Windows or macOS at the moment.
3. Cache for `cabal` builds is based on the _cabal freeze_ files. The
   `cache` GitHub Action doesn't upload newer cache if the cache with
   such key already exists. This can be problematic when you starting
   developing a package and adding new dependencies. To improve the
   situation, the cache key is based on all project
   dependencies. Using this approach means that once you change
   dependencies, your project and all dependencies will be rebuilt
   from scratch. But when they are built, the whole cache will be
   reused next time.
4. Your project builds on macOS and Windows only using the latest (or working) GHC
   version. It usually won't give you a lot to build with multiple GHC
   versions on all three platforms. So instead of having a `N x M`
   matrix, it's enough to have a `N + M - 1` matrix. Though, you can
   easily change this behaviour by removing relevant `exclude`
   sections.
5. The CI also configures the testing environment properly and runs
   your tests automatically with each build.
6. Dependencies are built in a separate step, so you can quickly see
   from the overview, which building step has failed — dependencies or
   your project.
7. The config is extensible and easily customizable. You can change
   step names and their commands, add new steps. You can even add
   releases in an easy way with such a system!

## Dependabot

The presented CI configuration specifies versions of used GitHub
Actions. They can become outdated with time, and this blog post is not
updated automatically to the latest versions of each mentioned GitHub
Action.

Fortunately, you can use [Dependabot](https://dependabot.com/) to move
the burden of updating actions versions from your shoulders to tools.

To receive pull requests with version updates for used actions, add the
`.github/dependabot.yml` file with the following content (assuming,
that you already have labels `CI` and `library :books:` in your
repository, but you can choose your own existing labels):

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
    commit-message:
      prefix: "GA"
      include: "scope"
    labels:
      - "CI"
      - "library :books:"
```
