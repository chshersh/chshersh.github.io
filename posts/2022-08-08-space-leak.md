---
title: Avoiding space leaks at all costs
description: Guidelines for avoding space leaks in Haskell programs
tags: haskell, performance
shortName: space-leak
---

Haskell is a purely functional **lazy** programming language. The
world doesn't have a lot of lazy-by-default PLs. In fact, all
mainstream languages have **eager** evaluation models.

You may argue it's because eager evaluation is better (because this is
how the world works, obviously, only good things are popular). I tend
to think this happened because implementing the lazy evaluation model
is more difficult and nobody wanted to bother.

In any case, both _lazy_ and _eager_ evaluations have their own
advantages and drawbacks. But this post is not about
[comparing different evaluation semantics][comparing-lazy] and their
trade-offs. I'd like to talk about living with the consequences of our
choices.

[comparing-lazy]: https://www.tweag.io/blog/2022-05-12-strict-vs-lazy/

Haskell programs are infamous for having lots of space leaks. This is
the result of Haskell choosing the lazy evaluation model and not
designing the language around preventing such type of memory usage
errors.

Investigating and fixing space leaks brought tons of frustration to
Haskell developers. Believe it or not, I'm not a fan of space leaks
either. However, instead of fighting the fire later, you can use
several techniques to prevent the catastrophe in the first place.

In this blog post, I'm going to describe several safeguards you can
put in your codebase to avoid seeing any space leaks in your Haskell
programs.

Space leaks can happen in any programming language but here I'm
focusing on Haskell-specific ways to avoid space leaks. These
guidelines will be helpful to all Haskell developers who want to
improve the performance and memory usage of their Haskell programs
while saving their precious time by avoiding the need to debug
annoying memory troubles.

## What is a Space Leak?

A **space leak** occurs when a computer program uses more memory than
necessary.

In this form, the definition is too broad. Who am I to tell the
computer how much memory it needs??? The machine knows better than
mere mortals 😤 But usually, space leak occurs when a program uses
more memory "accidentally" or "unintentionally".

To understand the problem, let's look at a simple implementation of a
function that adds all elements in a list. And we're also going to
apply our function to the list of all integers from 1 to 1 million:

```haskell
module Main where

add :: [Int] -> Int
add []       = 0
add (x : xs) = x + add xs

main :: IO ()
main = print $ add [1 .. 1000000]
```

We can compile this Haskell program and ask GHC **R**un**T**ime
**S**ystem (RTS) to print its memory usage stats:

```shell
$ ghc Main.hs
[1 of 1] Compiling Main             ( Main.hs, Main.o )
Linking Main ...

$ ./Main +RTS -t
500000500000
<<ghc: 145311416 bytes, 28 GCs, 13277046/31810960 avg/max bytes residency (4 samples), 66M in use, 0.000 INIT (0.000 elapsed), 0.061 MUT (0.062 elapsed), 0.106 GC (0.106 elapsed) :ghc>>
```

The relevant metric here is _max bytes residency_ which is 31810960
bytes (~31 MB). This is how much actual data we keep in memory at the
program's peak memory usage.

Actual program memory usage can be checked with the `time` tool by
passing the `-v` flag and looking at the _Maximum resident set size_
metric:

```shell
$ /usr/bin/time -v ./Main
500000500000
	Command being timed: "./Main"
	User time (seconds): 0.13
	System time (seconds): 0.02
	Percent of CPU this job got: 98%
	Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.16
	Average shared text size (kbytes): 0
	Average unshared data size (kbytes): 0
	Average stack size (kbytes): 0
	Average total size (kbytes): 0
	Maximum resident set size (kbytes): 70692
	Average resident set size (kbytes): 0
	Major (requiring I/O) page faults: 0
	Minor (reclaiming a frame) page faults: 16963
	Voluntary context switches: 1
	Involuntary context switches: 18
	Swaps: 0
	File system inputs: 0
	File system outputs: 0
	Socket messages sent: 0
	Socket messages received: 0
	Signals delivered: 0
	Page size (bytes): 4096
	Exit status: 0

```

We see the value of 70692 KB (or ~70 MB). So, our Haskell program
actually uses twice as much memory as our actual data observed by GHC.

> 👩‍🔬 This is explained by the implementation of Garbage Collector
> (GC) in GHC. The GC needs twice as much memory to copy all live data
> from one half to another "empty" half during the copying phase. So
> any Haskell program will actually require at least twice as much
> memory as you actually use.

