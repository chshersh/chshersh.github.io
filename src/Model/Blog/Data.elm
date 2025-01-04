module Model.Blog.Data exposing (..)

type alias Article =
    { title : String
    , createdAt : String
    , path : String
    }

articles : List Article
articles =
    [ { title = "Pragmatic Category Theory | Part 3: Associativity"
      , createdAt = "December 20th, 2024"
      , path = "2024-12-20-pragmatic-category-theory-part-03"
      }
    , { title = "Pragmatic Category Theory | Part 2: Composing Semigroups"
      , createdAt = "August 19th, 2024"
      , path = "2024-08-19-pragmatic-category-theory-part-02"
      }
    , { title = "Pragmatic Category Theory | Part 1: Semigroup Intro"
      , createdAt = "July 30th, 2024"
      , path = "2024-07-30-pragmatic-category-theory-part-01"
      }
    , { title = "7 OCaml Gotchas"
      , createdAt = "May 20th, 2024"
      , path = "2024-05-20-7-ocaml-gotchas"
      }
    , { title = "Learn Lambda Calculus in 10 minutes with OCaml"
      , createdAt = "February 5th, 2024"
      , path = "2024-02-05-learn-lambda-calculus-in-10-minutes-with-ocaml"
      }
    , { title = "8 months of OCaml after 8 years of Haskell in production"
      , createdAt = "December 16th, 2023"
      , path = "2023-12-16-8-months-of-ocaml-after-8-years-of-haskell"
      }
    , { title = "Avoiding space leaks at all costs"
      , createdAt = "August 8th, 2022"
      , path = "2022-08-08-space-leak"
      }
    , { title = "Using a 50-years old technique for solving modern issues"
      , createdAt = "June 30th, 2022"
      , path = "2022-06-30-cps"
      }
    , { title = "Dead simple cross-platform GitHub Actions for Haskell"
      , createdAt = "May 7th, 2020"
      , path = "2020-05-07-github-actions"
      }
    , { title = "The Power of RecordWildCards"
      , createdAt = "July 29th, 2019"
      , path = "2019-07-29-recordwildcards"
      }
    , { title = "A story told by Type Errors"
      , createdAt = "July 1st, 2019"
      , path = "2019-07-01-type-errors"
      }
    , { title = "Comonadic builders"
      , createdAt = "March 25th, 2019"
      , path = "2019-03-25-comonadic-builders"
      }
    , { title = "Dead simple Haskell Travis settings for cabal and stack"
      , createdAt = "February 25th, 2019"
      , path = "2019-02-25-haskell-travis"
      }
    ]