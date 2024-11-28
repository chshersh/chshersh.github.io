---
title: "Pragmatic Category Theory | Part 1: Semigroup Intro"
tags: ocaml, functional programming, category theory, math
shortName: "pragmatic-category-theory-part-1"
updated: "August 9th, 2024"
---

## Motivation

Functional Programming abstractions have a bad rap for not being accessible.

Or for being a tool to gatekeep.

Or for just sounding like plain, psychedelic nonsense (*bong rip* [Cotambara cofreely constructs costrength](https://hackage.haskell.org/package/profunctors-5.6.2/docs/Data-Profunctor-Strong.html#t:Cotambara)).

**I WANT TO FIX THIS**

I've been using pure FP in production for **10 years**. I programmed in Haskell, OCaml, Elm and PureScript. I've solved real-world problems in diverse industries, such as healthcare, dating, fintech and blockchain.

In my short (but eventful) career, I benefited a lot from foundational abstractions that took root in abstract algebra and category theory. I experienced first-hand the value of these concepts. This is good stuff, folks!

I want to demystify these concepts.

I want to show they're not scary.

I want to show they're actually useful for building real-world stuff.

I hope you're hyped (I know I am). Let's start.

> This is a series of blog posts and videos. I'm going to focus more on use cases rather than on deep theory but the underlying theory is important too.
>
> All code examples are provided in OCaml for illustration purposes. This is not an OCaml tutorial but basic familiarity with the language should be enough. Refer to the [OCaml::Learn](https://ocaml.org/docs) section to learn more about OCaml.
>
> All code snippets can be found on GitHub:
> - [chshersh/pragmatic-category-theory](https://github.com/chshersh/pragmatic-category-theory)

## What is Semigroup?

We start with one of the simplest yet powerful concepts — **semigroup**.

### Why Semigroup?

This abstraction supports quite a large number of diverse use cases:

1. MapReduce
1. CS Data Structures such as Segment Tree, Treap and Rope
1. Optimal multiplication and string concatenation algorithms
1. Blazing fast string builder
1. Composable lexicographic comparison API
1. Set and dictionary union
1. Combining config files, CLI and environment arguments
1. Composable validation
1. Composable logging
1. The Builder pattern from OOP
1. Sane JSON merging for structured logging

And we're going to look into **ALL OF THEM** in future parts.

You can see that such mathematical abstractions are expressive enough to implement common OOP patterns. However, they have the added benefit of being rooted in math and backed by thousands of years of research. This means you get so much for free!

So let's not waste any more time.

### So what is it actually?

A **semigroup** describes an operation of appending two values of some type to get a value of the same type.

> 👩‍🔬 For the sake of simplicity, here we're using the definition of semigroup from _abstract algebra_. For completeness, a Category Theory definition: a _semigroup_ is a hom-set in a semicategory with a single object. But let's stick with appending two values for now.

Here's a graphical explanation:

![Smooshing two things](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/539w2fuxx1er75bte8mn.png)

You may immediately say that this looks too generic! It's just appending two things, what's the big deal?!

And indeed, you can call this operation _append_, _add_, _multiply_, _combine_, _compose_, _merge_, _melt_, _fuse_, _apply_, _squash_, etc. It doesn't really matter, we don't gatekeep here on irrelevant details (my favourite one is **smoosh**). For consistency, I'll be using **append** everywhere.

But just to be more concrete, this concept can also be easily expressed in OCaml using [_module signatures_](https://courses.cs.cornell.edu/cs3110/2021sp/textbook/modules/signatures.html).

```ocaml
module type SEMIGROUP = sig
  type t
  val append : t -> t -> t
end
```

In this module signature, we have a type `t` and a binary function `append` that takes two values of type `t` and returns another value of type `t`. When implementing a module with this signature, a developer needs to specify a concrete type `t` and implement the `append` function.

However, there's one extra restriction. Not every `append` creates a Semigroup. This `append` operation must satisfy one requirement — **associativity**.

In other words, the following must be true:

```ocaml
append a (append b c) = append (append a b) c
```

And that's all! It's that simple! Although, for now, this may not look too interesting. Don't worry. Lots of real-world examples are waiting in future parts!

> 👩‍🔬 More formally, a **semigroup** is a pair of type `t` and a binary associative operation where the operands and the result all have the same type `t`.

## Examples

We'll see plenty of Semigroup examples as well as some counterexamples where this associativity requirement doesn't hold.

### Numbers

Let's start with trivial examples. Integer numbers form a semigroup. How can we append two numbers? Simple, just add them!

Here's how it looks in OCaml:

```ocaml
module IntAdd = struct
  type t = int
  let append = ( + )
end
```

It's pretty straightforward to show that associativity holds. We all know from school math that `a + (b + c) = (a + b) + c`. Not all examples will be that trivial though!

We can easily verify that this implementation does what we want using [utop](https://github.com/ocaml-community/utop) (an OCaml REPL):

```ocaml
utop # IntAdd.append 2 3 ;;
- : int = 5
```

> I already sense doubt in your eyes. A question is rising inside you:
>
> — _"Who the hell is going to `IntAdd.append` two numbers??? I can just use `+`!"_
>
> And you will be absolutely right. If you want to add numbers, you're just going to use the `+` operator. However, trivial examples help with onboarding complex concepts. And we'll see in future articles that even this simple example is quite useful.

Is this the only way to append two numbers? Surprisingly, not. We can also multiply them! And it'll be a valid Semigroup as well. The implementation is almost identical to `IntAdd`:

```ocaml
module IntMul = struct
  type t = int
  let append = ( * )
end
```

Let's verify that everything works:

```ocaml
utop # IntMul.append 2 3 ;;
- : int = 6
```

You can see that a single type (in our example, `int`) can have multiple ways to append its values. OCaml module system can handle this perfectly. The important takeaway here is that Semigroup is not defined just by a type, but also by the specific implementation of `append`.

> 🧑‍🔬 It's tempting to implement such modules for other number types, like `float`. Unfortunately, arithmetic operations for `float` are [not associative](https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html) under IEEE 754. In such cases, it's better to avoid providing modules entirely. We'll see why associativity matters later.

### Boolean

Another trivial example. Booleans also can form a Semigroup! The standard operations of _logical or_ and _logical and_ are one of the simplest examples.

Implementation in OCaml is quite similar to the previous ones:

```ocaml
module BoolAnd = struct
  type t = bool
  let append = ( && )
end

module BoolOr = struct
  type t = bool
  let append = ( || )
end
```

As always, we can leverage `utop` to see that everything works:

```ocaml
utop # BoolAnd.append true false ;;
- : bool = false

utop # BoolOr.append true false ;;
- : bool = true
```

> Proving that these operations satisfy _associativity_ is left as an exercise for the dedicated reader.

### Strings

Let's finally look at the first slightly less trivial and the first pragmatic real-world example!

It turns out that string concatenation is also a Semigroup!

The OCaml implementation is straightforward again:

```ocaml
module String = struct
  type t = string
  let append = ( ^ )
end
```

Verifying that it works:

```ocaml
utop # String.append "I know " "Semigroup!" ;;
- : string = "I know Semigroup!"
```

As a developer, you append strings all the time. You don't think about this simple operation in terms of semigroups. But the structure is there. Once you open this Pandora Box, you start noticing semigroups everywhere.

String concatenation happens to resemble number addition and boolean logical operations. JavaScript devs might actually be onto something.

The string append example is different in one other significant way. All previous operations (`+`, `*`, `&&` and `||`) satisfy a different property — **commutativity**. In other words, for them, the order of arguments for `append` doesn't matter, and the following holds:

```
append a b = append b a
```

String concatenation, in turn, is not commutative. The order of appending strings matters. But the operation is still associative, as can be seen in the following example:

```
(1)
append "Hello, " (append "OCaml " "World!")
= append "Hello, " "OCaml World!"
= "Hello, OCaml World!"

(2)
append (append "Hello, " "OCaml ") "World!"
= append "Hello, OCaml " "World!"
= "Hello, OCaml World!"
```

## Counterexample

At this point, you may start thinking that everything is a semigroup! However, life is cruel. Not everything is a semigroup.

We don't need to come up with an esoteric example. A simple number subtraction is not a semigroup because the associativity property doesn't work for it, as can be seen on the following example:

```
(1)
1 - (2 - 3)
= 1 - (-1)
= 2

(2)
(1 - 2) - 3
= (-1) - 3
= -4
```

Still, nothing prevents you from writing the following OCaml code:

```ocaml
module IntSub = struct
  type t = int
  let append = ( - )
end
```

> 👩‍🔬 This associativity requirement is a _semantic law_. You can choose not to follow it at your own risk and write code that satisfies the API but not the extra contract, as demonstrated above.
>
> If you decide not to follow the law, you can't reap the benefits it provides. Moreover, if you lose the semantics, then you can't take advantage of the nice properties that they will have. And we'll see in future parts what are those nice properties.

Fortunately, you can use tests to verify that modules satisfy the associativity law (either unit or property-based tests).

> **Exercise:** Can you come up with at least one more counterexample of semigroup?

## Conclusion

That's it for now! I wanted to keep the introduction light. But you're going to be mind-blown pretty soon. I promise (however, I don't give any refunds).

## Acknowledgement

Many thanks to people who proofread the early draft of this article and shared their invaluable feedback: [@_____C](https://x.com/_____C) [@adworse](https://x.com/adworse) [@DazzlingHazlitt](https://x.com/DazzlingHazlitt) [@egmaleta](https://x.com/egmaleta) [@int_index](https://x.com/int_index) [@janiczek](https://x.com/janiczek) [@jwdunne_dev](https://x.com/jwdunne_dev)

<hr>

> If you liked this blog post, consider following me on YouTube, X (formerly known as Twitter) or sponsoring my work on GitHub
>
> - [YouTube: @chshersh](https://youtube.com/c/chshersh)
> - [𝕏: @chshersh](https://twitter.com/ChShersh)
> - [GitHub Sponsors: Support @chshersh!](https://github.com/sponsors/chshersh)