> ℹ️ We can notice that GHC reports "66M in use" and it's quite close
> to our 70 MB reported by `time`. So we can use this number from RTS
> for now to check the actual memory usage.

Our Haskell program consumes so much memory because our implementation
of `add` is highly inefficient. For now, this has nothing to do with
lazy evaluation. Such implementation will be slow in every
language. It happens because `add` doesn't use tail-call recursion.

To understand the problem better, let's look at finding a sum of 5
numbers using the [Equational Reasoning][equational] debugging
technique:

[equational]: https://gilmi.me/blog/post/2020/10/01/substitution-and-equational-reasoning

```haskell
sum [1, 2, 3, 4, 5]
= 1 + sum [2, 3, 4, 5]
= 1 + (2 + sum [3, 4, 5])
= 1 + (2 + (3 + sum [4, 5]))
= 1 + (2 + (3 + (4 + sum [5])))
= 1 + (2 + (3 + (4 + (5 + sum []))))
= 1 + (2 + (3 + (4 + (5 + 0))))
= 1 + (2 + (3 + (4 + 5)))
= 1 + (2 + (3 + 9))
= 1 + (2 + 12)
= 1 + 14
= 15
```

You can see that we're storing the entire list as nested un-evaluated
additions and we can't reduce them until we go through the entire
list.

> 👩‍🔬 This is especially relevant for non-materialized lists like `[1
> ... 1000]`. Such a range expression doesn't allocate a thousand
> numbers immediately but rather produces them on demand. However,
> with our naive implementation of `add` we are actually going to
> store in memory all elements of the list.

<hr>

Usually, such problems are solved by rewriting the implementation to
use Tail-Call Optimization (TCO). Let's do this with `add`:

```haskell
add :: [Int] -> Int
add = go 0
  where
    go :: Int -> [Int] -> Int
    go acc [] = acc
    go acc (x : xs) = go (acc + x) xs
```

If we run our program with this new implementation, we won't see any
memory usage improvements. In fact, our performance becomes even
worse!

```shell
$ ./Main +RTS -t
500000500000
<<ghc: 153344184 bytes, 36 GCs, 17277505/46026632 avg/max bytes residency (5 samples), 93M in use, 0.001 INIT (0.001 elapsed), 0.046 MUT (0.046 elapsed), 0.193 GC (0.193 elapsed) :ghc>>
```

Now it's 93 MB instead of the previous 66 MB. Not so much for an
optimization then, heh 🥲

The new implementation of `add` is properly TCO-ed but now we actually
hit lazy evaluation problems. If we apply equational reasoning again,
we see the root cause:

```haskell
sum [1, 2, 3, 4, 5]
= go 0 [1, 2, 3, 4, 5]
= go (0 + 1) [2, 3, 4, 5]
= go ((0 + 1) + 2) [3, 4, 5]
= go (((0 + 1) + 2) + 3) [4, 5]
= go ((((0 + 1) + 2) + 3) + 4) [5]
= go (((((0 + 1) + 2) + 3) + 4) + 5) []
= ((((0 + 1) + 2) + 3) + 4) + 5
= (((1 + 2) + 3) + 4) + 5
= ((3 + 3) + 4) + 5
= (6 + 4) + 5
= 10 + 5
= 15
```

We still retain our entire list as delayed additions. Haskell laziness
explains such behaviour but it might be unexpected when observed for
the first time.

Lazy-by-default evaluations has their own benefits but it's not what
we're looking for here. What we want is to add numbers to our
accumulator **immediately**.

Fortunately, this is easily possible with Haskell. You need to enable
the [BangPatterns][bang-patterns] feature and use exclamations `!` in
front of patterns for variables where you want the evaluation to be
performed eagerly.

```haskell
{-# LANGUAGE BangPatterns #-}

add :: [Int] -> Int
add = go 0
  where
    go :: Int -> [Int] -> Int
    go !acc [] = acc
    go !acc (x : xs) = go (acc + x) xs
```

Now, if we run our program, we'll see that it uses a more reasonable 5
MB now!

```shell
$ ./Main +RTS -t
500000500000
<<ghc: 120051896 bytes, 29 GCs, 36312/44328 avg/max bytes residency (2 samples), 5M in use, 0.000 INIT (0.000 elapsed), 0.044 MUT (0.044 elapsed), 0.001 GC (0.001 elapsed) :ghc>>
```

