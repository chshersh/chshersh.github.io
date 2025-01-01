---
title: "8 months of OCaml after 8 years of Haskell in production"
description: Comparing my experience in OCaml with Haskell
tags: ocaml, haskell, functional programming
shortName: "8"
updated: "August 21st, 2024"
---

I've been using Haskell in production for 8 years.
I've been using OCaml in production for 8 months.

It's time to compare those two languages.

# Syntax

Haskell probably has the most elegant syntax across all languages I've seen (maybe Idris is better because dependently typed code can become ugly in Haskell really quickly).

There's utter joy in expressing your ideas by typing as few characters as possible.

OCaml, being a language from the ML family is great too, but still, Haskell is more tacit.

Compare a few examples:

## Sum of all numbers in a string

> Using just the standard library

**Haskell**

```haskell
-- strSum "100  -42 15" = 73
strSum :: String -> Int
strSum = sum . map read . words
```

**OCaml**

```ocaml
(* str_sum "100  -42 15" = 73 *)
let str_sum (str: string): int =
  str
  |> String.split_on_char ' '
  |> List.filter_map int_of_string_opt
  |> List.fold_left (+) 0
```

## Defining a new binary tree type

**Haskell**

```haskell
data Tree a
  = Leaf
  | Node a (Tree a) (Tree a)
```

**OCaml**

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree
```

## Parsing

> Return the result on successful parsing of lines like the one
> below where "Status" equals to zero and the result is an even number
>
> ```
> "Status: -1 | Result: 42"
> ```

**Haskell**

```haskell
parseLine :: String -> Maybe Int
parseLine line = do
    ["Status:", "0", _, "Result:", result] <- Just $ words line
    n <- readMaybe result
    guard $ even n
    pure n
```

**OCaml**

```ocaml
let parse_line (line: string): int option =
  let ( let* ) = Option.bind in
  let* result =
    match String.split_on_char ' ' line with
    | ["Status:"; "0"; _; "Result:"; result] -> Some result
    | _ -> None
  in
  let* n = int_of_string_opt result in
  if n mod 2 = 0 then Some n else None
