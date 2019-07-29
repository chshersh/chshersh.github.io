module Website.Posts
       ( postsRules
       , postsContextCompiler
       , externalPostsContext
       , postContext
       ) where

import Hakyll (compile, composeRoutes, constField, constRoute, dateField, defaultContext,
               defaultHakyllReaderOptions, defaultHakyllWriterOptions, functionField,
               getResourceString, getTags, idRoute, loadAll, match, metadataRoute, recentFirst,
               renderPandocWith, route, saveSnapshot, setExtension)
import Hakyll.Core.Metadata (lookupString)
import Hakyll.ShortcutLinks (allShortcutLinksCompiler)
import Text.Pandoc.Options (WriterOptions (..))

import Website.Social (socialContext)

import qualified Data.Text as T


postsRules :: Rules ()
postsRules = match "posts/*" $ do
    route $ metadataRoute $ \metadata ->
        let shortNameRoute = case lookupString "shortName" metadata of
                Nothing   -> idRoute
                Just name -> constRoute name
        in composeRoutes shortNameRoute (setExtension "html")

    compile $ do
        rawPost <- getResourceString
        tocItem <- renderPandocWith defaultHakyllReaderOptions withToc rawPost
        let toc  = itemBody tocItem
        tags    <- getTags (itemIdentifier rawPost)

        let ctx = mconcat
                [ postContext tags
                , socialContext
                , constField "toc" toc
                ]

        allShortcutLinksCompiler
            >>= loadAndApplyTemplate "templates/post.html" ctx
            >>= saveSnapshot "content"
            >>= relativizeUrls

withToc :: WriterOptions
withToc = defaultHakyllWriterOptions
    { writerTableOfContents = True
    , writerTOCDepth = 4
    , writerTemplate = Just "$toc$"
    }

postsContextCompiler :: Compiler (Context String)
postsContextCompiler = do
    posts <- recentFirst =<< loadAll "posts/*"
    pure $ listField "posts" (postContext []) (pure posts)

-- | Removes the @.html@ suffix in the post URLs.
stripHtmlContext :: Context a
stripHtmlContext = functionField "stripExtension" $ \args _ -> case args of
    [k] -> pure $ maybe k toString (T.stripSuffix ".html" $ toText k)
    _   -> error "relativizeUrl only needs a single argument"

-- Context to used for posts
postContext :: [String] -> Context String
postContext tags = mconcat
    [ listField "tagsList" (field "tag" $ pure . itemBody) (traverse makeItem tags)
    , stripHtmlContext
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