Moreover, not only did we significantly decrease memory usage in this
example but memory usage won't grow if the data size grows. If we
increase the list size from 1 million to 10 million, memory
consumption in our first naive implementation will grow from 66 MB to
628 MB (a job for a true 10x Haskell developer). However, our
optimized implementation will continue using 5 MB no matter how we
increase the size of the data.

<hr>

In this section, we looked at the definition of space leak and how it
can be fixed in a simple Haskell program. In the next section, we're
going to look at common ways for preventing space leaks.

## Lazy guidelines

Haskell is especially sensitive to the presence of space leaks in
programs because both performance and memory usage suffer. Since
Haskell has a GC, it spends more time moving around unnecessarily
allocated memory.

**The more garbage you have, the more garbage you need to clean up.** 👆

So I would like to share some guidelines for avoiding space leaks in
Haskell programs. Following these guidelines doesn't guarantee that
you'll never ever see a space leak but it greatly reduces the chances
of getting one. Don't know about you folks but I'd like to improve my
survival chances at any cost.

> ⚠️ Applying the below techniques blindly may backfire if you tried to
> be too clever with some Haskell tricks. For instance, if you use the
> [Tying the knot][knot] technique, following the below suggestions
> may result in your code hanging which is much worse than having a
> space leak!

[knot]: https://www.fpcomplete.com/blog/tying-the-knot-haskell/

### Use BangPatterns in strict accumulators

::: {.thought}

[BangPatterns][bang-patterns] is your second best friend.

:::

The problem and the solution were demonstrated at the beginning of
this article. The general suggestion is to use strict accumulators
when using the [recursive go pattern][go] or similar to avoid the
accumulation of unevaluated expressions in a single variable.

[go]: https://kowainik.github.io/posts/haskell-mini-patterns#recursive-go

You don't need to add `!` blindly everywhere. For example, the
following code evaluates the accumulator of type `Set` on every
recursive call anyway, so you don't need to use the `!`-patterns in
the `acc` variable:

```haskell
ordNub :: forall a . Ord a => [a] -> [a]
ordNub = go mempty
  where
    go :: Set a -> [a] -> [a]
    go _ [] = []
    go acc (x : xs)
        | Set.member x acc = go acc xs
        | otherwise        = x : go (Set.insert x acc) xs
```

But if you don't force the evaluation of an accumulator on every
recursive steps with various functions, the strict pattern matching
`!` comes to the rescue.

![Using BangPatterns to reduce space leaks](/images/space-leak/space-leak-bang-patterns.jpeg)

### StrictData

::: {.thought}

Enable the `StrictData` feature.

:::

A simple thing you can do today to reduce the number of space leaks is
to enable the [StrictData][strict-data] language feature. Either in
each module:

```haskell
{-# LANGUAGE StrictData #-}
```

Or, even better, in your package `.cabal` file globally:

```haskell
  default-extensions: StrictData
```

> ℹ️ Instead of enabling this feature, you can specify individual
> fields as strict using `!` in the type definition but this approach
> is more cumbersome and error-prone.

> 👩‍🔬 It's extremely rare when you need lazy fields intentionally
> (you can use `~` to mark fields as lazy when `StrictData` is
> enabled). One example when lazy fields are needed explicitly is [the
> `Message` type in the `co-log` logging library][co-log].

[co-log]: https://github.com/co-log/co-log/blob/65b89152d0ae61ac99a56fbe645ed28cfacd717e/src/Colog/Message.hs#L107-L111

In fact, enabling `StrictData` by default in your `.cabal` file today
is the simplest thing you can do to avoid half of the space leaks! 👏

> ℹ️ As an additional benefit of enabling `StrictData`, GHC will now
> produce a compiler error instead of a warning when you
> [forget to initialise some of the fields][record-fields].

[record-fields]: https://kodimensional.dev/recordwildcards#strict-construction

![Enabling StrictData to fight space leaks](/images/space-leak/space-leak-strict-data.jpg)

Lazy evaluation helps to avoid unnecessary evaluation when you don't
use all the arguments in the result. But the reality shows that with
custom data types you almost always want all their fields eventually
(serialization to Text, JSON, DB; aggregation of all fields in a
single value, etc.). So laziness doesn't actually reduce performance
overhead, it only delays evaluation to the future by keeping
unnecessary data in memory longer than it should be.

Let's look at an example of a space leak:

