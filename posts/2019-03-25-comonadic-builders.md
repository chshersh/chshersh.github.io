---
title: Comonadic builders
description: Builder pattern in Haskell using Comonads
tags: haskell, comonad
---

When I was teaching advanced Haskell course to students, I've created lab
assignments on several compelling topics. One of the homework tasks on the
comonad section is particularly interesting, and today I would like to share the
problem itself with the solution and explanation. Turns out, you actually can
use comonads to solve production problems from the real world.

## Problem statement

The problem in its essence is simple — we want to implement the
[Builder programming pattern][builder]. In simple words, the builder is used when you
want to separate value creation from configuring the creation process. In our
case, we can represent config as a separate data type, construct config first
and only then create a value using the configuration.

> **NOTE:** It is a known fact that comonads can help with representing some OOP
> patterns. Check out this blog post: [OOP Comonads][oop-comonads].

To make our problem entertaining, we want some of the configuration options to
depend on the values of other options. I can give you a real example. In Haskell
scaffolding tool [Summoner][summoner] we have a huge `Settings` data type that
controls how the generated project looks like. This data type contains a lot of
fields but there are dependencies between some of them. For example, you can
specify flags whether you want [GitHub](http://github.com/) or
[Travis](https://travis-ci.org/) integration enabled. However, if you disable
GitHub integration, you shouldn't be able to specify Travis integration because
it doesn't make sense to have it locally.

Of course, you can let users specify whatever they want and figure out fields
dependencies later during value creation in one single place. However, there are
reasons why this might not be desired:

1. If you have a lot of fields and a lot of dependencies, the code for tracking
   all these dependencies becomes messy really quickly.
2. It is a real pain to test such code.
3. It is difficult to refactor such code when you introduce a new field or
   dependency.

So the question: can we do it better? The answer is yes and turns out that
comonads provide a convenient and composable interface for this problem.

> **NOTE:** The proposed solution has restrictions. It works only in a special
> case when dependencies have depth 1. In other words, your configuration
> contains two sets of options — A and B — and only options from set B depend on
> options from set A. Sure, it is possible to implement general solution with
> arbitrary non-cyclic dependencies (and maybe not with comonads) where you can
> disable and enable options, and all dependencies are resolved automatically.
> But I want to demonstrate how comonads can be used here and, who knows, maybe
> later this solution can be generalised!

## Short intro to comonads

Before showing how comonads can be applied to solve the problem, I want to talk
about the comonad concept itself. This is not a tutorial on comonads but I will
try to give better intuition behind this typeclass.

### What is Comonad?

`Comonad` is implemented as the following typeclass available in the
[comonad][comonad] package:

```haskell
class Functor w => Comonad w where
    extract   :: w a -> a
    duplicate :: w a -> w (w a)
    extend    :: (w a -> b) -> w a -> w b
```

If you're familiar with monads in Haskell, you may notice some similarities:

```haskell
class Applicative m => Monad m where
    return :: a -> m a
    join   :: m (m a) -> m a
    bind   :: (a -> m b) -> m a -> m b
```

Basically the same thing, just with some arrows reversed. If `a` is a type of
value, you can think of `w` and `m` as types of a context for that value. But
there are some differences:

1. `return` vs. `extract`
    * `return` knows how to attach context `m` to a value.
    * `extract` always knows how to get value from the context `w`. In particular,
      this means that instances of the `Comonad` typeclass could be only for
      non-empty structures.
2. `join` vs. `duplicate`
    * `join` knows how to collapse contexts. This means, for example, that in most
      cases it doesn't make sense to design interfaces around types like
      `Maybe (Maybe a)`, you can always get rid of nested contexts.
    * `duplicate` can add one more layer of context if a value already has a
      context.
3. `bind` vs. `extend`
    * `bind` can change the resulting context `m` depending on a value inside the
      existing context. However, the function passed to `bind` is not allowed to
      analyze the current context, it can make decisions based on the value.
    * `extend` takes a function that is allowed to analyze context `w` to produce
      a value of type `b`. However, the context itself remains unchanged.

`Monad` doesn't provide a generic way to get rid of a monadic context. Once you
have entered a monad — you always will be in the monad. You need to know
specifics of your monad if you want to eliminate context from the value.
However, monads provide a way to collapse multiple contexts into a single one
using the `join` function.

With `Comonad` you always can extract the value from the comonadic context. But
you need to know the internal structure of your data type to attach context in
the first place. However, if you already have a context, you can add as many
layers as you want using the `duplicate` function.

Before diving into more complicated stuff, let's first look at the
straightforward `Comonad` instance for a very innocent data type:

```haskell
newtype Identity a = Identity { runIdentity :: a }

class Comonad Identity where
    extract :: Identity a -> a
    extract = runIdentity

    duplicate :: Identity a -> Identity (Identity a)
    duplicate = Identity

    extend :: (Identity a -> b) -> Identity a -> Identity b
    extend f = Identity . f
```

And who said that comonads are scary? :)

### Arrow comonad

In order to implement the Builder pattern, we are going to use the `Comonad`
instance for the function arrow `(->)`. The `comonad` package has the
[Traced][Traced] `newtype` wrapper around the function `(->)`. The `Comonad`
instance for this `newtype` gives us the desired behaviour.

```haskell
newtype Traced m a = Traced { runTraced :: m -> a }

instance Monoid m => Comonad (Traced m)
```

However, dealing with the `newtype` wrapping and unwrapping makes our code noisy
and truly harder to understand, so let's use the `Comonad` instance for the
arrow `(->)` itself:

```haskell
instance Monoid m => Comonad ((->) m) where
    extract :: (m -> a) -> a
    extract f = f mempty

    duplicate :: (m -> a) -> (m -> m -> a)
    duplicate f = \m1 m2 -> f (m1 <> m2)
```

> **NOTE:** there is no explicit implementation of the `extend` function since
> it has a default implementation via `duplicate`.
> ```haskell
> extend :: (w a -> b) -> w a -> w b
> extend f = fmap f . duplicate
> ```
> We are going to this definition later.

I mentioned earlier that only non-empty structures can have a `Comonad`
instance. In general case you can't extract the value of type `a` using the
function of type `m -> a` without having `m`. However, if you know that the `m`
is a `Monoid` then you always have `mempty` to pass to a function. `duplicate`
is a no-brainer as well. If you have a function that takes a single value of
type `m` and you need to make it work with two values of that type and you also
know that `m` is a `Monoid` then it is easy — just squash those two values with
`mappend` and pass to your function.

> **NOTE:** This instance is also useful for logging! See
> [co-log](https://kowainik.github.io/posts/2018-09-25-co-log#comonads) for an
> example.

We are going to use the `(->)` instance above as a fundamental piece of our
interface in the following section.

## Builder pattern using Comonad

Finally, let's solve the original problem! In Builder pattern we have several
pieces:

1. A data type for the configuration.
2. A data type for the value created from the configuration.
3. A function that creates value from the configuration.
4. A way to compose builders.

In our approach the `Builder` itself is a function that takes configuration and
produces a value:

```haskell
type Builder = Config -> Value
```

And `Builder` is a comonad! However, it requires from `Config` to have the
`Monoid` instance in order to make the whole thing work.

### Monoidal settings

Let's use a simpler version of the `Settings` data type from
[Summoner][summoner] in our example as the configuration. This data type has the
following fields:

1. Flag that tells whether the project has a library or not (disabled by default).
2. Flag to enable GitHub integration (disabled by default).
3. Flag to enable Travis integration (disabled by default).

In Haskell this can be represented as follows:

```haskell
data Settings = Settings
    { settingsHasLibrary :: !Any
    , settingsGitHub     :: !Any
    , settingsTravis     :: !Any
    } deriving (Show)
```

Here I'm using `Any` from the `Data.Semigroup` module. Since we need to have
`Monoid` instance for `Settings`, let's implement it:

```haskell
instance Semigroup Settings where
    Settings a1 b1 c1 <> Settings a2 b2 c2 =
        Settings (a1 <> a2) (b1 <> b2) (c1 <> c2)

instance Monoid Settings where
    mempty = Settings mempty mempty mempty
```

### Trivial project builder

We are going to create `Project` from `Settings` and here is how our `Project`
data type looks like:

```haskell
data Project = Project
    { projectName       :: !Text
    , projectHasLibrary :: !Bool
    , projectGitHub     :: !Bool
    , projectTravis     :: !Bool
    }
```

Finally, our Builder has the following type:

```haskell
type ProjectBuilder = Settings -> Project
```

Trivial project builder just creates `Project` from `Settings` as it is:

```haskell
buildProject :: Text -> ProjectBuilder
buildProject projectName Settings{..} = Project
    { projectHasLibrary = getAny settingsHasLibrary
    , projectGitHub     = getAny settingsGitHub
    , projectTravis     = getAny settingsTravis
    , ..
    }
```

And you already can play with comonads:

```haskell
ghci> extract $ buildProject "empty"
Project
    { projectName = "empty"
    , projectHasLibrary = False
    , projectGitHub = False
    , projectTravis = False
    }
```

### Simple project builder

Now, what we would like to have, is a way to compose different builders. The
idea here is to build the smallest and simplest project builders manually and
create more complicated ones by composing the smaller ones. For this we are
going to use the following operator from the `comonad` package:

```haskell
(=>>) :: Comonad w => w a -> (w a -> b) -> w b
(=>>) = flip extend
```

When specialized to `ProjectBuilder`, it has the following type:

```haskell
(=>>) :: ProjectBuilder -> (ProjectBuilder -> Project) -> ProjectBuilder
```

In order to see what it does, we can apply [equational reasoning][er]:

```haskell
builder =>> f :: Settings -> Project
    -- (1) definition of (=>>)
    = flip extend builder f

    -- (2) applying `flip`
    = extend f builder

    -- (3) default definition of `extend`
    = (fmap f . duplicate) builder

    -- (4) applying (.)
    = fmap f (duplicate builder)

    -- (5) Using `duplicate` definition from Comonad instance for arrow
    = fmap f (\m1 m2 -> builder (m1 <> m2))

    -- (6) Using `fmap` definition from Functor instance for arrow
    = f . (\m1 m2 -> builder (m1 <> m2))

    -- (7) eta-expanding outer lambda
    = \settings -> (f . (\m1 m2 -> builder (m1 <> m2)) settings

    -- (8) applying (.)
    = \settings -> f $ (\m1 m2 -> builder (m1 <> m2)) settings

    -- (9) partially applying inner lambda
    = \settings -> f $ \m2 -> builder (settings <> m2)
```

But in order to understand, what `(=>>)` operator actually does, we need to
think over its implementation for some time. What we achieved in the step (9) is
the final form of the `(=>>)` operator and also the definition of the `extend`
function from the `Comonad` typeclass for arrow `(->)`. Let's first look at one
example of the function `f` (can be passed as an argument to `(=>>)`).

```haskell
hasLibraryB :: ProjectBuilder -> Project
hasLibraryB builder = builder $ mempty { settingsHasLibrary = Any True }
```

`hasLibrary` builder needs to produce `Project`. This function takes an argument
of type `builder :: Settings -> Project` so the only way to return `Project` is
to pass some `Settings` to `builder`. Here we pass `Settings` that just enable
`hasLibrary` flag. But in general case, you can specify the context of arbitrary
complexity for such functions so they can use smarter and more sophisticated
logic.

By analogy we can create the builder for the GitHub flag:

```haskell
gitHubB :: ProjectBuilder -> Project
gitHubB builder = builder $ mempty { settingsGitHub = Any True }
```

And you can see how it works:

```haskell
ghci> extract $ buildProject "library" =>> hasLibraryB
Project
    { projectName = "library"
    , projectHasLibrary = True
    , projectGitHub = False
    , projectTravis = False
    }

ghci> extract $ buildProject "lib-git" =>> hasLibraryB =>> gitHubB
Project
    { projectName = "lib-git"
    , projectHasLibrary = True
    , projectGitHub = True
    , projectTravis = False
    }
```

If you apply the equational reasoning technique here as well, you can see how
all pieces combine together:

```haskell
buildProject "foo" =>> hasLibraryB :: Settings -> Project
    = \settings -> hasLibraryB $ \settings2 -> buildProject "foo" $ settings <> settings2
    = \settings -> (\settings2 -> buildProject "foo" $ settings <> settings2) (mempty { settingsHasLibrary = Any True })
    = \settings -> buildProject "foo" $ settings <> mempty { settingsHasLibrary = Any True }
```

### Context-dependent builders

Now comes the fun part. We need to implement a builder for the Travis flag.
However, we can't just do the same job that we did for the other flags. We don't
want to set `projectTravis` to `True` if GitHub flag is set to `False`. So we
need to inspect the value of the GitHub flag before setting something to Travis
flag. The way to achieve the desired behaviour is the following:

```haskell
travisB :: ProjectBuilder -> Project
travisB builder =
    let project = extract builder
    in project { projectTravis = projectGitHub project }
```

The key observation here: our initial `buildProject` function mappends all
passed settings first and only then creates `Project`. So we can build the
`Project` first and later perform post-analysis to decide how to set the flag.

> **NOTE:** here `projectTravis` is set to the value of `projectGitHub` because
> it is the same as `if projectGitHub then True else False`.

The neat thing about this approach is that the result doesn't depend on the
order of applied builders. Because of that, we have better composability:

```haskell
ghci> extract $ buildProject "travis" =>> travisB
Project
    { projectName = "travis"
    , projectHasLibrary = False
    , projectGitHub = False
    , projectTravis = False
    }

ghci> extract $ buildProject "github-travis" =>> gitHubB =>> travisB
Project
    { projectName = "github-travis"
    , projectHasLibrary = False
    , projectGitHub = True
    , projectTravis = True
    }

ghci> extract $ buildProject "travis-github" =>> travisB =>> gitHubB
Project
    { projectName = "travis-github"
    , projectHasLibrary = False
    , projectGitHub = True
    , projectTravis = True
    }
```

> To make sure that the above works you can apply the [equational reasoning][er]
> technique here as well.

## Conclusion

Putting all together we have the following pieces of the Builder pattern
implemented in Haskell:

1. `Settings`: our configuration which is a Monoid as well.
2. `Project`: final result produced by our `Builder`.
3. `type ProjectBuilder = Settings -> Project`: our builder, also a Comonad.
4. `extract`: a way to build `Project` from `Settings`.
5. `(=>>)`: a way to compose different builders.

I hope that this blog post gives you a better understanding of comonads and
inspires you to play with them more!

Here is the gist with the complete code:

* [Code sample for comonadic builders][gist]


[builder]: https://en.wikipedia.org/wiki/Builder_pattern
[oop-comonads]: http://www.haskellforall.com/2013/02/you-could-have-invented-comonads.html
[summoner]: https://github.com/kowainik/summoner
[comonad]: https://hackage.haskell.org/package/comonad
[er]: http://www.haskellforall.com/2013/12/equational-reasoning.html
[Traced]: https://hackage.haskell.org/package/comonad-5.0.4/docs/Control-Comonad-Trans-Traced.html#t:TracedT
[gist]: https://gist.github.com/ChShersh/5a4c8e1c0557627859fe93ad0b05dd56
