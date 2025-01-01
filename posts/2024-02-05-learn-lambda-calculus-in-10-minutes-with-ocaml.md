---
title: "Learn Lambda Calculus in 10 minutes with OCaml"
description: Brief intro to Lambda Calculus
tags: ocaml, functional programming, lambda calculus
shortName: "learn-lambda"
updated: "July 29th, 2024"
---

I'm going to teach you the basics of Lambda Calculus really quickly.

Lambda Calculus is deep. But I'm covering only the fundamentals here.

## What is Lambda Calculus?

[Lambda Calculus][lambda-wiki] (LC) is a model to describe computations.

[lambda-wiki]: https://en.wikipedia.org/wiki/Lambda_calculus

LC describes the syntax and semantics.

## Syntax

A **lambda expression** (also known as **lambda term**) can be one of the following three things:

1. Variable
2. Application
3. Abstraction

### Variable

A **variable** is just a **string**. For example:

- **Traditional:**
    ```
    x
    ```
- **Programmer-friendly**
    ```
    company_id
    ```

### Application

**Application** (aka _function application_) is applying one term to another.

To introduce an application, simply separate two terms by a space (and use parentheses appropriately).

An application can be simple:

- **Traditional:**
    ```
    f x
    ```
- **Programmer-friendly**
    ```
    employees_of company_id
    ```

Or more involved

- **Traditional:**
    ```
    f (g x) (h x)
    ```
- **Programmer-friendly**
    ```
    find_by_id (get map (entry key)) (hash id)
    ```

> :warning: Parentheses matter! `f (g x)` is not the same as `(f g) x`!

### Abstraction

**Abstraction** (aka anonymous function) is a way to introduce functions in Lambda Calculus.

To introduce an abstraction, write the Greek letter `λ` followed by the variable name, a dot `.` and a body of a function.

> The variable after λ is known to be **bound**.


- **Traditional:**
    ```
    λx.f x
    ```
- **Programmer-friendly**
    ```
    λcompany_id.employees_of company_id
    ```

Abstractions can be nested:

- **Traditional:**
    ```
    λx.λy.f x y
    ```
- **Programmer-friendly**
    ```
    λcompany_id.λcount.has_at_least (employees_of company_id) count
    ```

## Semantics

LC is not just about a fancy way to write functions and their arguments. It also attaches semantics to terms. Specifically:

1. Rename a bound variable (known as **α-conversion**)
2. Apply a function to its arguments (known as **β-reduction**)

### Renaming (α-conversion)

The idea is simple. If you rename a local variable of a function, the behaviour of this function doesn't change.

Terms on both sides of `=` are equal in the following examples:

- **Traditional:**
    ```
    λx.f (g x) (h x) = λy.f (g y) (h y)
    ```
- **Programmer-friendly**
    ```
    λcompany_id.size company_id = λcompanyId.size companyId
    ```

### Applying (β-reduction)

Function application takes an _abstraction_ and applies it to its argument by replacing a bound variable with the argument.

It's implemented as a simple string search-and-replace. Evaluating a function has never been simpler!

I'm using the `=>` operator here with the meaning _reduces to_.

- **Traditional:**
    ```
    (λx.f x) y => f y
    ```
- **Programmer-friendly**
    ```
    (λcompany_id.size company_id) bloomberg => size bloomberg
    ```

> ⚠️ You can see that parentheses matter here as well! `λx.f x y` is not the same as `(λx.f x) y`!

> 💎 Bonus! One lambda term is especially popular, it even has its own name **Ω-combinator**
> ```
> (λx.x x) (λx.x x)
> ```
> It represents infinite recursion because beta-reducing this term returns the term itself.

<hr/>

As you can see, the basics of Lambda Calculus are pretty simple but turns out, they're powerful enough to describe **any possible computation**. Although, it might not provide the most efficient way to compute things.

## Practice

Now that we learned the theory, it's time to do some practice!

> The following sections provide exercises for you to implement a simple program to work with LC. Solutions in OCaml are provided as well.

> ⚠️ Implementing the following exercises may take longer than 10 minutes, so don't worry!

### Modeling Lambda Calculus

First of all, let's define a type to model a term in Lambda Calculus. Remember, it can be either a variable name, an application of two terms or a lambda-abstraction.

**Exercise 1.** Create a data type to describe a term in Lambda Calculus.

<details>

<summary>Solution in OCaml</summary>

This is nicely modelled with sum types:

```ocaml
type expr =
  | Var of string
  | App of expr * expr
  | Lam of string * expr
```

Example of terms in both LC and OCaml:

| Lambda Calculus | OCaml                               |
|-----------------|-------------------------------------|
| x               | `Var "x"`                           |
| f x             | `App (Var "f", Var "x")`            |
| λx.f x          | `Lam ("x", App (Var "f", Var "x"))` |

</details>

### Pretty-printing

Now that we have a type, let's implement a function to display a value of our type nicely.

**Exercise 2.** Implement a pretty-printing function for Lambda Calculus.

<details>

<summary>Solution in OCaml</summary>

A simple solution in OCaml (that may produce some redundant parentheses) uses just pattern matching, `printf` and recursion.

```ocaml
let rec pretty = function
  | Var x -> x
  | App (l, r) -> Printf.sprintf "(%s) (%s)" (pretty l) (pretty r)
  | Lam (x, body) -> Printf.sprintf "λ%s.(%s)" x (pretty body)
```

</details>

### Parsing

And the most difficult part (that made me ignore FP for 3 (!) years when I first tried to implement it).

Can we go backwards? Can we parse a string to a value of our type?

**Exercise 3.** Implement a parser for Lambda Calculus.

<details>

<summary>Solution in OCaml</summary>

Here I'm using the Parser Combinators approach provided by the wonderful [angstrom] OCaml library.

Parser Combinators deserve a separate blog post, so here I'm just presenting the full code without comments.

[angstrom]: https://github.com/inhabitedtype/angstrom

```ocaml
open Angstrom

let parens_p p = char '(' *> p <* char ')'

let name_p =
  take_while1 (function 'a' .. 'z' -> true | _ -> false)

let var_p = name_p >>| (fun name -> Var name)

let app_p expr_p =
  let* l = parens_p expr_p in
  let* _ = char ' ' in
  let* r = parens_p expr_p in
  return (App (l, r))

let lam_p expr_p =
  let* _ = string "λ" in
  let* var = name_p in
  let* _ = char '.' in
  let* body = parens_p expr_p in
  return (Lam (var, body))

let expr_p: expr t =
  fix (fun expr_p ->
    var_p <|> app_p expr_p <|> lam_p expr_p <|> parens_p expr_p
  )

let parse str =
  match parse_string ~consume:All expr_p str with
  | Ok expr   -> Printf.printf "Success: %s\n%!" (pretty expr)
  | Error msg -> failwith msg
```

</details>

<hr>

The full working OCaml code can be found here:

- [`lam.ml`: Lambda Calculus in OCaml](https://gist.github.com/chshersh/6d354c0a3a9a4120a30226f26853653f)

## What's next?

I hope this blog post helped you to learn the basics of Lambda Calculus!

At least now, when you hear these words, you'll know their meaning.

If you feel like you want to take on some challenge, you can try to implement α-conversion and β-reduction for your simple Lambda Calculus language!

And most importantly, have fun!