```haskell
data QueryResult = MkQueryResult
    { queryResultUniqueIds :: Set ResponseId
    , ...
    }

aggregateApi :: UserId -> App QueryResult
aggregateApi userId = do
    response1 <- queryApi1 userId
    response2 <- queryApi2 userId
    response3 <- queryApi3 userId
    ...
    pure QueryResult
        { queryResultUniqueIds = Set.fromList $ response1 <> response2 <> response3
        , ...
        }
```

In this example, the code queries data from several APIs. Each
individual response can be potentially huge. However, if we don't use
`StrictData`, we will keep all the `response1`, `response2` and
`response3` values in memory until we try to evaluate the
`queryResultUniqueIds` field.

Now, imagine several concurrent calls to the `aggregateApi` function
and each of them keeps more memory around than it needs. And the
problem becomes even worse. ⏲💣

Enabling `StrictData` would prevent such a problem here.

### Consume local values eagerly

::: {.thought}

Use `!`-patterns and the `$!` strict application operator to evaluate
values of local variables eagerly.

:::


Let's look at a simplified version of code from the previous section:

```haskell
aggregateApi :: UserId -> App (Set ResponseId)
aggregateApi userId = do
    response1 <- queryApi1 userId
    response2 <- queryApi2 userId
    response3 <- queryApi3 userId
    ...
    pure $ Set.fromList (response1 <> response2 <> response3)
```

This program still has space leaks and enabling `StrictData` won't
help because our value of type `Set` is not part of a data type.

Here you can get rid of a potential space leak by evaluating the
result of `Set.fromList` eagerly with the help of `$!`:

```haskell
    ...
    pure $! Set.fromList (...)
```

> ⚠️🧠😒 **PEDANTIC NERD WARNING**: Strictly speaking (pun intended),
> usage of `$!` eliminates the space leak because of the `Set` data
> structure specifics. The `$!` operator evaluates only up until
> Weak-Head Normal Form (WHNF). Or, in simple words, only to the first
> constructor. Internally `Set` is implemented with balanced
> AVL-tree. To figure out the root constructor, the data structure
> requires to insert all elements. That's why we don't see a space
> leak. But if `Set` was implemented naively using simple binary
> trees, it would be possible to stil have space leak even after using
> `$!`.

The idea behind this suggestion is that local variables are not
visible outside of the function scope. So the function caller has no
way of controlling their lifetime. Hence, it's the responsibility of
the function implementor to think about potential space leaks.

![Eat all local values!](/images/space-leak/space-leak-consume.jpg)

### Use strict containers

::: {.thought}

Use `Map` type and functions from the `Data.Map.Strict` module and
`HashMap` from `Data.HashMap.Strict`

:::

The [containers](@hackage) library implements the dictionary data
structure called `Map`. The library provides two versions of this data
structure: _lazy_ and _strict_. The data type is the same for both
versions but the function implementation details are different.

The only difference is that values in the strict map are evaluated
strictly. That's all.

If you use strict `Map` instead of lazy, the following code doesn't
contain space leak:

```haskell
aggregateApi :: UserId -> App (Map UserId (Set ResponseId))
aggregateApi userId = do
    response1 <- queryApi1 userId
    response2 <- queryApi2 userId
    response3 <- queryApi3 userId
    ...
    pure $ Map.singleton userId $ Set.fromList $ response1 <> response2 <> response3
```

> 🧩 **Exercise**: could you replace a single `$` with `$!` in the
> above code to eliminate space leak without using the strict `Map`?

`Map` and `HashMap` are quite common data structures. And you don't
want to have a `Map` around that still retains a pointer to some
unevaluated expression. We don't need zombie data 💀

> 👩‍🔬 You may still benefit from lazy data structures when they are used with awareness. For example, lazy arrays enable the [Lazy Dynamic Programming][lazy-dynamic] approach.

[lazy-dynamic]: https://jelv.is/blog/Lazy-Dynamic-Programming/

### Use strict text types

::: {.thought}

Use strict `Text` or `ShortByteString` or strict `ByteString`.

:::

It's really cool that you can consume a multi-gigabyte file in
constant memory using only the Haskell standard library: lazy IO and
`String`. But most of the time you don't need this. And even if you
need, there're more efficient ways to solve this problem.

In all other cases `String` performs much worse and increases the
likelihood of introducing a space leak. Are you still using Haskell's
`String` in 2022???

