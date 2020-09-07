---
title: Be a goalkeeper
description: A secret weapon for increasing open-source productivity and communication
tags: open-source, haskell
shortName: goalkeeper
---

![Be a goalkeeper](/images/goalkeeper.png)

During many years of open-source development I have come to the
helpful habit that severely increases productivity of my work, and
greatly increases projects maintainability and sustainability. I also
noticed that very few people actually follow the same way of personal
project development as I do.

So, in this post I want to share this magical (at least for me)
approach, give a few examples and elaborate on why it is important to
integrate it into your project development routine.

You may find this blog post useful, if you are interested in
maintaining any project for a long time and keep your sanity during
this process.

## One goal to rule them all

The suggestion itself is rather simple:

::: {.thought}

Define the project goals.

:::

That's it. Come up with the goals and write them explicitly somewhere.

The goals can be written either in README.md of your repository, or
Wiki for your project, or even some private text document that only
you can see. But it is crucial to **set the goals** for your project
and **record** them somewhere. And here is why.

Usually, when you create a new project, you have some strong
understanding of why you are doing this. The reasons could be
absolutely different. You may want to:

  * Learn something new
  * Experiment with some wild ideas
  * Solve your specific problem
  * Try to fill the gap in the language's ecosystem
  * Literally anything else!

And you have your own unique vision on how you prefer to execute your
plan. The desired resulting product could be one of the following:

  * Lightweight dependencies-wise but yet batteries-included solution
  * Composable library
  * All-inclusive framework
  * Beginner-friendly designed interface
  * Advanced users targeted package that uses some sophisticated
    language features and techniques

However, as we all are different, we may have different visions of all
the above subject areas. Moreover, even your own vision may change
over time, and that is normal.

If you have a self-checking note that helps to navigate between many
directions of your project, you won't accidentally change the
course. The act of changing the project roadmap will be an explicit
action in that case.

In your private projects such a note would help you to find the
motivation and perspective on how to proceed with the project to
accomplish your goals. However, in the open-source world, other people
– users of your project or just curious people – may come and point
out that they find something inconvenient or some features
lacking. Usually they would visit your bug-tracker and propose some
changes. And if those changes do not align with the goals of your
project, they should not be accepted.

However, if you don't write the goals explicitly, people **may
impose** the goals for you, and you could spend a lot of time and
mental health arguing about some particular proposal trying to
convince the opposite side in what you think is better for the
project, and they would do the same to you, as there is no clear
vision of what is actually right.

Another possibility is that you may accept the feature and changes,
but as it is not aligned with the goals, it may lead to the issues in
the future:

  * additional costs to support what you are not interested in
  * obstacles on the way of implementing some other feature that you need
  * misunderstanding of how to better serve this feature
  * etc.

While doing open-source, I've noticed that people usually implicitly
assume the following goals for you:

  * Be the ultimate best-in-class solution for a problem, or don't
    exist at all
  * Cover and provide the support for every use-case, even very
    specific ones
  * Implement the project using only "blessed" or "popular" design
    patterns (by the opinion of each person separately)
  * Be the most performant solution among all
  * Satisfy as many users of your library/tool/application as possible

Even if all the above goals are noble and reasonable in particular
situations, you can easily see how they might be different from your
own plans, distract you from the main goals, or sometimes simply
impossible to achieve.

But even with the set list of goals in your mind there could be some
difficulties. One important thing to consider, when interacting in the
open-source world, is the anxiety of rejecting people's thoughts,
notably when they are completely valid and make sense to you
generally, but not in the context of a particular project. Even though
it is important to say "no" and stick to your goals for the project to
succeed, people's feelings could be hurt when you reject their work,
especially if they put effort into it. That is why it is nice to have
the goals for your open-source project publically, so people know what
to expect, and you can link to that instead of walking on the
minefield of people's emotions.

<hr>

::: {.thought}

Defining goals and priorities helps to triage bug reports and
feature requests.

:::

Let's be honest, many developers do open-source only in their
**free time**, unfortunately. It's already impossible to satisfy
_everyone_. And it's completely impossible to solve _all_ problems
using limited resources. We must always remember that **time and
mental health are very limited resources**.

Of course, you can be excited about other people using your solutions,
and it is really a great feeling when somebody else finds your work
useful and worth depending on! As a consequence, you may spend a lot
of time implementing and maintaining features they want. But it is not
sustainable to follow others dreams instead of yours.

As an extreme example,
[a repository can accept any PR](@github(illacceptanything):illacceptanything),
but you don't need to be a psychic to predict what is happening in
there.

## How to determine goals for your project?

When starting a new project, I think about the purpose of creating the
project and why I want to work on it. It is quite a tricky process
that requires time to analyse the given information, capabilities and
limits.

I see how hard it sounds, so here are my two cents to help people come
up with their goals:

  1. Always try to put realistic goals.
  2. When writing down the goals think about how important and
     relevant they are to the project.
  3. Do not put anything because it **has to** be in there, you are
     not obligated to anything you are not personally interested in
     doing. Believe me, the strong motivation behind each goal is
     important.
  4. It is okay to adjust goals on the way: an experimental project
     could become primary, and vice versa as well.

