module Chshersh.Posts
       ( postsRules
       , postsContextCompiler
       , externalPostsContext
       , postContext
       ) where

import Hakyll (compile, dateField, defaultContext, functionField, loadAll, match, pandocCompiler,
               recentFirst, route, saveSnapshot, setExtension)

import Chshersh.Social (socialContext)

import qualified Data.Text as T


postsRules :: Rules ()
postsRules = match "posts/*" $ do
    route $ setExtension "html"
    compile $ do
        let ctx = postContext <> socialContext
        pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html" ctx
            >>= saveSnapshot "content"
            >>= relativizeUrls

postsContextCompiler :: Compiler (Context String)
postsContextCompiler = do
    posts <- recentFirst =<< loadAll "posts/*"
    pure $ listField "posts" postContext (pure posts)

-- | Removes the @.html@ suffix in the post URLs.
stripHtmlContext :: Context a
stripHtmlContext = functionField "stripExtension" $ \args _ -> case args of
    [k] -> pure $ maybe k toString (T.stripSuffix ".html" $ toText k)
    _   -> error "relativizeUrl only needs a single argument"

-- Context to used for posts
postContext :: Context String
postContext = mconcat
    [ stripHtmlContext
    , dateField "date" "%B %e, %Y"
    , defaultContext
    ]

data Post = Post
    { postName   :: String
    , postUrl    :: String
    , postSource :: String
    , postDate   :: String
    }

externalPosts :: Compiler [Item Post]
externalPosts = traverse makeItem
    [ Post
        { postName   = "tomland: Bidirectional TOML serialization"
        , postUrl    = "https://kowainik.github.io/posts/2019-01-14-tomland"
        , postSource = "Kowainik"
        , postDate   = "January 14, 2019"
        }
    , Post
        { postName   = "State monad comes to help sequential pattern matching"
        , postUrl    = "https://kowainik.github.io/posts/2018-11-18-state-pattern-matching"
        , postSource = "Kowainik"
        , postDate   = "November 18, 2018"
        }
    , Post
        { postName   = "co-log: Composable Contravariant Combinatorial Comonadic Configurable Convenient Logging"
        , postUrl    = "https://kowainik.github.io/posts/2018-09-25-co-log"
        , postSource = "Kowainik"
        , postDate   = "September 25, 2018"
        }
    , Post
        { postName   = "Picnic: put containers into a backpack"
        , postUrl    = "https://kowainik.github.io/posts/2018-08-19-picnic-put-containers-into-a-backpack"
        , postSource = "Kowainik"
        , postDate   = "August 19, 2018"
        }
    , Post
        { postName   = "Haskell: Build Tools"
        , postUrl    = "https://kowainik.github.io/posts/2018-06-21-haskell-build-tools"
        , postSource = "Kowainik"
        , postDate   = "June 21, 2018"
        }
    ]

externalPostsContext :: Context a
externalPostsContext = listField
    "externalPosts"
    (postNameCtx <> postUrlCtx <> postSourceCtx <> postDateCtx)
    externalPosts

postNameCtx, postUrlCtx, postSourceCtx, postDateCtx :: Context Post
postNameCtx   = field "postName"   $ pure . postName   . itemBody
postUrlCtx    = field "postUrl"    $ pure . postUrl    . itemBody
postSourceCtx = field "postSource" $ pure . postSource . itemBody
postDateCtx   = field "postDate"   $ pure . postDate   . itemBody
