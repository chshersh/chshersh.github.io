module Website.Project
       ( Project (..)
       , projectsContext
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

projects :: Compiler [Item Project]
projects = traverse makeItem
    [ Project
        { projectName = "🌈 iris"
        , projectLink = "https://github.com/chshersh/iris"
        , projectDesc = "Haskell CLI Framework supporting Command Line Interface Guidelines"
        }
    , Project
        { projectName = "✨ zbg"
        , projectLink = "https://github.com/chshersh/zbg"
        , projectDesc = "Zero Bullshit Git"
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
        { projectName = "🧪 ghc-plugin-non-empty"
        , projectLink = "https://github.com/chshersh/ghc-plugin-non-empty"
        , projectDesc = "A Haskell compiler plugin for writing type-safe programs easier"
        }
    , Project
        { projectName = "👁 sauron"
        , projectLink = "https://github.com/chshersh/sauron"
        , projectDesc = "A CLI tool that fetches top user tweets (written with Haskell and Iris)"
        }
    ]

projectsContext :: Context a
projectsContext = listField "projects" (pName <> pLink <> pDesc) projects
