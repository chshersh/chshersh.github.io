---
title: 7 OCaml Gotchas
tags: ocaml, functional programming
shortName: "ocaml-gotchas"
updated: "July 29th, 2024"
---

I've been writing OCaml for about 1 year (check my previous post [8 months of OCaml after 8 years of Haskell](/blog/2023-12-16-8-months-of-ocaml-after-8-years-of-haskell.html)).

I enjoy OCaml. But as any other programming language, OCaml has its quirks. That's fine, you can enjoy imperfect things too. But it could be useful to learn about potential surprising behaviours.

In this blog post, I'm highlighting **7 OCaml gotchas**. Some of them might be obvious to experienced OCamlers. But I hope everyone can learn something new or at least enjoy reading!

Let's start.

## 1. Structural vs Physical equality

| **Property**    | **Rating** |
| --------------- | ---------- |
| Surprise factor | 🌕🌕🌕🌑🌑 |
| Severity        | ⚠️ |

Being bitten by different types of equalities in a language like JavaScript, you exhale with relief when you learn that in OCaml you can easily compare numbers with `==` and it doesn't allow you to compare values of different types 😮‍💨

```ocaml
utop # 255 == 255 ;;
- : bool = true

utop # 0 == false ;;
Error: This expression has type bool but an expression was expected of type int
```

However, quite soon, with horror, you realise that `==` doesn't work with strings!

```ocaml
utop # "OCaml" == "OCaml" ;;
- : bool = false
```

Or with lists:

```ocaml
utop # [1; 2; 3] == [1; 2; 3] ;;
- : bool = false
```

Or with pairs

```ocaml
utop # (true, 1) == (true, 1) ;;
- : bool = false
```

Or with optionals:

```ocaml
utop # Some 10 == Some 10 ;;
- : bool = false
```

Or literally with anything else!

Well, the thing is, OCaml has two equalities:

- `=`: structural, actually compares values
- `==`: physical, compares pointers to values

> As well as two inequalities, `<>` and `!=`. To figure out which one is physical and which is structural is left as an exercise for the reader.

So, to actually check values for equality, use `=`:

```ocaml
utop # "I Love OCaml" = "I Love OCaml" ;;
- : bool = true
```

> And for the love of god, configure your linter to warn on usages of `==`. How many bugs has it caused...

## 2. Nested `match-with`

| **Property**    | **Rating** |
| --------------- | ---------- |
| Surprise factor | 🌕🌗🌑🌑🌑 |
| Severity        | 🍹 |

Consider the following types:

```ocaml
type reason =
  | Waiting
  | Validating

type status =
  | Pending of reason
  | Cancelled
  | Done
```

Let's write a function to pattern match on a value of type `status` and convert the value to a string. We can use the `match-with` syntax in OCaml for this.

However, the following code doesn't compile!

```ocaml
let show_status status =
  match status with
  | Pending reason ->
    match reason with
    | Waiting -> "Pending: Waiting"
    | Validating -> "Pending: Validating"
  | Cancelled -> "Cancelled"
  | Done -> "Done"
```

The compilation error is:

```ocaml
File "lib/example.ml", line 16, characters 4-13:
16 |   | Cancelled -> "Cancelled"
         ^^^^^^^^^
Error: This variant pattern is expected to have type reason
       There is no constructor Cancelled within type reason
```

The explanation is that OCaml is not a layout-sensitive language 🙅

When matching on `reason`, the compiler thinks that the `| Cancelled -> ...` case is the next pattern, hence the error.

I know three fixes:

**1.** Put `()` around the nested `match` explicitly

```ocaml
let show_status status =
  match status with
  | Pending reason ->
    (match reason with
    | Waiting -> "Pending: Waiting"
    | Validating -> "Pending: Validating")
  | Cancelled -> "Cancelled"
  | Done -> "Done"
```

**2.** Move the only nested `match-with` to the end:

```ocaml
let show_status status =
  match status with
  | Cancelled -> "Cancelled"
  | Done -> "Done"
  | Pending reason ->
    match reason with
    | Waiting -> "Pending: Waiting"
    | Validating -> "Pending: Validating"
```

