---
title: The Power of RecordWildCards
description: Best-practices for the RecordWildCards language extension
tags: haskell, syntax, language, record
shortName: recordwildcards
---

## Intro

> With great power comes great responsibility!

Record data types are vital for developing libraries and applications. However,
there is a popular opinion that records in Haskell are not well-designed. The
Haskell ecosystem has multiple approaches to deal with records pitfalls: a bunch
of language extensions, multiple `lens` libraries, best-practices and naming
conventions. But there is still no consensus on the best way to use records.

[RecordWildCards](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#record-wildcards)
is one of the language extensions that improve the situation with records.
However, it's one of the most controversial extensions at the same time. Some
people suggest avoiding this extension no matter what. Some prefer to use it
everywhere. In this blog post, I'm going to review this extension under any
possible angle and tell when to use and when not to use it.

## What is RecordWildCards?

Let's start with talking about how records are implemented in Haskell. When you
define the following data type:

```haskell
data User = User
    { name :: Text
    , age  :: Int
    }
```

In Haskell it's actually syntax sugar for the following code:

```haskell
data User = User Text Int

name :: User -> Text
name (User n _) = n

age :: User -> Int
age (User _ a) = a
```

> **NOTE:** in addition to generated functions each record also allows you to
> use record update syntax.

As you can see, getter functions are generated with the same names and types as
the corresponding fields. And you can operate with them as ordinary functions
when you write code:

```haskell
canBuyVodka :: User -> Bool
canBuyVodka user = age user >= 18
```

### Deconstruction

The first feature that `RecordWildCards` allows you to do is to pattern-match on
the constructor in a special way by bringing all its fields into scope not as
functions but as values instead. So, using this extension we can rewrite code
above in the following way:

```haskell
canBuyVodka :: User -> Bool
canBuyVodka User{..} = age >= 18
```

In the snippet above `age` would be the value taken taken from `User` and it has
type `Int`. It's hard to see benefits in this small example. However, when you
have a lot of fields and use them multiple times inside a single function, this
extension becomes really handy.

### Construction

The second feature of `RecordWildCards` is the ability to construct values of
the record type from identifiers in scope. Like this:

```haskell
readUser :: IO User
readUser = do
    name <- getLine
    age  <- readLn
    pure User{..}
```

Values `name` and `age` are used as corresponding fields of the `User`
constructor. This helps to avoid code duplication and eliminates the need to
come up with different variable names.

In the following sections, I'm going to highlight common concerns about this
extension and recommend best-practices.

## Implicit scope

One of the reasons why some people don't like `RecordWildCards` is because it's
not clear where the identifiers come from. Consider the following code:

```haskell
nameOnCard :: User -> Job -> Text
nameOnCard User{..} Job{..} = name <> " | " <> title
```

The problem with this code is that it's not obvious from what data types these
fields come from: is `name` a field of `User` or `Job`? Hard to tell without
looking at the definitions of the corresponding types. This makes code hard to
read and maintain.

One of the possible solutions some people recommend is to use
[NamedFieldPuns](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#record-puns)
extension. When this extension enabled, you can write the following code
instead:

```haskell
nameOnCard :: User -> Job -> Text
nameOnCard User{name} Job{title} = name <> " | " <> title
```

`NamedFieldPuns` is similar to `RecordWildCards` but it forces you to specify
explicitly what fields you are using. In this particular case, the extension
solves the problem of figuring out where the variables come from, however, it
has its own drawbacks:

1. When your records have a lot of fields and you use most of them, usage of
   this extension increases the size of your code significantly.
2. It introduces code duplication. You write field names twice: on the
   pattern-matching side and on the call side.

Let's see how all these problems can be solved with `RecordWildCards`. Because
record fields are top-level functions and because there is no function
overloading in Haskell, you can't have two data types with the same field names
in scope (though see the section about
[DuplicateRecordFields](#duplicaterecordfields)). One of the popular solutions
to this difficulty is to prefix field names with the data type name or its
abbreviation if the data type name is too long. Turns out that this approach
also solves the above problem with `RecordWildCards`. This naming convention is
so common that JSON and `lens` libraries provide options to strip prefixes
automatically. If we define our data type like this:

```haskell
data User = User
    { userName :: Text
    , userAge  :: Int
    }
```

Then the function from our example becomes more readable!

```haskell
nameOnCard :: User -> Job -> Text
nameOnCard User{..} Job{..} = userName <> " | " <> jobTitle
```

**Conclusion:** prefix field names with the type name to solve two problems at
the same time.

## Strict construction

If you construct values using `RecordWildCards`, you might forget to specify all
fields like in the code below:

```haskell
defaultUser :: User
defaultUser =
    let userName = "Ivan"
    in User{..}
```

When GHC sees similar code, it outputs warning that not all fields are
initialised. But it's very easy to miss this warning and get a runtime error
later. The answer to this problem is to mark every field of your data type with
the strict annotation:

```haskell
data User = User
    { userName :: !Text
    , userAge  :: !Int
    }
```

> **NOTE:** you can make all your types strict by default by enabling the
> [StrictData](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#strict-by-default-data-types)
> language extension.

If you add `!` in front of each type, then all fields will become strict and you
will see compiler error instead of warning when you forget to initialise some
fields. Adding bangs also considered one of the best-practices to avoid space
leaks. It's very rare when you want lazy fields of records.

> **NOTE:** you can add `{-# OPTIONS_GHC -Werror=missing-fields #-}` to get
> compile time error on unitialised lazy fields.

**Conclusion:** mark field as strict to have more compile time checks and to
avoid potential performance problems.

## Compileless

Another popular concern about `RecordWildCards` is that you lose compile time
checks during pattern-matching when you add more fields. For example, we want to
implement `ToJSON` instance from the [aeson](@hackage) library for our `User`
data type:

```haskell
instance ToJSON User where
    toJSON User{..} = ["name" .= userName, "age" .= userAge]
```

Now, if we add one more field to the `User` type, GHC wouldn't warn us that we
need to update this instance. If we want to see compile time error we need to
write this instance in a different way:

```haskell
instance ToJSON User where
    toJSON (User name age) = ["name" .= name, "age" .= age]
```

But let's look at this problem closer. This is the case where we want to use
_each_ field of the constructor. However, not all functions are like that. In
our `nameOnCard` function from the previous paragraph, we don't want to use all
fields, we're interested only in a subset of them. And we don't want to update
that function when we change definitions of the `User` or `Job` types. However,
in `ToJSON` instance, we want to use _all_ fields. So, the problem is not
actually in `RecordWildCards`. We need to know where to apply this extension,
though even here you can use `RecordWildCards` to make your life easier and here
is why:

1. If you also define `FromJSON` instance, you should implement roundtrip
   property-based tests to make sure that your `FromJSON` and `ToJSON` satisfy
   this property. It's not possible to skip `FromJSON` instance update because
   you will see compile time error if you don't initialise all fields of the
   type. Thus, if you forget to update `ToJSON` instance, you observe test
   failure.
2. If your `FromJSON/ToJSON` instances are trivial, you can use
   [generics](https://hackage.haskell.org/package/base-4.12.0.0/docs/GHC-Generics.html#t:Generic)
   or
   [TemplateHaskell](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#template-haskell)
   to derive these instances automatically.
3. If your `ToJSON` instance is a part of your exposed API then you probably
   should care about not changing it accidentally. And for this, you need to
   provide golden tests.

Forgetting to add field is not the scariest problem actually. A scarier problem
is that you can change the type of some field, your roundtrip tests are still
passing, but consumers of your JSON API will observe errors. So
`RecordWildCards` is not the most dangerous thing you should worry about here.

You _must_ avoid `RecordWildCards` only when you really need compile time
guarantees to use all fields of the type and when tests are not good. For
example, when implementing binary serialisation. If you convert your data type
to a sequence of 0s and 1s then failed test output won't help you much to find
where is the problem.

**Conclusion:** not using `RecordWildCards` doesn't help you to avoid _all_ your
problems, so implement tests to prevent your code from spontaneous breakages.

## ApplicativeDo

We talked about concerns with `RecordWildCards` but let's talk about its
advantages. Turns out that `RecorldWildCards` plays nicely with another language
extension —
[ApplicativeDo](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#applicative-do-notation).

Let's say we want to build CLI for the tool that allows to query some data and
filter it by `from` and `to` entries. Terminal command for this tool may look
like this:

```
my-tool query --from 3 --to 42
```

We can use [optparse-applicative](@hackage) library to implement a parser for
these options easily. Let's start with creating our data type for the options:

```haskell
data Options = Options
    { optionsFrom :: !Int
    , optionsTo   :: !Int
    }
```

`optparse-applicative` is built around `Applicative` functors. So in order to
implement a parser for the `Options` data type you need to write code like this:

```haskell
fromP, toP :: Parser Int
...

optionsP :: Parser Options
optionsP = Options
    <$> fromP
    <*> toP
```

One problem with writing code in this style is that very easy to use the wrong
order of `fromP` and `toP` parsers when defining a parser for `Options` and this
can lead to bugs. In CLI you can write either `--from 3 --to 42` or `--to 42 --from 3`
and both work correctly. But in code `Options <$> fromP <*> toP` is
not the same as `Options <$> toP <*> fromP`. This semantic difference between
real-world and expectations from code can lead to unexpected bugs.

This is true in general for such applicative-style code but it's more important
with regards to CLI. Because it's not that easy to test CLI and to my knowledge,
not many people really write automatic tests for CLI. So in this area of our
code, we want to be more careful not to introduce extra bugs.

One of the solutions to the described problem is to introduce `newtype`s. But it
might be too tedious to deal with lots of `newtype`s. Fortunately, we can use
`RecordWildCards` and `ApplicativeDo` extension to solve this problem easier!

```haskell
optionsP :: Parser Options
optionsP = do
    optionsFrom <- fromP
    optionsTo   <- toP
    pure Options{..}
```

Now, even if you change the order of `optionsFrom` and `optionsT` variables, the
code still works.

**Conclustion:** `RecordWildCards` combined with `ApplicativeDo` allow you to
write type-safe and maintainable code.

## DuplicateRecordFields

Due to the records implementation details, it's not possible to have data types
with the same field names in scope in standard Haskell code (as per
Haskell2010). However, if you enable
[DuplicateRecordFields](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#duplicate-record-fields)
extension, it becomes possible. You can leverage this extension to convert
between data types easily:

```haskell
data Man = Man { name :: !Text }
data Cat = Cat { name :: !Text }

evilMagic :: Man -> Cat
evilMagic Man{..} = Cat{..}
```

However, such automatic conversion works only if fields of different types have
the exact same names. So, if data types have different prefixes, you need to
write mapping between fields explicitly. But if you decide not to add prefixes
for the field names, some pieces of your code that do something else besides
mere conversion between data types, can become less readable if you use
`RecordWildCards` in them.

**Conclusion:** if you convert between data types more often than you use them,
you can leverage the combination of `RecordWildCards` and
`DuplicateRecordFields` extensions.

## Summary

`RecordWildCards` is a very useful and convenient extension. It can be used in
the wrong way. However, if you follow best-practices, this extension can become
your best friend in writing elegant and maintainable code.
