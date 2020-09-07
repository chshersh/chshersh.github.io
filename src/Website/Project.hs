module Website.Project
       ( Project (..)
       , projectsContext
       ) where

data Project = Project
    { projectName :: !String
    , projectLink :: !String
    , projectDesc :: !String
    }

pName, pLink, pDesc :: Context Project
pName = field "pName" $ pure . projectName . itemBody
pLink = field "pLink" $ pure . projectLink . itemBody
pDesc = field "pDesc" $ pure . projectDesc . itemBody

allProjects :: Compiler [Item Project]
allProjects = traverse makeItem
    [ Project
        { projectName = "📕 co-log"
        , projectLink = "https://kowainik.github.io/posts/2018-09-25-co-log"
        , projectDesc = "Composable contravariant comonadic logging library"
        }
    , Project
        { projectName = "🌀 relude"
        , projectLink = "https://github.com/kowainik/relude"
        , projectDesc = "Alternative standard library for Haskell with modern idioms"
        }
    , Project
        { projectName = "🏝 tomland"
        , projectLink = "https://kowainik.github.io/posts/2019-01-14-tomland"
        , projectDesc = "Bidirectional TOML serialization library with monadic profunctors, theorem proving and prefix trees"
        }
    , Project
        { projectName = "🍃 treap"
        , projectLink = "https://github.com/chshersh/treap"
        , projectDesc = "Efficient implementation of the implicit treap data structure"
        }
    , Project
        { projectName = "🐞 type-errors-pretty"
        , projectLink = "https://github.com/chshersh/type-errors-pretty"
        , projectDesc = "Combinators for writing pretty type errors easily"
        }
    , Project
        { projectName = "🎒 containers-backpack"
        , projectLink = "https://kowainik.github.io/posts/2018-08-19-picnic-put-containers-into-a-backpack"
        , projectDesc = "Backpack implementation of the uniform interface for containers in Haskell"
        }
    , Project
        { projectName = "🌋 idris-patricia"
        , projectLink = "https://github.com/kowainik/idris-patricia"
        , projectDesc = "Idris implementation of the patricia trees"
        }
    ]

projectsContext :: Context a
projectsContext = listField "projects" (pName <> pLink <> pDesc) allProjects