**3.** Extract nested `match-with` into a separate function

```ocaml
let show_reason reason =
  match reason with
  | Waiting -> "Pending: Waiting"
  | Validating -> "Pending: Validating"

let show_status status =
  match status with
  | Pending reason -> show_reason reason
  | Cancelled -> "Cancelled"
  | Done -> "Done"
```

## 3. Labelled and Optional Arguments

| **Property**    | **Rating** |
| --------------- | ---------- |
| Surprise factor | 🌕🌕🌕🌑🌑 |
| Severity        | 🍹 |

OCaml has labelled (aka named) and optional arguments.

However, if your function uses both labelled and optional arguments without positional arguments, you get a compiler error!

The following code implements a function that generates all numbers between the given two with an optional `step`:

```ocaml
let range ?(step = 1) ~from ~until =
  let rec loop i =
    if i > until
      then []
      else i :: loop (i + step)
  in
  loop from
```

Unfortunately, it doesn't compile!

```ocaml
File "lib/example.ml", line 21, characters 12-20:
21 | let range ?(step = 1) ~from ~until =
                 ^^^^^^^^
Error (warning 16 [unerasable-optional-argument]):
this optional argument cannot be erased.
```

The explanation is that you can specify both labelled and optional arguments in any order (you can mix and match):

```ocaml
range ~step:2 ~from:10 ~until:20  (* this is valid *)
range ~from:10 ~until:20 ~step:2  (* also valid! *)
```

So when you call the `range` function like this:

```ocaml
range ~from:10 ~until:20
```

OCaml doesn't know whether you want to apply the default value of `step` or whether you want to have a partially applied `range` with only the default argument missing!

One of the solutions in this case is to add a positional argument of type `unit` at the end of the function, like this:

```ocaml
let range ?(step = 1) ~from ~until () =
  let rec loop i =
    if i > until
      then []
      else i :: loop (i + step)
  in
  loop from
```

Alternatively, if it makes sense, you can convert one or more labelled arguments to positional to avoid adding an extra `unit`.

## 4. Type inference doesn't work well: Part 1

| **Property**    | **Rating** |
| --------------- | ---------- |
| Surprise factor | 🌕🌕🌕🌗🌑 |
| Severity        | ⚠️ |

OCaml has type inference and it works even if you define your own custom types. Usually, it works pretty well.

Like in the example below, when we have a record type but we don't write explicit type annotations, OCaml is smart enough to figure out the types:

```ocaml
type book =
  { author: string;
    title: string;
    words: int;
  }

let is_novel book =
  book.words >= 50000
```

The OCaml compiler can easily infer the type of `is_novel` as

```ocaml
val is_novel : book -> bool
```

However, if you move the type definition into a separate module, OCaml gives up immediately:

```ocaml
(* --- book.ml --- *)
type book =
  { author: string;
    title: string;
    words: int;
  }

(* --- example.ml --- *)
let is_novel book =
  book.words >= 50000
```

The error message is:

```ocaml
File "lib/example.ml", line 31, characters 7-12:
31 |   book.words >= 50000
            ^^^^^
Error: Unbound record field words
```

On one hand, it makes sense. Trying to guess the correct type across all possible modules and dependencies can decrease the compilation speed and introduce surprising behaviour.

However, this can be quite annoying when dealing with lots of types.

One solution is to specify the type explicitly in the inline type signature:

```ocaml
let is_novel (book : Book.book) =
  book.words >= 50000
```

Alternatively, you can use the local open syntax:

```ocaml
let is_novel book =
  Book.(book.words) >= 50000
```

## 5. Type Inference doesn't work well: Part 2

| **Property**    | **Rating** |
| --------------- | ---------- |
| Surprise factor | 🌕🌕🌕🌕🌑 |
| Severity        | ⚠️ |

You want to write a function that creates a list by replicating the same element `n` times.

The implementation is straightforward:

```ocaml
let replicate n x = List.init n (fun _ -> x)
```

This function works and OCaml correctly infers the polymorphic type of `replicate`:

```ocaml
val replicate : int -> 'a -> 'a list
```

