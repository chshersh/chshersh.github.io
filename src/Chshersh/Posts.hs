module Chshersh.Posts
       ( postsRules
       , postsContextCompiler
       ) where

import Hakyll (compile, dateField, defaultContext, functionField, listField, loadAll, match,
               pandocCompiler, recentFirst, route, setExtension)

import Chshersh.Social (socialContext)

import qualified Data.Text as T


postsRules :: Rules ()
postsRules = match "posts/*" $ do
    route $ setExtension "html"
    compile $ do
        let ctx = postContext <> socialContext
        pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html" ctx
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

--
-- postCtxWithTags :: [String] -> Context String
-- postCtxWithTags tags =
--     listField "tagsList" (field "tag" $ pure . itemBody) (traverse makeItem tags)
--     <> postCtx
