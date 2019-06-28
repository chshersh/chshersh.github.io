module Website.Social
       ( Social (..)
       , socialContext
       ) where


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
    , Social "reddit"         "https://www.reddit.com/user/chshersh"
    , Social "stack-overflow" "https://stackoverflow.com/users/2900502/shersh"
    , Social "linkedin"       "https://www.linkedin.com/in/chshersh/"
    , Social "telegram"       "https://t.me/chshersh"
    ]

socialContext :: Context a
socialContext = listField "socials" (socialName <> socialLink) allSocials