```

<hr/>

The above are just a few random code snippets. They don't give an idea of all possible programs that could be written in those languages. But I hope they can quickly highlight the similarities and differences between the two languages.

This slowly leads us to the next point.

# Features

Haskell has waaaaaay more features than probably any other programming language (well, C++ can compete). This is both good and bad.

It's good because you have the tools to solve your problems in the best way.

It's bad because you have those tools. They're distracting. Every time I need to solve a problem in Haskell, I'm immediately thinking about all the ways I can design the solution instead of, ahem, actually implementing this solution.

I'm interested in building stuff, not sitting near my pond on a warm summer day, thinking if TypeFamilies + DataKinds would be better than GADTs for making illegal states unrepresentable.

If I come to an existing OCaml project, the worst thing previous developers could do to it is have poor variable names, minimal documentation, and 200+ LOC functions. That's fine, nothing extraordinary, I can handle that.

If I come to an existing Haskell project, the worst thing previous developers could do... Well, my previous 8 years of Haskell experience can't prepare me for that 😅

That's why I feel more productive in OCaml.

I do miss some Haskell features at times. But I've seen their ugly side and what they can do to your output.

Consider the following table with a full comparison of major features.

### Feature comparison table

| **Feature**                   | **OCaml** | **Haskell** |
|-------------------------------|-----------|-------------|
| Expression-oriented syntax    | ✅         | ✅           |
| Immutability by default       | ✅         | ✅           |
| Higher-Order Functions (HOFs) | ✅         | ✅           |
| Anonymous functions (lambdas) | ✅         | ✅           |
| Algebraic Data Types (ADTs)   | ✅         | ✅           |
| Pattern Matching              | ✅         | ✅           |
| Parametric Polymorphism       | ✅         | ✅           |
| Type Inference                | ✅         | ✅           |
| Monadic Syntax Sugar          | ✅         | ✅           |
| Garbage Collector             | ✅         | ✅           |
| Multithreading                | ✅         | ✅           |
| GADTs                         | ✅         | ✅           |
| Purity by default             | ❌         | ✅           |
| Composable laziness           | ❌         | ✅           |
| Type classes                  | ❌         | ✅           |
| Higher-Kinded Types           | ❌         | ✅           |
| Opt-in language features      | ❌         | ✅           |
| First-class modules           | ✅         | ❌           |
| Polymorphic variants          | ✅         | ❌           |
| Objects                       | ✅         | ❌           |
| Classes and Inheritance       | ✅         | ❌           |
| Ergonomic mutability          | ✅         | ❌           |

# Ecosystem

Let's be honest, both programming languages are niche FP langs. So you shouldn't expect first-class support for the latest modern framework that just got published.

However, in my experience, despite needing to write more custom bindings, you have solutions for the majority of common tasks.

For example, in OCaml, you can find:

- [otoml: A TOML parser](https://github.com/dmbaturin/otoml/)
- [Mint Tea: A TUI framework](https://github.com/leostera/minttea)
- [ocaml-opentelemetry: Instrumentation for OpenTelemetry](https://github.com/imandra-ai/ocaml-opentelemetry)
- [awsm: OCaml AWS Client](https://github.com/solvuu/awsm)
- [petrol: An OCaml SQL API made to go FAST](https://github.com/gopiandcode/petrol)

And so on. Similar story for Haskell.

I'd still say that the Haskell ecosystem has more packages and more ready-to-go solutions.

It's easy to show the difference in the following example.

Number of [Stripe API](https://stripe.com/docs/api) client libraries:

- Haskell: 13
- OCaml: 1 (last change was 8 years ago, so it's more like zero)

You may find a solution in Haskell. But often you'll discover **too many** solutions, you won't know which one to choose.

Choosing a library in Haskell becomes a separate skill you need to master. Haskellers [even blog their recommendations](https://www.haskellforall.com/2018/05/how-i-evaluate-haskell-packages.html) on how to choose a library! And you'll face this dilemma over and over again.

Often, a new Haskell library is created not because it solves a different problem.

But because the author wanted to _write it differently_ (using different abstractions, playing with new features, etc. Who doesn't want a new streaming library based on LinearTypes???).

It's not exciting to write a GitHub API client and parse tons of JSON.

But it is exciting to design a [logger with comonads](https://www.youtube.com/watch?v=elqPlMyryjc).

# Tooling

The Haskell tooling evokes the most controversial feelings. It's like an emotional roller coaster:

- 🤩 Hoogle is the best! I can search through the entire ecosystem by using just a type signature!!!
- 😨 Wait, why build tooling error messages are so bad, what do you mean it couldn't find a build plan for a working project???
- 🤩 Global content-addressable storage for all dependencies is such an amazing idea!!!
- 😨 What do you mean I need to recompile my IDE because I changed my package???
- 🤩 I can automatically test all the code snippets in my package docs!!!
- 😨 Wait, why doesn't the standard library have docs at all for this version I use???

And so on.

Using Haskell tooling is like always being in the quantum superposition of **"How do you even use other PLs without such wholesome Haskell tools???"** and **"How can Haskellers live like that without these usability essentials???"**.

<hr/>

OCaml, on the other hand, hits differently. Because its ecosystem is smaller, you actually get surprised every time you find something working!

For example, the VSCode plugin for OCaml based on Language Server Protocol (LSP) works out-of-the-box. I never had any issues with it. It **just works** ™️

The ergonomics of starting with OCaml tooling might not be the best but they're straightforward and robust. And they work most of the time.

<hr/>

To get a full picture, refer to the following table for the full comparison of available tooling in both languages.

### Tooling comparison table

| **Tool**            | **OCaml**                | **Haskell**                                        |
|---------------------|--------------------------|----------------------------------------------------|
| Compiler            | [ocaml]                  | [ghc]                                              |
| REPL                | [utop]                   | [ghci]                                             |
| Build tool          | [dune]                   | [cabal], [stack]                                   |
| Package manager     | [opam]                   | [cabal]                                            |
| Package repository  | [opam]                   | [Hackage]                                          |
| Toolchain installer | -                        | [ghcup]                                            |
| Linter              | [zanuda]                 | [hlint]                                            |
| Formatter           | [ocamlformat], [topiary] | [fourmolu], [stylish-haskell], [hindent], [ormolu] |
| Type Search         | [Sherlodoc]              | [Hoogle]                                           |
| Code search         | [Sherlocode]             | [Hackage Search]                                   |
| Online playground   | [TryOCaml]               | [Haskell Playground]                               |
| LSP                 | [ocaml-lsp]              | [HLS]                                              |

[ocaml]: https://github.com/ocaml/ocaml
[ghc]: https://gitlab.haskell.org/ghc/ghc

[utop]: https://github.com/ocaml-community/utop
[ghci]: https://downloads.haskell.org/ghc/latest/docs/users_guide/ghci.html

[dune]: https://dune.build/
[cabal]: https://cabal.readthedocs.io/en/latest/
[stack]: https://docs.haskellstack.org/en/stable/

[opam]: https://opam.ocaml.org/
[Hackage]: https://hackage.haskell.org/

[ghcup]: https://www.haskell.org/ghcup/

[zanuda]: https://github.com/Kakadu/zanuda
[hlint]: https://github.com/ndmitchell/hlint

[ocamlformat]: https://github.com/ocaml-ppx/ocamlformat
[topiary]: https://github.com/tweag/topiary
[fourmolu]: https://fourmolu.github.io/
[stylish-haskell]: https://github.com/haskell/stylish-haskell
[hindent]: https://github.com/mihaimaruseac/hindent
[ormolu]: https://github.com/tweag/ormolu

[Sherlodoc]: https://doc.sherlocode.com/
[Hoogle]: https://hoogle.haskell.org/

[Sherlocode]: https://sherlocode.com/
[Hackage Search]: https://hackage-search.serokell.io/

[TryOCaml]: https://try.ocamlpro.com/
[Haskell Playground]: https://play.haskell.org/

[ocaml-lsp]: https://github.com/ocaml/ocaml-lsp
[hls]: https://github.com/haskell/haskell-language-server

# Compiler messages

I want to highlight the compiler aspect of tooling separately since this is the tool you interact the most with.

Especially, compiler suggestions.

When using FP languages, the compiler is your best friend! You rely on it heavily to understand why your assumptions haven't been codified precisely.

Therefore, the compiler must present the information in the most accessible way.

In my view, Haskell compiler messages tend to be verbose with lots of contextual, often redundant, and distracting information.

OCaml compiler messages, on the other hand, are quite succinct. Sometimes too succinct.

Consider the following example.

## Haskell: Compiler messages example

**Program with an error**

```haskell
x = 1 + [3, 1, 2]
```

**Compiler output**

![Haskell Compiler Error Message](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/kh45ype7j5lo9gns76d7.png)

## OCaml: Compiler messages example

**Program with an error**

```ocaml
let x = 1 + [3; 1; 2]
```

**Compiler output**

![OCaml Compiler Error Message](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/t44lbbjywfvpj3d4gnv4.png)

<hr/>

This is just one example (and most likely not the best one), but you can already see the differences in how information is presented and how types work in different languages.

# Standard library

I believe the standard library deserves a separate mention too.

It shapes your first program in a language and guides you through all future journeys.

A great standard library is a cornerstone of your PL success.

A poor standard library is a cornerstone of never-ending bikesheds about a better standard library (including an endless variety of alternative competing standard libraries).

I'm a big proponent of the idea that a standard library should be batteries-included.

Give me an Option-like type, a UTF-8 string, Map and HashMap, JSON and XML parsers, async primitives, and so on, so I can avoid learning your poor implementation of dependency tracking and build tooling. ([Build Systems a la Carte](https://www.microsoft.com/en-us/research/uploads/prod/2018/03/build-systems.pdf) is a thorough analysis of the space of dependency trackers and build tools.).

Both Haskell and OCaml have kinda barebones standard libraries. They have minor differences (e.g. Haskell doesn't include Map and HashMap; OCaml doesn't have non-empty lists and Bitraversable). But overall they're similar in the spirit.

The Haskell standard library is called `base` and OCaml standard library is called.. well, it's just "the standard library".

- [base: The Haskell Standard Library](https://hackage.haskell.org/package/base)
- [OCaml: The standard library](https://v2.ocaml.org/api/index.html)

However, one difference is striking. The quality of Haskell documentation sometimes can amaze even a seasoned developer.

> Haskell has a few more nice features, like the ability to jump to sources from docs but I've been told such features are being cooked for OCaml too 👀

Compare a few doc snippets for the List data type (one of the fundamental structures in FP):

**Haskell**

[Haskell: Data.List.head](https://hackage.haskell.org/package/base-4.19.0.0/docs/Data-List.html#v:head)

![Haskell head](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/j38mezm8mld79emi3me9.png)

[Haskell: !?](https://hackage.haskell.org/package/base-4.19.0.0/docs/Data-List.html#v:-33--63-)

![Haskell index](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/chphke0bux2l3fq0x93y.png)

**OCaml**

[OCaml: List.hd](https://v2.ocaml.org/api/List.html)

![OCaml hd](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/l7cmzh4pd66kmgpav9xl.png)

[OCaml: List.nth_opt](https://v2.ocaml.org/api/List.html)

![OCaml nth_opt](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/mvn0bo84lbf6pibvbq7l.png)

<hr/>

You may argue that the result of such functions is obvious, therefore there's no need to write essays under each function.

I'm a fan of example-driven documentation, and I love seeing usage examples in docs! This immediately gives me an idea of how I can leverage the API in the best way.

# Conclusion

I want to end this blog post by saying:

**Both languages came a long way to support real industrial needs.**

They're still small compared to mainstream languages.

If you're not critically dependent on the presence of some specific SDK, you can choose any and have lots of joy while coding your next app 🧡

However, I prefer OCaml nowadays because I feel that I can focus on actually building stuff with this language.

# Discussions

Besides the comment section below, you can also find the discussions of this blog post in various places:

- [𝕏 by chshersh](https://twitter.com/ChShersh/status/1740303405678006422) (210+ 🧡, 14+ comments)
- [Hacker News](https://news.ycombinator.com/item?id=42302426) (264+ points, 277+ comments)
- [OCaml Discuss](https://discuss.ocaml.org/t/8-months-of-ocaml-after-8-years-of-haskell-in-production/13729) (16+ 🧡, 16+ comments)
- [Haskell Discourse](https://discourse.haskell.org/t/8-months-of-ocaml-after-8-years-of-haskell-in-production/8405) (27+ 🧡, 107+ comments)
- [Lobste.rs: ml](https://lobste.rs/s/0xsnfj/8_months_ocaml_after_8_years_haskell) (39+ ⬆️, 16+ comments)
- [Reddit: /r/ocaml](https://www.reddit.com/r/ocaml/comments/18sq1p5/8_months_of_ocaml_after_8_years_of_haskell_in/) (22+ ⬆️, 18+ comments)
- [Reddit: /r/haskell](https://www.reddit.com/r/haskell/comments/18sq4gp/8_months_of_ocaml_after_8_years_of_haskell_in/) (91+ ⬆️, 57+ comments)
