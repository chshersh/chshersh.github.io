module Website.Experience
       ( Experience (..)
       , experienceContext
       ) where

import Hakyll (Compiler, Context, Item (..), field, listField, makeItem)


data Experience = Experience
    { experienceTitle   :: !String
    , experienceSite    :: !String
    , experienceCompany :: !String
    , experienceDesc    :: !String
    , experienceDate    :: !String
    }

eTitle, eSite, eCompany, eDesc, eDate :: Context Experience
eTitle   = field "eTitle"   $ pure . experienceTitle   . itemBody
eSite    = field "eSite"    $ pure . experienceSite . itemBody
eCompany = field "eCompany" $ pure . experienceCompany . itemBody
eDesc    = field "eDesc"    $ pure . experienceDesc    . itemBody
eDate    = field "eDate"    $ pure . experienceDate    . itemBody

allExperience :: Compiler [Item Experience]
allExperience = traverse makeItem
    [ Experience
        { experienceTitle   = "Co-founder & Maintainer"
        , experienceSite    = "https://kowainik.github.io/"
        , experienceCompany = "Kowainik"
        , experienceDesc    = "Using Haskell to build better software. Improving Haskell ecosystem and making community friendlier. Mentoring people and help them to learn the programming language."
        , experienceDate    = "March 2018 — Present"
        }
    , Experience
        { experienceTitle   = "Quantitative Developer"
        , experienceSite    = "https://www.sc.com/en/"
        , experienceCompany = "Standard Chartered Bank"
        , experienceDesc    = "Implementing and supporting pricing platform core features, working on a custom build tool and GHC infrastructure, developing web-services, enhancing products maintainability, monitoring and analysing project performance, improving continuous integration, continuous deployment and developing experience."
        , experienceDate    = "December 2019 — Present"
        }
    , Experience
        { experienceTitle   = "Middle Haskell Developer"
        , experienceSite    = "https://www.holmusk.com/"
        , experienceCompany = "Holmusk"
        , experienceDesc    = "Backend development of web applications in Haskell. Working on healthcare projects that sync information from multiple sources and display them to users. Integration with machine learning models in other languages. Technologies included: Haskell, Elm, PostgreSQL, Amazon services (S3, SQS), Protocol buffers."
        , experienceDate    = "May 2018 — November 2019"
        }
    , Experience
        { experienceTitle   = "Haskell Software Engineer"
        , experienceSite    = "https://serokell.io/"
        , experienceCompany = "Serokell"
        , experienceDesc    = "Developing distributed cryptocurrency systems using Haskell. Implementing cryptocurrency protocols, creating logging framework, writing jekyll documentation in English, Haskell development and refactoring tooling support, performance optimizations, benchmarking, making world better."
        , experienceDate    = "May 2016 — April 2018"
        }
    , Experience
        { experienceTitle   = "Haskell PL Tutor"
        , experienceSite    = "http://en.ifmo.ru/en/"
        , experienceCompany = "ITMO University"
        , experienceDesc    = "Teaching the course about functional programming in Haskell: desinging the course, creating lecture slides and validating completed lab assignments."
        , experienceDate    = "September 2015 — April 2018"
        }
    ]

experienceContext :: Context a
experienceContext = listField "experience" (eTitle <> eSite <> eCompany <> eDesc <> eDate) allExperience