If you are only starting doing open-source or maintaining your own
project, and struggling with defining goals for your projects, you can
learn from other people's experience. Alternatively, you can follow
some established processes for defining goals which are suitable for
programming projects as well. An example of such metodology is
[S.M.A.R.T.](https://en.wikipedia.org/wiki/SMART_criteria).

## Project goals example

Below is a specific example of the project I'm working on, which
defines its goals upfront:

  * [Relude](@github(kowainik)) — safe, performant and lightweight
    Haskell standard library.

Shortly, being a standard library for Haskell, the Relude has goals to
provide Haskell developers with an interface that increases their
productivity and encourages Haskell best-practices, while still being
beginner-friendly and easy to use even for experienced users. These
goals can be achieved in multiple ways, e.g. by providing a safe and
lightweight interface.

I stand by these goals all the time, and Relude goals are even
highlighted in its description to indicate that. As the Prelude is a
rather important part of any application, through our goals we want to
make it easier for users to decide if they would need to replace the
default standard library with Relude before committing to long-term
relationships.

The project passed the test of time by proving itself useful and
convenient to use. And it is the goals that make it successful and
help to be productive. So it's helpful to remind ourselves about the
library course.

If you don't agree with the project goals, you can always just not use
it. It is completely fine that some other tool may solve your problem
better. And goals tell you what to expect from a particular tool,
library or application.

Here are some proofs that this approach works. In Relude we were
declining some changes and proposals due to the fact that they were
not aligned with our goals. Similarly, we were gladly accepting
proposals that make developer lives easier and not contradict with our
goals. A few examples:

  * Not aligned with the goals: [Non partial Data.Text.head](https://github.com/kowainik/relude/issues/330)
  * Aligned with the goals: [Could I add `average`?](https://github.com/kowainik/relude/issues/316)

Having goals written severely improved our experience both as Relude
users and maintainers.

## Haskell goals

::: {.thought}

What are the Haskell goals really?

:::

I love Haskell and I feel extremely productive using this programming
language. It is totally okay if you disagree and if you feel more
comfortable using other tools. We all have different preferences, and,
at least in our spare time, we are free to choose what to use. I'm not
here to sell Haskell to you, today we are talking about goals only.

And because I enjoy using Haskell, I want this particular programming
language to become more approachable, helpful and convenient both for
me personally and other potential users of the language as well. And
this desire motivates me to contribute towards achieving this goal by
doing a lot of open-source in Haskell and for the Haskell ecosystem.

At the same time, I'm extremely worried about the Haskell future. Not
because of some language design decisions, but because I do not
completely see where Haskell is moving, and whether the goals and
values of the core developers align with my long-term goals and
values.

::: {.thought}

I believe it would be beneficial for the whole Haskell community to
define goals of Haskell (the language) and GHC (the Haskell
compiler).

:::

To give an example of why I think so, let's have a look at the
[ghc-proposals](@github(ghc-proposals)) repository. It is a place
where anyone can propose a change to Haskell, the community is
supposed to discuss it, and the committee then will decide to accept
or reject the proposal.

I think this is an awesome initiative, where everyone can be involved
and improve the language they love, as well as get valuable opinions
from other experienced and brilliant Haskell developers at the same
time! I love that Haskell evolves and improves over time under the
common efforts.

The `ghc-proposals` readme contains a detailed description of a good
proposal, but what it misses is a description of what committee values
in the proposals. However, this part seems important in the presence
of the following acceptance criterion:

> For acceptance, a proposal must have at least _some_ enthusiastic
> support from member(s) of the committee.

Specifically, it is valuable to know many things beforehand to guess
what the decision status could possibly be. For example, whether the
committee fancy completely new features over syntax changes, or if it
is okay to break backwards compatibility.

I feel like the project development is not healthy if instead of
depending on some values or goals, it depends more on which party has
more time and energy to contribute their vision or which party has
more reputation or more power. I'm not saying that this is the case
with Haskell. I just want to highlight this thought: having a
well-defined roadmap is **better for everyone**.

_As a Haskell developer_, I'm naturally worried that some changes to
Haskell may negatively change the way we write the code and work with
the language.

_As an author of a GHC proposal_, I'm worried that I will spend a lot
of time writing the proposal, thinking about corner cases and
discussing the proposal in comments, when it will be rejected
eventually because it wasn't aligned with the Haskell goals from the
start.

One possible list of goals for GHC/Haskell can look like this:

  1. Be beginner-friendly.
  2. Allow solving real-life problems in a convenient and expressive way.
  3. Think about language users.
  4. Value UX improvements.
  5. Provide smooth migration plans, when breaking changes are unavoidable.

I think that the following GHC proposal is a good representer of these
goals:

  * [RecordDotSyntax language extension proposal](https://github.com/ghc-proposals/ghc-proposals/pull/282)

At the same time, the following list of goals is also completely
valid:

  1. Be a platform for academic research and playground for new
     Programming Languages ideas.
  2. Experiment with new techniques and approaches and see how they
     can be applied to solving real-world problems.
  3. Allow changing the syntax, if it makes the life of compiler
     maintainers easier.
  4. Pursue the goal of implementing the ideal language.

And I think that this proposal illustrates the above goals:

  * [Linear types](https://github.com/ghc-proposals/ghc-proposals/pull/111)

While both lists are reasonable, the outcome of having one set of
goals is completely different from having another. As a developer or
as a researcher you may find one list appealing, while another is less
satisfying.

I would like you to think about the following important question we
all should ask ourselves:

::: {.thought}

What values in the programming language you find attractive and
healthy, so you would like to engage in that community more?

:::

And maybe together we could help Haskell by establishing some concrete
goals.

## Acknowledgement

Thanks to [Veronika Romashkina](https://vrom911.github.io/) for the
inspiration, illustrations and support!
