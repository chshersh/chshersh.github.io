module Model.Blog exposing (..)


type alias T =
    { title : String
    , date : String
    , path : String
    }


mkUrl : T -> String
mkUrl article =
    "https://github.com/chshersh/chshersh.github.io/blob/develop/posts/" ++ article.path ++ ".md"


articles : List T
articles =
    [ { title = "8 months of OCaml after 8 years of Haskell in production"
      , date = "December 16th, 2023"
      , path = "/blog/8-months.html"
      }
    , { title = "Pragmatic Category Theory | Part 1: Semigroup Intro"
      , date = "July 30th, 2024"
      , path = "2024-07-30-pragmatic-category-theory-part-01"
      }
    , { title = "Pragmatic Category Theory | Part 2: Composing Semigroups"
      , date = "August 19th, 2024"
      , path = "2024-08-19-pragmatic-category-theory-part-02"
      }
    , { title = "7 OCaml Gotchas"
      , date = "May 20th, 2024"
      , path = "2024-05-20-7-ocaml-gotchas"
      }
    , { title = "Learn Lambda Calculus in 10 minutes with OCaml"
      , date = "February 5th, 2024"
      , path = "2024-02-05-learn-lambda-calculus-in-10-minutes-with-ocaml"
      }
    ]
