module Website.Project
       ( Project (..)
       , allProjectsContext
       , currentProjectsContext
       ) where

import Hakyll (Compiler, Context, Item (..), field, listField, makeItem)


data Project = Project
    { projectName :: String
    , projectLink :: String
    , projectDesc :: String
    }

pName, pLink, pDesc :: Context Project
pName = field "pName" $ pure . projectName . itemBody
pLink = field "pLink" $ pure . projectLink . itemBody
pDesc = field "pDesc" $ pure . projectDesc . itemBody

currentProjects :: Compiler [Item Project]
currentProjects = traverse makeItem
    [ Project
        { projectName = "🌈 iris"
        , projectLink = "https://github.com/chshersh/iris"
        , projectDesc = "Haskell CLI Framework supporting Command Line Interface Guidelines"
        }
    , Project
        { projectName = "🧰 tool-sync"
        , projectLink = "https://github.com/chshersh/tool-sync"
        , projectDesc = "A CLI tool written in Rust for downloading pre-built binaries of all your favourite tools with a single command"
        }
    , Project
        { projectName = "📊 dr-cabal"
        , projectLink = "https://github.com/chshersh/dr-cabal"
        , projectDesc = "Haskell dependencies build times profiler"
        }
    , Project
        { projectName = "👁 sauron"
        , projectLink = "https://github.com/chshersh/sauron"
        , projectDesc = "A CLI tool that fetches top user tweets (written with Haskell and Iris)"
        }
    , Project
        { projectName = "🧪 ghc-plugin-non-empty"
        , projectLink = "https://github.com/chshersh/ghc-plugin-non-empty"
        , projectDesc = "A Haskell compiler plugin for writing type-safe programs easier"
        }
    ]

previousProjects :: Compiler [Item Project]
previousProjects = traverse makeItem
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

allProjects :: Compiler [Item Project]
allProjects = liftA2 (++) currentProjects previousProjects

allProjectsContext :: Context a
allProjectsContext = listField "allProjects" (pName <> pLink <> pDesc) allProjects

currentProjectsContext :: Context a
currentProjectsContext = listField "currentProjects" (pName <> pLink <> pDesc) currentProjects
