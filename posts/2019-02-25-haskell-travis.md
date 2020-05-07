---
title: Dead simple Haskell Travis settings for cabal and stack
description: Travis CI settings for Haskell projects with cabal and stack
tags: haskell, ci, travis, cabal, stack
---

Today I am going to share a simple [Travis CI](https://travis-ci.com/) configuration for Haskell projects with you. The `.travis.yml` file presented in this blog post allows you to painlessly test your repository on the continuous integration service under multiple GHC versions and with both build tools — [cabal-install](https://www.haskell.org/cabal/users-guide/) and [stack](https://docs.haskellstack.org/en/stable/README/). Note that the suggested settings do not include complex configuration steps that could possibly be required for some projects. However, they work amazingly well for most Haskell libraries and applications where a basic setup is enough!

## The Config

I'll cut to the chase, here is the `.travis.yml` file that you can copy-paste to each Haskell project and enjoy (hopefully) the green CI status:

```yaml
sudo: true
language: haskell

git:
  depth: 5

cabal: "2.4"

cache:
  directories:
  - "$HOME/.cabal/store"
  - "$HOME/.stack"
  - "$TRAVIS_BUILD_DIR/.stack-work"

matrix:
  include:

  # Cabal
  - ghc: 8.2.2
  - ghc: 8.4.4
  - ghc: 8.6.5

  # Stack
  - ghc: 8.6.5
    env: STACK_YAML="$TRAVIS_BUILD_DIR/stack.yaml"

install:
  - |
    if [ -z "$STACK_YAML" ]; then
      ghc --version
      cabal --version
      cabal new-update
      cabal new-build --enable-tests --enable-benchmarks
    else
      # install stack
      curl -sSL https://get.haskellstack.org/ | sh

      # build project with stack
      stack --version
      stack build --system-ghc --test --bench --no-run-tests --no-run-benchmarks
    fi

script:
  - |
    if [ -z "$STACK_YAML" ]; then
      cabal new-test --enable-tests
    else
      stack test --system-ghc
    fi

notifications:
  email: false
```

> **NOTE:** Instead of copy-pasting this `.travis.yml` file to every project you can use [Summoner](https://github.com/kowainik/summoner) to scaffold completely configured production-level Haskell libraries and applications which would include Travis configurations corresponding to the user-configured/custom project settings.

I want to point out some nice things about this config — it doesn't mention the project name anywhere and it doesn't rely on any additional shell scripts. Which means that you have the ability to paste it in any Haskell project and it **should just work** out of the box. Though, it's not the only reason why I recommend it. This config requires almost no maintenance, but at the same time, it is easily extensible. For example, if you want to check your code with [HLint](http://hackage.haskell.org/package/hlint) on every CI run, you just need to add the following line at the end of the `script` section:

```yaml
  - curl -sSL https://raw.github.com/ndmitchell/neil/master/misc/travis.sh | sh -s -- hlint .
```

This command downloads the latest HLint version and runs the `hlint` executable on your project.

## How to set up Travis CI

A quick recap on how to make Travis CI work for your project:

1. [Enable Travis CI for your GitHub account](https://docs.travis-ci.com/user/tutorial/) if you haven't done it before.
2. Enable Travis CI for your specific repository.
3. Copy-paste the given `.travis.yml` to your project.

That's all! Feel free to contact me if you have any problem setting up Travis CI for your Haskell projects with this config. I have done tons of `“Fix CI”` commits and learned about a lot of weird errors before figuring out the proper settings.

> **NOTE:** If you build your project with `stack`, it is a good idea to put a
> fully configured `stack.yaml` file to the repository. There you can specify
> all the settings required for `stack` to build your project, but for basic
> cases, it should be enough to have only the resolver in there:
>
> ```haskell
> resolver: lts-13.26
> ```

## Explanation of the configuration commands

Here is a short description of the commands used in the script:

1. `sudo: true` allows us to use more powerful CI environment and increases the speed of building.
2. When you use `language: haskell`, the GHC and cabal versions for Ubuntu are taken from [Herbert V. Riedel’s ppa](https://launchpad.net/~hvr/+archive/ubuntu/ghc).
3. Setting `git depth` to 5 decreases the time for cloning the GitHub repo, by pruning the amount of history (commits) of the repo that is fetched.
4. `STACK_YAML` environment variable is used to distinguish between Cabal and Stack builds. If you want to test multiple GHC versions with `stack` you only need to create `stack-VERSION.yaml` file specific to GHC version and add the corresponding number of items to the `matrix`.
5. `new-` commands are used for Cabal since they provide a modern way to build Haskell projects with `cabal-install` in [nix-style local builds](https://www.haskell.org/cabal/users-guide/).
6. `--system-ghc` flag is important for `stack` builds. Since you get the GHC version from the CI, `stack` doesn't need to download them separately. That’s why, do remember to add this flag to every `stack` command you're using.
7. Email notifications are disabled because they quickly become annoying. But the `notifications` section allows you to add a Slack integration, which can be handy.

## Reasoning behind such a CI config

As you can see from the config, it contains several opinionated decisions, which can appear redundant or suboptimal. Here I am going to reveal the reasoning behind them.

### Why both cabal and stack?

You may ask, why would I need to test my project with two build tools? The answer is to be friendlier to the rest of the Haskell community. Yes, there are several build tools for Haskell with `cabal` and `stack` being the most popular ones. But, unfortunately, if the project builds with one of the tools, it doesn't guarantee that it would also build with the other (though it works in _most_ cases).

1. If your project builds with `stack` it may still fail to build with `cabal`. For example, if you don't specify library bounds in the `build-depends` section, cabal solver might not find a valid plan to build your package with.
2. If your project builds with `cabal` it may still fail to build with `stack`. For example, some of your dependencies might not be in the Stackage snapshot, so you would need to add them into the `extra-deps` section in `stack.yaml`.

If you test your Haskell package on CI with both Cabal and Stack you provide a better user experience for users of both the build tools. As a maintainer of multiple open-source libraries and applications, I try to make the life of the contributors and users of my packages easier by providing support for both `cabal` and `stack`. The fewer steps they need to do in order to make my project work in their current environment, the more chances they don't give up halfway through fighting with the tooling. Also, if your Haskell package builds with `cabal` and `stack`, you can add it to both [Hackage](http://hackage.haskell.org/) and [Stackage](https://www.stackage.org/).

### Why latest 3 major GHC versions?

It is a huge temptation to use only the latest GHC version for your package with all brand new cool features. But even if migration to a newer GHC version is usually a painless process, it takes time for the whole Haskell ecosystem to catch up. And users of your Haskell package may still use a two year old GHC version. This usually happens in big applications where you cannot switch to a newer GHC version unless each of your dependencies supports it.

At the same time, it is highly desired to be able to bump up the version bounds only for some specific libraries (because of applied bug-fixes and performance improvements in the newer versions). But if newer versions require you to also switch to a newer compiler, you might not be able to do that because the migration of your application to a newer GHC version can be blocked by other libraries.

You can see why it is nice when libraries support older compiler versions as well. However, maintaining support for very old GHC versions might be a thankless and time-consuming thing to do. Also, the more GHC versions you test against on the CI, the more time you need to wait until CI passes. That's why the latest 3 seem reasonable enough.

> **NOTE:** you may notice from the configuration that the latest 3 GHC versions are tested only for `cabal-install` while `stack` builds only most recent version. This is done merely for convenience since in Stackage snapshots GHC versions are tightly coupled with dependency versions.

## Conclusion

You can see now that it's actually not that hard to run Travis CI for Haskell repositories! And the given configuration is easily extensible with more commands, like adding HLint, checking on a newer compiler version, building [Haddock](https://www.haskell.org/haddock/) documentation, running benchmarks, etc. Dealing with CI errors requires time and patience. But at least with this config you don't need to have multiple build tools and multiple GHC versions installed on your machine, you can delegate all this dirty work to the CI.

## Appendix

In some situations it's not possible to run CI for your Haskell project with both build tools easily. So below I’m providing separate configurations for each build tool.

### Cabal-only configuration

```yaml
sudo: true
language: haskell

git:
  depth: 5

cabal: "2.4"

cache:
  directories:
  - "$HOME/.cabal/store"

matrix:
  include:
  - ghc: 8.2.2
  - ghc: 8.4.4
  - ghc: 8.6.5

install:
  - ghc --version
  - cabal --version
  - cabal new-update
  - cabal new-build --enable-tests --enable-benchmarks

script:
  - cabal new-test --enable-tests

notifications:
  email: false
```

### Stack-only configuration

```yaml
sudo: true
language: haskell

git:
  depth: 5

cache:
  directories:
  - "$HOME/.stack"
  - "$TRAVIS_BUILD_DIR/.stack-work"

matrix:
  Include:
  - ghc: 8.2.2
    env: STACK_YAML="$TRAVIS_BUILD_DIR/stack-8.2.2.yaml"
  - ghc: 8.4.4
    env: STACK_YAML="$TRAVIS_BUILD_DIR/stack-8.4.4.yaml"
  - ghc: 8.6.5
    env: STACK_YAML="$TRAVIS_BUILD_DIR/stack.yaml"

install:
  - curl -sSL https://get.haskellstack.org/ | sh
  - stack --version
  - stack build --system-ghc --test --bench --no-run-tests --no-run-benchmarks

script:
  - stack test --system-ghc

notifications:
  email: false
```