> 👩‍🔬 Since [the `text-2.0` release][text-20], the `Text` type is now
> UTF-8 encoded instead of the previous UTF-16 encoding.

> 👩‍🔬 Since the [latest release of the `filepath` library][filepath],
> you can even switch `FilePath` (which is `String` in disguise) to a
> better type.

[text-20]: https://discourse.haskell.org/t/text-2-0-with-utf8-is-finally-released/3840
[filepath]: https://hasufell.github.io/posts/2022-06-29-fixing-haskell-filepaths.html

### Don't use the State monad

::: {.thought}

Don't use the `State` monad from the `transformers` and `mtl`
packages.

:::

The [transformers](@hackage) library implements the `State` monad (and
[mtl](@hackage) reexports it) in two versions: lazy and strict. The
data type definitions of both monads are the same (although they are
different types incompatible with each other). And there's a subtle
difference in various instances, e.g. the `Monad` one:

**Strict**

```haskell
instance (Monad m) => Monad (StateT s m) where
    m >>= k  = StateT $ \ s -> do
        (a, s') <- runStateT m s
        runStateT (k a) s'
```

**Lazy**

```haskell
instance (Monad m) => Monad (StateT s m) where
    m >>= k  = StateT $ \ s -> do
        ~(a, s') <- runStateT m s
        runStateT (k a) s'
```

Unless you know the consequences of using the lazy version, I suggest
defaulting to the strict State monad to avoid other places where you
can have space leaks.

Unfortunately, even
[the strict State monad can cause space leaks][state-leaks] so the
general suggestion is to avoid the state monad entirely unless you
know what you're doing.

> 👩‍🔬 Usages of the strict `State` monad still can be safe if your
> state data type is strict and you're careful enough with updating
> state using `put $! newState` or `modify'` and underlying monad in
> `StateT` doesn't do anything funky.

[state-leaks]: https://free.cofree.io/2021/12/13/space-leak/

![Impossible choice](/images/space-leak/space-leak-state.jpeg)

### Don't use the Writer monad

::: {.thought}

Don't use the `Writer` monad from the `transformers` and `mtl`
packages.

:::

Seriously. Just don't. You thought having lazy and strict versions of
the `State` monad that both leak memory is a problem? Well, `Writer`
has three (!!!) versions. And
[at least two of them contain space leaks][writer-leaks].

[writer-leaks]: https://journal.infinitenegativeutility.com/writer-monads-and-space-leaks

Moreover, the `Writer` monad is often misused for storing logs in
memory. It's an extremely terrible practice to store logs in memory
instead of outputting them immediately somewhere.

So, unless you definitely know what you're doing, a simple suggestion
would be to avoid the `Writer` monad entirely.

