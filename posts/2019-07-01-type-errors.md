---
title: "A story told by Type Errors"
description: Tutorial on custom type errors in Haskell with a lot of examples
tags: haskell, type-level, type-errors
shortName: "type-errors"
---

Custom type errors is an extremely powerful tool for improving the UX of Haskell
libraries. However, they are not used frequently enough. Partially because this
technique requires the usage of some advanced Haskell concepts like type
families, data kinds and kind polymorphism. And partially because not everyone
is aware of such a valuable piece of standard Haskell library.

In this blog post I'm going to show that using custom type errors is a simple
task. I will present a lot of very different usage examples and teach you how to
flavour your Haskell code with useful compile-time error messages.

* [Complete version of the code from this blog](https://gist.github.com/chshersh/d9413b52aafd2057f1d8c87880aa3df7)

## Motivation

I can not express how important it is to have lucid error messages. An ideal
error message should not only point out an incorrect piece of code but also
suggest how to fix it. Unfortunately, not all standard error messages are that
helpful. Moreover, GHC cannot know in advance about all possible usages for
various functions. That's why error messages are not attached to particular use
cases. Often they are vague due to the fact how the type system in GHC is
implemented and this makes errors hard to understand sometimes. However, most of
the common types and functions became standard idioms in day-to-day Haskell
programming. So why not give Haskell users a helping hand and guide them how to
use the language efficiently by exploiting the power of the type system itself?

## What is TypeError?

Custom type errors mechanism allows Haskell developers to introduce their own
compile-time error messages about usages of their functions without a need to
fork GHC and patch it for the particular use cases. It provides a user-level way
for extending the capabilities of the compiler. Custom user error messages can
use the information only about types. With such type errors, you can't introduce
new parse errors about Haskell syntax (for that you actually need to fork GHC
and patch it). But using type errors you can guide users of your library in the
right direction of using your functions and types.

To use custom type errors you need to perform two steps:

1. Construct an error message itself using the `ErrorMessage` data type.
2. Put the `TypeError` type family application result to your error message
   inside the constraint context for your functions or instances.

The following sections explain what is a type family, how `TypeError` and
`ErrorMessage` look like and how to use them.

> For a deeper understanding of type-level computations in Haskell I recommend
> reading [Thinking with Types](https://leanpub.com/thinking-with-types) by
> Sandy Maguire.

### Short intro to type families

In simple words, [type family](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#type-families)
is a type-level function from types to types. Below you can see the example of
some simple type family that for a given type of unsigned numeric values returns
signed type that contains every unsigned value of the corresponding type:

```haskell
type family Signed (t :: Type) :: Type where
    Signed Word8   = Int16
    Signed Natural = Integer
```

Defining a type family is as simple as defining an ordinary function. The only
difference is that type families take types as arguments and return types as
their result. You can use `:k` or `:kind` command in GHCi to see the type of any
type family. And you can use `:kind!` to apply type family and evaluate it to
see the result:

```haskell
ghci> :kind Signed
Signed :: * -> *

ghci> :kind! Signed Natural
Signed Natural :: *
= Integer

ghci> :kind! Signed Int
Signed Int :: *
= Signed Int
```

> **NOTE:** GHC is moving towards renaming `*` to `Type` and you already can use
> [Type](https://hackage.haskell.org/package/base-4.12.0.0/docs/Data-Kind.html#t:Type)
> in your code to specify kinds. But GHCi still displays the `Type` kind as `*`.

Our `Signed` type family is not defined for the `Int` type that's why we see in
GHCi that the result of `Signed Int` is not evaluated. Above we've implemented
so-called _closed type family_ — it is defined only for those types that we
specified under `where` clause. Just like familiar term-level functions. There
also exist _open type families_ that can be extended externally. But we are
going to talk only about _closed type families_ in this blog post.

The `Signed` type family can be useful to define a safe interface like this one:

```haskell
class ToSigned a where
    toSigned :: a -> Signed a
```

In the `ToSigned` typeclass the result type depends on the argument type and it
is possible to have instances of this typeclasses only for types handled by the
`Signed` type family.

### TypeError type family

Let's look at the implementation details of the
[TypeError](https://hackage.haskell.org/package/base-4.12.0.0/docs/GHC-TypeLits.html#t:TypeError)
type family first. Below I provide its full definition from `base`:

```haskell
type family TypeError (a :: ErrorMessage) :: b where
```

`TypeError` is a type family that takes a type of `ErrorMessage` kind and
returns a type of a [polymorphic kind](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#kind-polymorphism)
(not just `Type` as in the example from the previous section). The fact that
`TypeError` has polymorphic kind of the result means that the result can be used
in many places, like constraint context or return value of any function (though
usually it's used inside constraints).

You can notice that the `TypeError` type family doesn't have a body at the
language-level. There is nothing after the `where` keyword. And it is also a
_closed type family_ which means that you can't extend it externally. The
implementation of `TypeError` is baked into GHC internals.

### Short intro to DataKinds

In Haskell, every type can be typed. The type of type is called _kind_. You can
inspect the value type in GHCi using `:t` command. Similarly, you can inspect
the kind of type using `:k` command.

```haskell
ghci> :t True
True :: Bool

ghci> :t Bool
    error: Data constructor not in scope: Bool

ghci> :k Bool
Bool :: *

ghci> :k True
    Not in scope: type constructor or class ‘True’
    A data constructor of that name is in scope; did you mean DataKinds?
```

You can see that you can't inspect a type of type and you can't inspect a kind
of value. However, the last error message is intriguing. What does it mean and
what is `DataKinds`?

Turns out that GHC provides an ability to [promote value-level data constructors](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#datatype-promotion)
to type-level. To be able to use promoted data constructors you need to enable
the `DataKinds` language extension and add a single quote in front of the
constructor:

```haskell
ghci> :set -XDataKinds
ghci> :k 'True
'True :: Bool
```

`True` is a value that has type `Bool` and `Bool` has kind `Type`. But `'True`
is a type that has kind `Bool`. So we promoted constructors to types and types
to kinds. You may ask if `'True` is a type then what values it has? The answer
is that it doesn't have any values, this type is uninhabited. Not every type has
values. Though, such promoted types still can be useful for type-level
computations.

### ErrorMessage data type

Now, let's have a look at the
[ErrorMessage](https://hackage.haskell.org/package/base-4.12.0.0/docs/GHC-TypeLits.html#t:ErrorMessage)
data type which is used as an argument in the `TypeError` type family:

```haskell
data ErrorMessage
    = Text Symbol
    | forall t. ShowType t
    | ErrorMessage :<>: ErrorMessage
    | ErrorMessage :$$: ErrorMessage
```

This data type looks attractive. What we can notice first is that it has several
constructors that are defined as operators (`:<>:` and `:$$:`). Second, this
data type is intended to be used on the type-level, not value-level. That's why
the `Text` constructor stores a type-level string of kind `Symbol`, not just
`String`.
[Symbol](https://hackage.haskell.org/package/base-4.12.0.0/docs/GHC-TypeLits.html#t:Symbol)
is a kind of type-level strings in Haskell:

```haskell
ghci> :t "Ordinary string"
"Ordinary string" :: String

ghci> :k "Type-level string"
"Type-level string" :: Symbol
```

The `ErrorMessage` constructors have the following meaning:

1. `Text` specifies a hardcoded text.
2. `ShowType` displays any given type.
3. `:<>:` concatenates two messages inside a single line.
4. `:$$:` puts a line break between two messages.

Let's try to build our first error message!

```haskell
type FooMessage =
    'Text "First line of the foo message" ':$$:
    'Text "Second line of the foo message: " ':<>: 'ShowType ErrorMessage
```

Note how we prepend every constructor (even operators) with a single quote. This
is because we are using `DataKinds` to create type-level values from promoted
constructors. You can check that `FooMessage` is indeed a type-level value that
has `ErrorMessage` kind:

```haskell
ghci> :k FooMessage
FooMessage :: ErrorMessage
```

After creating an error message we can finally use it!

```haskell
foo :: TypeError FooMessage
foo = error "unreachable"
```

Now, if you will try to compile the module which has this `foo` function, you
will see the following error message:

```
TypeErrors.hs:19:8: error:
    • First line of the foo message
      Second line of the foo message: ErrorMessage
    • In the type signature: foo :: TypeError FooMessage

19 | foo :: TypeError FooMessage
   |        ^^^^^^^^^^^^^^^^^^^^
```

This use case is not particularly useful but it should demonstrate how to
construct and use custom type errors. In the following sections I'm going to
explain how to implement a lot of cool and useful stuff with type errors.

> You can construct error messages using combinators from the
> [type-errors](@hackage) library.

## Motivating example: adding two lists

One of the most common Haskell typeclasses is the `Num` typeclass. It contains a
lot of arithmetic operations, including number addition:

```haskell
ghci> :t (+)
(+) :: Num a => a -> a -> a
```

This operator is used to add two numbers. But what will happen if we try to add
two lists with this operator?

```haskell
ghci> [1,2] + [3,4]

<interactive>:4:1: error:
    • Non type-variable argument in the constraint: Num [a]
      (Use FlexibleContexts to permit this)
    • When checking the inferred type
        it :: forall a. (Num a, Num [a]) => [a]
```

As you can see, we can't add two lists. It is a compile-time error. And this is
a good thing: no implicit casts, no undefined and unexpected behaviour. But the
unfavourable part of it is the error message itself. I can imagine how horrified
and frustrated Haskell beginners could be after looking at this error message
because from the beginner's point of view the text of the message doesn't make
any sense at all! Sure, it is understandable if you are using Haskell long
enough and you learned how to decode error messages. But not at the start of
your Haskell adventure...

Imagine if the error message could look like this instead:

```
ghci> [1,2] + [3,4]

    • You've tried to perform an arithmetic operation on lists.
      Possibly one of those: (+), (-), (*), fromInteger, negate, abs

      If you tried to add two lists like this:

          ghci> [5, 10] + [1, 2, 3]

      Then this is probably a typo and you wanted to append two lists.
      Use (++) operator to append two lists.

          ghci> [5, 10] ++ [1, 2, 3]
          [5, 10, 1, 2, 3]

      If you want to combine a list of numbers with an arithmetic operation,
      you can either use 'zipWith' for index-wise application:

          ghci> zipWith (*) [5, 10] [1, 2, 3]
          [5, 20]

      or 'liftA2' for pairwise application:

          ghci> liftA2 (*) [5, 10] [1, 2, 3]
          [5, 10, 15, 10, 20, 30]

      If you want to apply unary function to each element of the list, use 'map':

          ghci> map negate [2, -1, 0, -5]
          [-2, 1, 0, 5]


    • In the expression: [1, 2] + [3, 4]
      In an equation for ‘it’: it = [1, 2] + [3, 4]
```

Much better! Now it is more clear what went wrong and how to fix the error. Good
news is that it is actually possible to provide such a neat error message. You
just need to do the following:

```haskell
type ListNumMessage
    = ... the above text constructed using earlier explained syntax ...

instance TypeError ListNumMessage => Num [a]
```

> **NOTE:** If you compile your code with
> [-Wredundant-constraints](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/using-warnings.html#ghc-flag--Wredundant-constraints)
> flag you see a lot of warnings about unused constraints in your code when
> using custom type errors. This is an unfortunate drawback but it's not that
> bad.

We've implemented the `Num` instance for the list. So every time this instance
is used, GHC will kindly tell why we can't use it and how to fix the error. If,
instead, there is no instance for some data type then all you see is the error
message saying "There is no such instance". However, if you know that there is
no reasonable instance of this typeclass and it can be used in the wrong context
and confuse users of your library then you can forbid this instance and provide
helpful error message explaining your motivation and guiding users in the right
direction when this instance is used.

I think that UX of Haskell beginners can be improved a lot if such instances
were added not only for lists but also for `Bool`, `Char`, `String`, tuples,
`IO` and many more data types. It will take time to write all the messages. But
you only need to do this once and from now on till the end of times all
developers would benefit from these instances.

A similar approach is heavily used by the [silica](@hackage) library which implements
lenses but has a lot of nice custom error messages that help developers to
understand the concept of lenses better.

## Create the restricted instance: Eq instance for the function

In the previous example, we've forbidden the instance completely. But sometimes
we want to forbid it partially (wat?). I'll explain what I mean.

Let's say that we want to check whether two functions are equal (this might be
useful for property-based testing or during refactoring). It is a difficult
question: what does the function equality mean in programming?
In [math we have a formal definition](https://math.stackexchange.com/questions/1070895/equality-of-functions).
This means that in Haskell we can apply this definition in the context of pure
computations. We can say that two functions are equal if they produce the same
output for all possible values of their arguments. This property can be encoded
via the following instance:

```haskell
instance (Bounded a, Enum a, Eq b) => Eq (a -> b) where
    (==) :: (a -> b) -> (a -> b) -> Bool
    f == g = let universe = [minBound .. maxBound]
             in map f universe == map g universe
```

And we can verify that the instance works:

```haskell
boolId1, boolId2, boolId3 :: Bool -> Bool
boolId1 = id
boolId2 = not . not
boolId3 = not

ghci> boolId1 == boolId2
True
ghci> boolId1 == boolId3
False
```

However, this instance is dangerous because we can accidentally compare two
functions that have an argument of type `Int` (or some other type with a lot of
values) and checking that two functions produce the same result for every `Int`
might take half of the Universe lifetime. So, what we eventually want is to
allow function equality but only when function argument is a "small" data type.
Fortunately, this can be achieved by the combination of type families and custom
error types. The idea is to implement a type family that pattern-matches on a
type and returns type error constraint only for non-small types. Otherwise, it
should return empty constraint. See the code snippet below for the
implementation:

```haskell
type FunEqMessage (arg :: Type) (res :: Type) = ... message ...

type family CheckFunArg (arg :: Type) (res :: Type) :: Constraint where
    CheckFunArg Bool  _ = ()
    CheckFunArg Int8  _ = ()
    CheckFunArg Word8 _ = ()
    CheckFunArg arg   r = TypeError (FunEqMessage arg r)

instance (CheckFunArg a b, Bounded a, Enum a, Eq b) => Eq (a -> b) where
   ... implementation stays the same ...
```

And now we can safely use it!

```haskell
inc1, inc2 :: Int -> Int
inc1 = (+1)
inc2 = succ
```

```
ghci> inc1 == inc2

    • You've attempted to compare two functions of the type:

          Int -> Int

      To compare functions their argument should be one of the following types:

          Bool, Int8, Word8

      However, the functions have the following argument type:

          Int

    • In the expression: inc1 == inc2
      In an equation for ‘it’: it = inc1 == inc2
```

> **NOTE:** With this instance it is still possible to hang function
> comparison if you will try to compare two functions of type like:
>
> ```haskell
> Int8 -> Int8 -> Int8 -> Int8 -> Bool
> ```
>
> But this is just an implementation detail how to patch this instance to take
> such cases into consideration.

## Restrict instance externally: Foldable

This use case is similar to the previous one, but now we want to restrict some
functions from the already implemented instance. Some instances are written in
the external libraries. It is not possible in Haskell to not import some
instances. But sometimes you really want to not have all of them. Or,
alternatively, the instance itself is useful except a couple of dangerous
functions.

**Example:** there exist well-known efficient container types `Set` and
`HashSet` from the [containers](@hackage) and [unordered-containers](@hackage)
packages correspondingly. These data structures provide fast modification and
query operation. Like these two:

```haskell
member :: Ord a              => a ->     Set a -> Bool
member :: (Eq a, Hashable a) => a -> HashSet a -> Bool
```

However, default Prelude exports the following method of the `Foldable`
typeclass:

```haskell
elem :: (Foldable f, Eq a) => a -> f a -> Bool
```

The problem here is that `elem` for both `Set` and `HashSet` works in `O(n)`
time while `member` works in `O(log n)` time and it's quite easy to accidentally
use slow `elem` instead of fast `member` function.

> **NOTE:** It is worth mentioning that it is actually possible to patch the
> `Foldable` typeclass itself so it can have an efficient implementation of the
> `member` method for both `Set` and `HashSet`. The change was proposed earlier
> but haven't been accepted.

Fortunately, it's still possible to have useful `Foldable` instances for `Set`
and `HashSet` but produce a compile-time error message when you are using `elem`
or `notElem` from `Foldable`. This trick is implemented in the
[relude](@github(kowainik)) alternative prelude. See the full
code in the repository:

* [Implementation](https://github.com/kowainik/relude/blob/559ed98a1d3e2c15f2ec36a1c94e3b9b4e9484a1/src/Relude/Foldable/Fold.hs#L137-L138)

> **NOTE:** Code in `relude` also contains tests for custom error messages using
> [doctest](@hackage). With such an approach, you can automatically check your
> compile-time messages at runtime.

The idea behind the implementation is to reexport our own version of the `elem`
function which just delegates the implementation to `elem` from `Data.Foldable`
but it has an additional constraint over the argument that pattern-matches on
the type and produces either error message or empty constraint. As you can see,
this technique can be extended even further. If you want to forbid instance
completely, you just need to forbid every method of the typeclass for the
particular data type.

Below you can see a general template for solving described problems:

```haskell
module BetterFoo (fooBar) where

import qualified Foo

fooBar :: (DisallowFooBar a, Foo.Foo a) => a -> Bar
fooBar = Foo.fooBar

type family DisallowFooBar (a :: Type) :: Constraint where
    DisallowFooBar Baz = TypeError ... error message …
    DisallowFooBar a   = ()
```

> **NOTE:** In the first example with the list we provided fat text for the
> whole instance because we don't know which function was used. But now you can
> see how we can be aware of the fact which function is used and provide more
> specific error messages.

## Deprecation: better migration guide

According to [PvP](https://pvp.haskell.org/) it's okay to remove a function from
a library while you are increasing major version. However, from the users of the
library point of view function removal may hurt when they try to upgrade to a
newer version of your library. If the function you are using is removed from the
library, the only error you get is that there is no such function. And now you
need to find CHANGELOG for the library to see what to use instead and if the
library author doesn't provide migration guide, you need to read comments and
reasoning under the corresponding issues (again, only if there was an issue at
first place). This is a poor UX.

GHC gives developers an ability to mark their functions with the
[DEPRECATED](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#warning-and-deprecated-pragmas)
pragma and provide a custom message. When a deprecated function is used you will
see a warning with the specified text. Unfortunately, it's very easy to miss a
warning message. And, again, once the function is removed, you will see only the
message that there is no such function. However, with custom type errors we can
make deprecation cycles smoother. Instead of removing the function, you can add
custom type error to the function saying that this function is deprecated. So
every time the function is used, users will see compiler error telling what to
do instead. It is still a compiler error like it would be if you removed the
function, but now at least users know how to fix it with less hassle.

It's extremely easy to introduce such deprecation message. This can be done via
the following code:

```haskell
class CompilerError (msg :: ErrorMessage)
instance TypeError msg => CompilerError msg

type ParseDeprecated = ... message goes here ...

parse :: CompilerError ParseDeprecated => FilePath -> IO ()
parse = error "unreachable"
```

Here is what we do:

1. We create the `CompilerError` typeclass. Usually, you create typeclasses for
   types of kind `Type` or `Type -> Type`. In this case, we create typeclass for
   things of the `ErrorMessage` kind.
2. Then we create a single instance of `CompilerError` for every `ErrorMessage`
   with the `TypeError` constraint for that message. One instance to rule all
   error messages.
3. You can see how to use this typeclass from the `parse` function type
   signature: just add it to the constraint with the specified error message.
   Now every time the `parse` function is used, you will get an error message
   like this one:

```
ghci> parse "path/to/config"

    • Function 'parse' was deprecated in my-parser-1.2.6.0.
      It will be deleted in my-parser-1.3.0.0.
      Use 'parseConfig' instead.

      See the following issue for motivation:

          * https://github.com/user/my-parser/issue/42

    • In the expression: parse "path/to/config"
      In an equation for ‘it’: it = parse "path/to/config"
```

Why write migration guide in some separate document if you can force the
compiler to show this guide to every user of your library? I'm just joking.
Please, write migration guides anyways, a separate document is still super
useful!

## Analyse Generic representation of a type: names, fields, constructors

Final usage of custom type errors is more advanced than the previous ones. The
approach uses
[Generic](https://hackage.haskell.org/package/base-4.12.0.0/docs/GHC-Generics.html)
capabilities to analyse the structure of the data types during compilation.
Generics allow haskellers to derive automatically instances of arbitrary data
types. However, it's not always possible to derive instances. Sometimes you want
to check whether a structure of a data type satisfies specific requirements. For
example, if you don't support automatic deriving for sum types, it is better to
tell about this fact during compilation, not from docs or runtime. But with
`Generic` you can do much more advanced checks! See
[elm-street](https://github.com/Holmusk/elm-street/blob/69a574055c281e781da65f31b6feba075a4f9728/src/Elm/Generic.hs#L79-L89)
for examples of different compile-time verification.

A possible list of compile-time analytics includes:

1. A data type contains only a single constructor.
2. A data type has a low number of fields.
3. Every constructor has the same fields with the same name.
4. A data type has a field of a particular type.
5. Every field of a data type is a newtype.
6. A data type is an enumeration.

And much more. The choices are limited only by your imagination!

This approach is heavily used by the [generic-lens](@hackage) library to check
the structure of data type before allowing to use lenses.

## Conclusion

You can see that custom type errors is a really powerful mechanism. It can
increase the quality of type errors by a lot. But they require some effort from
the developers. And sometimes they require some advanced Haskell knowledge and
understanding of more challenging topics. But in the end, it pays off a lot.

## Acknowledgements

I want to thank [Veronika Romashkina](https://vrom911.github.io/) for her
support and help with the blog post. I spent a lot of time and effort compiling
and explaining all the examples and I couldn't do this without her help.
