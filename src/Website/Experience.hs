module Website.Experience
       ( Experience (..)
       , workExperienceContext
       , mentorshipExperienceContext
       ) where

import Hakyll (Compiler, Context, Item (..), field, listField, makeItem)


data Experience = Experience
    { experienceTitle   :: String
    , experienceSite    :: String
    , experienceCompany :: String
    , experienceDesc    :: String
    , experienceDate    :: String
    }

eTitle, eSite, eCompany, eDesc, eDate :: Context Experience
eTitle   = field "eTitle"   $ pure . experienceTitle   . itemBody
eSite    = field "eSite"    $ pure . experienceSite    . itemBody
eCompany = field "eCompany" $ pure . experienceCompany . itemBody
eDesc    = field "eDesc"    $ pure . experienceDesc    . itemBody
eDate    = field "eDate"    $ pure . experienceDate    . itemBody

workExperience :: Compiler [Item Experience]
workExperience = traverse makeItem
    [ Experience
        { experienceTitle   = "Senior Software Engineer"
        , experienceSite    = "https://www.bloomberg.com/uk"
        , experienceCompany = "Bloomberg"
        , experienceDesc    = "Implementation of a trade engine using OCaml"
        , experienceDate    = "May 2023 — Present"
        }
    , Experience
        { experienceTitle   = "Senior Software Engineer"
        , experienceSite    = "https://feeld.co/"
        , experienceCompany = "Feeld"
        , experienceDesc    = "Development of the backend to support a dating app with high load, legacy code extraction, using latest techniques for performance profiling, mentorship, organization and workflow improvements."
        , experienceDate    = "April 2022 — April 2023"
        }
    , Experience
        { experienceTitle   = "Quantitative Developer"
        , experienceSite    = "https://www.sc.com/en/"
        , experienceCompany = "Standard Chartered Bank"
        , experienceDesc    = "Implementing and supporting pricing platform core features, working on a custom build tool and GHC infrastructure, developing web-services, enhancing products maintainability, monitoring and analysing project performance, improving continuous integration, continuous deployment and developing experience."
        , experienceDate    = "December 2019 — April 2022"
        }
    , Experience
        { experienceTitle   = "Software Engineer"
        , experienceSite    = "https://www.holmusk.com/"
        , experienceCompany = "Holmusk"
        , experienceDesc    = "Backend development of web applications in Haskell. Working on healthcare projects that sync information from multiple sources and display them to users. Integration with machine learning models in other languages. Technologies included: Haskell, Elm, PostgreSQL, Amazon services (S3, SQS), Protocol buffers."
        , experienceDate    = "May 2018 — November 2019"
        }
    , Experience
        { experienceTitle   = "Software Engineer"
        , experienceSite    = "https://serokell.io/"
        , experienceCompany = "Serokell"
        , experienceDesc    = "Developing distributed cryptocurrency systems using Haskell. Implementing cryptocurrency protocols, creating logging framework, writing jekyll documentation in English, Haskell development and refactoring tooling support, performance optimizations, benchmarking, making world better."
        , experienceDate    = "May 2016 — April 2018"
        }
    ]

mentorshipExperience :: Compiler [Item Experience]
mentorshipExperience = traverse makeItem
    [ Experience
        { experienceTitle   = "OSS Maintainer"
        , experienceSite    = "https://hacktoberfest.com/"
        , experienceCompany = "Digital Ocean et al."
        , experienceDesc    = "Mentoring Haskell beginners in various Haskell OSS projects and courses."
        , experienceDate    = "October 2017, 2018, 2019, 2020, 2021, 2022"
        }
    , Experience
        { experienceTitle   = "Mentor"
        , experienceSite    = "https://summer.haskell.org/"
        , experienceCompany = "Google Summer of Code (Haskell)"
        , experienceDesc    = "Mentoring a person in the web application development using Haskell, Elm and PostgreSQL."
        , experienceDate    = "May 2019 - September 2019"
        }
    , Experience
        { experienceTitle   = "Haskell PL Tutor"
        , experienceSite    = "http://en.ifmo.ru/en/"
        , experienceCompany = "ITMO University"
        , experienceDesc    = "Teaching the course about functional programming in Haskell: desinging the course, creating lecture slides and validating completed lab assignments."
        , experienceDate    = "September 2015 — April 2018"
        }
    ]

workExperienceContext :: Context a
workExperienceContext = listField "workExperience" (eTitle <> eSite <> eCompany <> eDesc <> eDate) workExperience

mentorshipExperienceContext :: Context a
mentorshipExperienceContext = listField "mentorshipExperience" (eTitle <> eSite <> eCompany <> eDesc <> eDate) mentorshipExperience