![Don't use the Writer monad](/images/space-leak/space-leak-writer.jpeg)

### Use atomicModifyIORef'

::: {.thought}

Use `atomicModifyIORef'` from `base` when modifying `IORef`

:::

When dealing with mutable values inside `IORef`, you want to mutate
them (duh!). Using `writeIORef` or `modifyIORef` functions for this
purpose has at least two problems:

1. They're lazy and don't evaluate the result which leads to a higher
   probability of introducing space leaks.
2. They are not thread-safe. Concurrent usage of these functions may
   corrupt the result.

If your program is not multithreaded, you maybe don't need
`atomicModifyIORef'` (and maybe you don't need `IORef` at all). But
things may change in the future. Are you going to chase any single
usage of potentially incorrect functions? You can start following best
practices immediately!

### Evaluate before putting into mutable references

::: {.thought}

Evaluate values (with `!` or `seq` or `$!`) before putting them into
`IORef` / `STRef` / `MVar` / `TVar`.

:::

`MVar` is another mutable container similar to `IORef`. It's used in
concurrent applications. Unfortunately, the situation with `MVar` is
slightly worse than with `IORef` because its API doesn't even provide
strict functions.

Consider the example:

```haskell
aggregateApi :: MVar (Set ResponseId) -> UserId -> IO ()
aggregateApi resVar userId = do
    response1 <- queryApi1 userId
    response2 <- queryApi2 userId
    response3 <- queryApi3 userId
    ...

    let responses = Set.fromList $ response1 <> response2 <> response3
    putMVar resVar responses
```

Boom 💥 You have a space leak!

You don't evaluate the `responses` value before putting it inside
`MVar`. So it'll remain unevaluated until some other thread tries to
consume the value inside and evaluate it. And may happen way in the
future while your program requires extra unneccessary memory.

The solution to this problem is very simple though. You need to change
a single line by adding `!` in front of the variable to evaluate it
before putting inside `MVar`

```haskell
    ...
    let !responses = ...
    ...
```

The same advice regarding evaluating values before putting them into
the mutable reference container applies to other mutable reference
types as well.

### Pay attention to the usage of standard types

::: {.thought}

Remember, previous methods don't evaluate values deeply and don't
affect already defined lazy types.

:::

So, you've followed all the recommendations from this blog post —
enabled all the extensions, always used `!` where needed, mutated
mutable references appropriately, never used lazy data structures and
avoided all dangerous monads.

And yet, you change a type of a single field or an accumulator from
`Int` to `Maybe Int` and all your efforts are perished in vain. You've
just introduced a new space leak! 💥

![Unexpected Maybe destroys all your efforts](/images/space-leak/space-leak-maybe.jpg)

This happens because evaluation with `!`-patterns doesn't evaluate
values "deeply". Similarly, [StrictData][strict-data] is applied only
to modules where it's enabled but it's not enabled in the standard
library.

You have several options to solve this problem:

* Think if you really need that `Maybe` or tuple wrapper and whether
  you can float it out
* Evaluate values before putting them inside `Maybe`
* Use [lightweight strict wrapper][strict-wrapper] from the
  [strict-wrapper](@hackage) library
* Use strict alternatives of standard types from the
  [strict](@hackage) library

[strict-wrapper]: http://h2.jaguarpaw.co.uk/posts/nested-strict-data/

<hr>

In general, it worth keeping your application simple ([KISS][kiss])
while simultaneously thinking about its memory usage. Lazy evaluation
requires to shift gears of your brain when you think about memory
usage of lazy programs.

[kiss]: https://en.wikipedia.org/wiki/KISS_principle

## Investigating space leaks

One of the problems with space leaks is that it's not really
straightforward to investigate them. There's also not a lot of
literature about investigating and debugging space leaks (and most of
it is outdated). Often, literature doesn't provide enough details and
only briefly mentions how to discover space leaks.

Some relevant information I was able to dig:

* [Diagnose memory leaks on PINNED values with GHC 9.2.1 and up (2022)][leak-pinned]
* [Being lazy without getting bloated (2020)][bloated]
* [Fixing Space Leaks in Ghcide (2020)][leak-ghcide]
* [Debugging space leaks in haskell-ide-engine (2019)][leak-hie]
* [Detecting Space Leaks (2015)][leak-detect]
* [Chasing a Space Leak in Shake (2013)][leak-chase]
* [Anatomy of a thunk leak (2011)][leak-anatomy]
* [Space leak zoo (2011)][leak-zoo]

When lifebuoy doesn't help, the only choice left is to learn how to swim.

[leak-pinned]: https://epicandmonicisnotiso.blogspot.com/2022/07/diagnose-memory-leaks-on-pinned-values.html
[bloated]: https://well-typed.com/blog/2020/09/nothunks/
[leak-ghcide]: https://mpickering.github.io/ide/posts/2020-05-27-ghcide-space-leaks.html
[leak-hie]: https://www.youtube.com/watch?v=PL8Wjdt0cKo&ab_channel=MatthewPickering
[leak-detect]: http://neilmitchell.blogspot.com/2015/09/detecting-space-leaks.html
[leak-chase]: http://neilmitchell.blogspot.com/2013/02/chasing-space-leak-in-shake.html
[leak-anatomy]: http://blog.ezyang.com/2011/05/anatomy-of-a-thunk-leak/
[leak-zoo]: http://blog.ezyang.com/2011/05/space-leak-zoo/

## Conclusion

We've seen that investigating space leaks could be a frustrating
experience. The bigger your application grows, the more challenging it
becomes to find a particular memory offender, especially when
investigation techniques don't work on a project of your size and
complexity.

On the other side, it's pretty easy to follow some simple guidelines
to avoid having space leaks in the first place. The recommendations in
this blog post may not give you 100% guarantee of not ever seeing a
space leak but it's safer to drive with your seat belt fastened.

[bang-patterns]: https://downloads.haskell.org/ghc/latest/docs/html/users_guide/exts/strict.html#bang-patterns-informal
[strict-data]: https://downloads.haskell.org/ghc/latest/docs/html/users_guide/exts/strict.html#strict-by-default-data-types
