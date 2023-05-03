module Website.Feed
       ( feedCompiler
       ) where

import Hakyll (Compiler, Context, Item, bodyField, loadAllSnapshots, recentFirst)
import Hakyll.Web.Feed (FeedConfiguration (..))

import Website.Posts (postContext)


feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "chshersh :: Haskell blog posts"
    , feedDescription = "This feed provides blog posts about using modern Haskell"
    , feedAuthorName  = "Dmitrii Kovanikov"
    , feedAuthorEmail = "kovanikov@gmail.com"
    , feedRoot        = "https://chshersh.com"
    }

type FeedRenderer =
    FeedConfiguration
    -> Context String
    -> [Item String]
    -> Compiler (Item String)

feedContext :: Context String
feedContext = postContext [] <> bodyField "description"

feedCompiler :: FeedRenderer -> Compiler (Item String)
feedCompiler renderer = loadAllSnapshots "posts/*" "content"
    >>= fmap (take 10) . recentFirst
    >>= renderer feedConfiguration feedContext
