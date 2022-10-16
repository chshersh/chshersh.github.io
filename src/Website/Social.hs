module Website.Social
       ( Social (..)
       , socialContext
       ) where

import Hakyll (Compiler, Context, Item (..), field, listField, makeItem)


data Social = Social
    { sName :: !String
    , sLink :: !String
    }

socialName, socialLink :: Context Social
socialName = field "socialName" $ pure . sName . itemBody
socialLink = field "socialLink" $ pure . sLink . itemBody

allSocials :: Compiler [Item Social]
allSocials = traverse makeItem
    [ Social "twitter"        "https://twitter.com/chshersh"
    , Social "github"         "https://github.com/chshersh"
    , Social "youtube"        "https://youtube.com/c/chshersh"
    , Social "reddit"         "https://www.reddit.com/user/chshersh"
    , Social "stack-overflow" "https://stackoverflow.com/users/2900502/shersh"
    , Social "linkedin"       "https://www.linkedin.com/in/chshersh/"
    ]

socialContext :: Context a
socialContext = listField "socials" (socialName <> socialLink) allSocials
