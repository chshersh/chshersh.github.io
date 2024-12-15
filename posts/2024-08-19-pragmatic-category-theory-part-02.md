---
title: "Pragmatic Category Theory | Part 2: Composing Semigroups"
description: Learning how to compose primitive Semigroups
tags: ocaml, functional programming, category theory, math
shortName: "pragmatic-category-theory-part-2"
updated: "August 20th, 2024"
---

You'll notice the following Functional Programming pattern many times:

1. You define trivial fundamental blocks.
2. You define trivial ways to compose blocks.
3. Suddenly, you end up with something extremely powerful.

I don't know how it works but it works every time. Trust the process.

Thus, it's important to develop the skill of noticing a particular pattern in diverse situations. We need to pump that [Tetris Effect](https://en.wikipedia.org/wiki/Tetris_effect) of yours.

To develop an even further understanding of the Semigroup concept, we will explore more Semigroup examples and learn a composition of Semigroups to solve a real-world problem.

> ⚠️ **CONTENT WARNING** ⚠️ This section may contain some advanced OCaml code. I'll do my best to explain the concepts in a beginner-friendly way though.

> All code snippets can be found on GitHub:
>
> - [chshersh/pragmatic-category-theory](https://github.com/chshersh/pragmatic-category-theory)

## Minimum and Maximum

We learned about two ways of appending numbers:

1. Adding
2. Multiplying

What if I told you, there are more ways? In fact, getting the minimum of two numbers is also a valid Semigroup that satisfies associativity!

In OCaml, this looks similar to what we had before:

```ocaml
module IntMin = struct
  type t = int
  let append x y = if x <= y then x else y
end
```

Verifying in `utop` that things work:

```ocaml
utop # IntMin.append 5 3 ;;
- : int = 3
utop # IntMin.append 7 10 ;;
- : int = 7
```

Reasonably, if the minimum operation is a Semigroup, _maximum_ should be a Semigroup too:

```ocaml
module IntMax = struct
  type t = int
  let append x y = if x >= y then x else y
end
```

Again, verifying in `utop` that things work:

```ocaml
utop # IntMax.append 5 3 ;;
- : int = 5
utop # IntMax.append 7 10 ;;
- : int = 10
```

Congratulations! You learned two more examples of Semigroups!

## Generalising Min and Max

This all sounds cute and nice but this series is called "Pragmatic Category Theory". And nothing can be further from being pragmatic as implementing a gazillion _min_ and _max_ modules for every single type.

Indeed, let's take this one step further here. Instead of saying

- _`int` with the minimum operation is a Semigroup_

We want to be able to say (in OCaml):

- _Any type that supports comparison is a Semigroup with the minimum operation_

Fortunately, the OCaml's module system is powerful enough to express this idea in the code.

> Other mainstream languages will use their specific features (generics and interfaces in Java, traits in Rust, typeclasses in Haskell, and in Python... just a vibe check on the value).

First, how can we say that values of a given type can be compared? We're going to use a module again! Similar to the `SEMIGROUP` module type signature, we'll have the `COMPARABLE` module type signature:

```ocaml
module type COMPARABLE = sig
  type t
  val compare : t -> t -> int
end
```

> Here `compare` returns `int` following the popular convention. The result of `compare` has the following meaning:
> - `compare x y = 0` means `x = y`
> - `compare x y < 0` means `x < y`
> - `compare x y > 0` means `x > y`

Now we need a way to express that the implementation of the _minimum Semigroup_ depends on the implementation of `COMPARABLE`. This is relatively straightforward to do in OCaml using [_module functors_](https://ocaml.org/docs/functors):

> 👩‍🔬 Fun fact! **Functor** is another popular and extremely useful concept from Category Theory. We'll get to it later but module functors are called functors for a reason.

```ocaml
module Min(C: COMPARABLE) = struct                      (* 1 *)
  type t = C.t                                          (* 2 *)
  let append x y = if C.compare x y <= 0 then x else y  (* 3 *)
end
```

Let's digest this piece of code. Here we say the following:

1. **Line 1:** We define a new module `Min`.
2. **Line 1:** The `Min` module needs another module `C` that implements `COMPARABLE`.
3. **Line 2:** The type `t` inside the `Min` module is the same as inside `COMPARABLE`. This makes sense because we take the minimum between the values of the type we can compare.
4. **Line 3:** We use the `compare` function from the module `C` to compare values and return the smallest one.

Normally, now we would have to implement the `COMPARABLE` module signature for all types where we want to get the minimum. Fortunately, due to how modules work, every existing module that defines `type t` and `val compare` with needed signatures will do!

And, surprisingly, all common modules implement the desired interface. Did we get lucky or was it intentional? 😉

Let's see how the usage looks in `utop`:

```ocaml
utop # module IntMin = Min(Int) ;;
utop # IntMin.append 3 5 ;;
- : int = 3

utop # module FloatMin = Min(Float) ;;
utop # FloatMin.append 5.2 3.1 ;;
- : float = 3.1
```

The main motivation for this section is that we want to build _reusable abstractions_ that we can leverage in diverse scenarios. If we have to redefine lots of trivial stuff from scratch every time, this quickly gets tiresome. Fortunately, we can avoid this in many cases.

Besides, we can see how such abstractions play well with the rest of the language ecosystem.

## First and Last

We learned about four ways of appending numbers:

1. Adding
2. Multiplying
3. Minimum
4. Maximum

What if I told you, there are more ways?? In fact, getting the first of two numbers is also a valid Semigroup that satisfies associativity!

In OCaml, this looks similar to what we had before:

```ocaml
module IntFirst = struct
  type t = int
  let append x _ = x
end
```

Verifying in `utop` that things work:

```ocaml
utop # IntFirst.append 3 5 ;;
- : int = 3
utop # IntFirst.append 5 3 ;;
- : int = 5
```

Similarly, getting the last element of two is also a valid Semigroup! Hmm, it's almost like every example has a twin...

```ocaml
module IntLast = struct
  type t = int
  let append _ y = y
end
```

Again, verifying in `utop` that things work:

```ocaml
utop # IntLast.append 3 5 ;;
- : int = 5
utop # IntLast.append 5 3 ;;
- : int = 3
```

An observant eye may notice, that there's nothing special about `int` that allows one to take the first element. There's nothing special needed at all! You can take the first of any value, you don't need anything!

The definitions of `IntFirst` and `IntLast` can be generalised to work with every type similarly to _minimum_ and _maximum_. I won't go into the details here but you can expand the following section to read the code:

<details>
  <summary>Generalised First and Last</summary>
```ocaml
module First(T : sig type t end) = struct
  type t = T.t
  let append x _ = x
end

module Last(T : sig type t end) = struct
  type t = T.t
  let append _ y = y
end
```
</details>

## Taking a step back

We learned about six ways of appending numbers:

1. Adding
2. Multiplying
3. Minimum
4. Maximum
5. First
6. Last

What if I told you, there are more ways???

But let's take a step back. You might start thinking, "Aren't we stretching the definition of _append_ too much?"

Indeed, I can follow this train of thought:

- Concatenating two strings is kinda like append, ok.
- Adding two numbbers — fine, append too.
- Minimum and Maximum — well, we're not really _appending_, we're _choosing_.
- Last and First — we can't be further from _appending_! We're, in fact, _discarding_ values!

You can see that English doesn't precisely describe the concept. Math is strict. It doesn't try to be fancy. It just says that a Semigroup has a _binary associative operation_. It doesn't name it but we need names to communicate ideas with each other.

If we think about _types as sets_ (e.g. `bool` is a set that has only two elements: `true` and `false`; `int` is a set that has 2^64 elements, etc.), we can view Semigroup is a function that picks two elements from a set and returns another element. This element can be one of the given two or completely different.

This concept visualised:

![A set view of Semigroup](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/sbu1jfwv4j24hhs44xox.png)

This is not the true Category Theory definition of a Semigroup but it's equivalent and helps build the intuition.

You can see that when presented like this, the binary associative operation in Semigroup is not always the strict **append** in the English meaning. For this reason, such an operation doesn't usually have a name in OCaml or other FP languages.

OCaml can define custom operators. So, another common definition of `SEMIGROUP` is the following:

```ocaml
module type SEMIGROUP = sig
  type t
  val (<+>) : t -> t -> t
end
```

But let's stick with `append` for now. Abusing operators can get out of hand pretty quickly.

## List

Let's look at another example of a Semigroup. We know that we can concatenate strings and this is a valid Semigroup. But why stop here? We can also concatenate lists, arrays, vectors, sequences, trees, and so on.

So List is also a valid Semigroup with `append` being list concatenation (the `@` operator in OCaml).

If we fix the list element type to something like `int`, we can define the list Semigroup trivially:

```ocaml
module IntList = struct
  type t = int list
  let append = ( @ )
end
```

To go one step further, and define a single `List` Semigroup for all lists, we need to parametrise our `List` module with a module that has just type and this type will be our list element:

```ocaml
module List(T : sig type t end) = struct
  type t = T.t list
  let append = ( @ )
end
```

I won't go into the details of what's going on but because we can't say `type t = 'a list`, we need to bring the type of a list element externally, so we'll depend on an anonymous module that has only type `t` inside.

The implementation looks scary but the usage in `utop` is no different from our `Min` module from before:

```ocaml
utop # module IntList = List(Int) ;;
utop # IntList.append [3; 1; 2] [4; 5] ;;
- : int list = [3; 1; 2; 4; 5]
```

## Pair

You'll be laughing to learn that all of the content before was just a preamble to this section. The title of this part is "Composing Semigroups", so let's finally learn how to compose Semigroups.

So, okay, we can concatenate two strings. We also can append two numbers. What if I want to concatenate two strings **AND** append two numbers AT THE SAME TIME?

If I can append things, it's natural to desire to append multiple different things simultaneously.

In other words, if I have _a pair of things_, I want to append two pairs, where the first elements of a pair are appended, and the second elements of the pairs are appended correspondingly.

So, to rephrase: if a type `a` is a Semigroup and type `b` is a Semigroup then a pair of types `a * b` is naturally a Semigroup.

In OCaml, this can be implemented straightforwardly using module functors again.

```ocaml
module Pair(S1: SEMIGROUP) (S2: SEMIGROUP) = struct  (* 1 *)
  type t = S1.t * S2.t                               (* 2 *)
                                                     (* 3 *)
  let append (a1, b1) (a2, b2) =                     (* 4 *)
    (S1.append a1 a2, S2.append b1 b2)               (* 5 *)
end
```

What it says:

1. **Line 1:** We define a Semigroup called `Pair`.
2. **Line 1:** It depends on two other Semigroups called `S1` and `S2` respectively.
3. **Line 2:** Our type is a pair of types `S1.t` and `S2.t`. So we just create a pair of two given types.
4. **Line 4:** Our `append` takes two pairs, so we pattern match on them immediately.
5. **Line 5:** When we append two pairs, we append the first elements using the `append` operation from `S1` and the second elements using `append` from `S2`.

> ⚠️ **SPOILER ALERT:** Did I mention that two components of a pair are appended independently, meaning that they can be appended in parallel for a performance increase? 🤫

This may look scary but I hope that the usage example in `utop` clarifies things:

```ocaml
utop # module PairStringInt = Pair(String)(IntAdd) ;;
utop # PairStringInt.append ("foo", 3) ("bar", 5) ;;
- : string * int = ("foobar", 8)
```

Another cute usage is finding the minimum and maximum among multiple numbers simultaneously.

We can easily find the minimum and maximum among three numbers using a composition of the `Min` and `Max` semigroups:

```ocaml
utop # module MinMax = Pair(Min(Int))(Max(Int)) ;;
utop # MinMax.append (3, 3) (MinMax.append (7, 7) (5, 5)) ;;
- : int * int = (3, 7)
```

This may look intimidating, so let's debug this code using the famous FP technique called **equational reasoning**. We will just apply functions step-by-step to arrive at our result.

```ocaml
MinMax.append (3, 3) (MinMax.append (7, 7) (5, 5))
= MinMax.append (3, 3) (5, 7)
= (3, 7)
```

The _min_ operation knows nothing about _max_, and _max_ knows nothing about _min_. They work on different parts of a pair independently. And by composing them, we're able to calculate both operations at the same time.

Generalising this usage from three pairs to a list, we can find the minimum, maximum, sum, product, first, and last element of the list in **ONE SINGLE TRAVERSAL**! It becomes just a matter of composing the needed Semigroups, and we'll look into this example in detail in one of the future parts.

## This is getting "chunky"

Now, let's look at a promised real-world example.

I'm developing a [GitHub TUI](https://github.com/chshersh/github-tui) in OCaml. The TUI rendering might get complex since at the end of the day, everything needs to be printed as lines to the terminal. But a single line might contain different parts formatted differently (some are bold, some are not; some are coloured, some are not);

![GitHub TUI Example](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6nfpzl2eml4oykvir8h4.png)

So I defined a `chunk` type to represent a part of the string with formatting:

```ocaml
(* --- chunk.mli --- *)
type t = {
  styles : Style.t;
  string : string;
}
```

And so my line of text is a list of chunks. But here's the catch.

During rendering, I need to know the length of strings, so I can do padding and alignment properly. Traversing the entire list of chunks to calculate its length every time is quite expensive. So I'm just storing the length of the line alongside the list of chunks. And when I'm appending two lines, I'm appending their lengths respectively.

In the code, it looks like this:

```ocaml
(* --- line.mli --- *)
type t

(** Append two lines into a single line. *)
val append : t -> t -> t


(* --- line.ml --- *)
type t = {
  chunks : Chunk.t list;
  length : int;
}

let append line1 line2 =
  let chunks = line1.chunks @ line2.chunks in
  let length = line1.length + line2.length in
  { chunks; length }
```

Essentially, I created a Pair Semigroup by composing the Int Add Semigroup and List Semigroup.

This series is called "Pragmatic Category Theory", and it's more pragmatic to create a custom record with the custom `append` operation rather than using the `Pair` module functors machinery directly. So an important lesson here:

- **Ideas > Implementations**

If you have enough programming experience, you can come up with this simple `line` type on your own without knowing the concept of Semigroup. After all, then something is really good, you naturally tend to use it more, even if you're not aware of all the underlying concepts.

However, in this rendering example, the _associativity_ property of a Semigroup becomes extremely crucial. And since this part is reaching its limit, we'll look into associativity closely in the next part.

## Conclusion

I hope this section was still interesting! Maybe some things look not so useful, or too trivial while others look too complex.

Semigroup is a **deep** concept, so I hope that a smooth introduction will help to demystify it even if unloading the entire context takes a while.

In the next section, we'll finally learn why associativity matters. And there'll be many more pragmatic examples. Be patient!

## Acknowledgement

Many thanks to people who proofread the early draft of this article and shared their invaluable feedback: [_____C](https://x.com/_____C) [sverien](https://x.com/sverien)
