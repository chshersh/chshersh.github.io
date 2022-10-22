---
title: Haskell Revitalisation
description: Updating and modernising Haskell packages
tags: haskell, consultancy
shortName: haskell-revitalisation
hideCreated: yes
---

**TL;DR** I'm offering paid consultancy services for improving the maintainability, sustainability and code quality of your Haskell packages:

* Supporting newer and older GHC versions
* Supporting both cabal and stack
* Adding more sanity checks, linting and static analysis
* Improving documentation
* And much more!

## Is this for you?

You can benefit from my offer if you are:

+ **A company** that wants to start following Haskell development best practices
+ **A company** under a burden of legacy code that needs help from an expert in improving and modernising the quality of their Haskell packages
+ **A company or an individual developer** who wants to boost their portfolio and presence in the Open-Source community by having an exemplary project

Or if you think that my services are a good fit for your use case!

## Pricing

::: {.thought}
Starting from $499
:::

The price is individual and starts from $499 per Haskell project update. The exact number will be provided after discussing all the details.

Before you pay, you get the following **for free**:

* Examples of my previous work
* Preliminary analysis of the expected work amount
* Final quote

> For more details on timelines and refunding, see the Refund Policy section.

[Send me an email][contacts] describing what you want to get the conversation going!

## How it works?

The typical workflow is quite simple:

1. You write me an email describing what you want.
2. We discuss the cost and timeline over email.
3. I send you the invoice.
4. You pay.
5. I produce the work as agreed (e.g. I open a Pull Request with desired changes to your GitHub repository within 14 days).

It's that simple!

## What's included?

The following section describes in detail the full package of my services to boost your Haskell project.

> You can use the below text as the template for your email message. Just copy it, insert it in your email body and edit!

- **Cabal support**. Your project will be built with the latest version of `cabal-install`.
- **Stack support**. Your project will be built with the latest version of `stack`.
- **GitHub Actions CI**. I'm using the [Dead-Simple cross-platform template][github-actions] to build your project on Ubuntu, macOS and Windows (if you don't depend on Unix-only packages).
- **GHC support**. Your project will be built with the latest major GHC version (currently 9.4)
    * You can request support for a specific version
    * For libraries, you can request to support "the latest three major" versions or some specific older GHC versions
- **GHC warnings**. This includes adding the latest recommended extended list of GHC warnings and fixing all of them.
    * Some warnings rely on features only from newer GHC versions. If you request support for multiple GHC versions, GHC warnings will be enabled only for the supported versions
- **HLint support**. Adding HLint check on CI and fixing/ignoring HLint suggestions.
    * If your project uses `relude`, you can request relude-specific HLint rules in addition to standard HLint support.
- **Stan support (Only for GHC 8.10 at the moment!)**. Running Stack check on CI and storing static analysis reports for each run.
- **The .cabal file improvements**.
    * Best-practices in the .cabal file metadata
    * Introduction of common stanzas for reduced boilerplate
    * You may request to keep or remove `hpack` support
- **Documentation improvements**. You can ask for some documentation improvements
    * Pretty badges in README (CI, Hackage, Stackage)
    * "How to use" section in README: A standard section on how to add your project to dependencies and a simple usage example.
    * Haddock errors fixes
    * Haddock improvements
    * Full tutorials using Literate Haskell
- **Using an alternative prelude library**. Using an alternative prelude library (e.g. `relude`) can improve the code quality and help with establishing best practices within a team.

These are the main examples to give you an idea of what can be done. If you have something different in mind, don't hesitate to mention it!

[github-actions]: https://kodimensional.dev/github-actions

### Example projects

I'm following Haskell's best practices to get the most from Haskell tooling. You can find examples of what to expect in my Haskell OSS packages:

* [chshersh/iris][iris]: A Haskell CLI framework
* [chshersh/dr-cabal][dr-cabal]: Haskell dependencies build times profiler

[iris]: https://github.com/chshersh/iris
[dr-cabal]: https://github.com/chshersh/dr-cabal

## Refund policy

To receive my services, **full payment in advance** is required. Before you pay, we can discuss the exact pricing, delivery timeline and further steps.

If I don't follow the discussed schedule, you're eligible for a full refund.

There's no refund if you're unsatisfied with the quality of my work. The examples of my work are available in public for free so you already know what you'll get.

However, if I don't finish something we discussed and agreed on, I'll finish it at no extra cost to you.

[contacts]: https://kodimensional.dev/#contacts