Now, let's say we replicate numbers five times specifically a lot, and we want to create a helper function by partially applying `replicate` to `5` (honestly, it's easier to write the code than to explain it in English):

```ocaml
let replicate_5 = replicate 5
```

This function is partially applied only to the number, so you'd still expect it to be polymorphic, right? Oh, boy...

Unfortunately, if you use `replicate_5` two times with different types, the OCaml compiler is not happy:

```ocaml
let two_lists =
  let five_bools = replicate_5 true in
  let five_ints = replicate_5 21 in
  (five_bools, five_ints)
```

The error message is:

```ocaml
File "lib/example.ml", line 42, characters 30-32:
42 |   let five_ints = replicate_5 21 in
                                   ^^
Error: This expression has type int but an expression was expected of type
         bool
```

You won't believe what is the fix the problem.

The fix is to avoid partial application for polymorphic functions:

```ocaml
let replicate_5 x = replicate 5 x
```

Unfortunately, I know why it's done this way. OCaml has valid reasons for this behaviour, believe me (you can read on [Weak polymorphism](https://v2.ocaml.org/manual/polymorphism.html)). Still, it makes me a bit annoyed.

## 6. Implicit variable quantification

| **Property**    | **Rating** |
| --------------- | ---------- |
| Surprise factor | 🌕🌕🌕🌕🌕 |
| Severity        | 💀 |

I want to write a function that takes an argument and returns it without changes. Again, the implementation is pretty simple:

```ocaml
let id x = x
```

This function doesn't do anything specific, and OCaml correctly infers the polymorphic type:

```ocaml
val id : 'a -> 'a
```

I can write this function slightly differently by using an anonymous function:

```ocaml
let id = fun x -> x
```

And, if I want, I can even specify the inline type signature for the entire function

```ocaml
let id : 'a -> 'a = fun x -> x
```

> The example may look artificial, but sometimes I don't want to bother with creating a separate `.mli` file, and I want to have type signatures written explicitly

What I can also do, is completely ignore the type signature and write any nonsense in my implementation:

```ocaml
let id : 'a -> 'a = fun _ -> 123
```

And the compiler error will be.. Or, wait, there's no error this time. OCaml is perfectly fine with this code 🥲

Turns out, if I really want to enforce the fact that the alpha `'a` indeed stands for a polymorphic variable, I need to introduce explicit quantification like this:

```ocaml
let id : 'a . 'a -> 'a = fun x -> x
```

And with this, I can no longer write nonsense.

## 7. Right-to-left order of execution

| **Property**    | **Rating** |
| --------------- | ---------- |
| Surprise factor | 🌕🌕🌕🌕🌕 |
| Severity        | 🍹 |

If you want to write a function that takes two actions and runs them sequentially, like this one:

```ocaml
let (>>) action1 action2 = action1; action2
```

And then you want to use it:

```ocaml
let run_example () =
  print_endline "Hello, " >> print_endline "World"
```

You'll be surprised by the actual behaviour:

```ocaml
utop # run_example () ;;
World
Hello,
- : unit = ()
```

Apparently, OCaml evaluates arguments from right to left, so the second argument is evaluated first.

> In fact, the order of evaluation is not even guaranteed.

The only solution is to avoid relying on this behaviour. Make your functions accept arguments of type `unit -> ...` or `Lazy.t`, so the functions can control the execution order of their arguments.

## Conclusion

That's all! If you found anything surprising in OCaml, feel free to share!

As I mentioned, every language has some pitfalls. If you don't see them in your favourite language, you either don't know it well enough or nobody uses this language anymore.

Human brains are really good at focusing on bad things. However, I wrote this blog post not to say that OCaml is bad but rather to reduce the frustration when experiencing something surprising for the first time 😌

> If you liked this blog post, consider following me on YouTube, X (formerly known as Twitter) or sponsoring my work on GitHub
>
> - [YouTube: chshersh](https://youtube.com/c/chshersh)
> - [𝕏: chshersh](https://twitter.com/ChShersh)
> - [GitHub Sponsors: Support chshersh!](https://github.com/sponsors/chshersh)
