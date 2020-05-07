module Website.Posts
       ( postsRules
       , postsContextCompiler
       , externalPostsContext
       , postContext
       ) where

import Hakyll (compile, composeRoutes, constField, constRoute, dateField, defaultContext,
               defaultHakyllReaderOptions, defaultHakyllWriterOptions, functionField,
               getResourceString, getTags, idRoute, loadAll, match, metadataRoute,
               pandocCompilerWithTransformM, recentFirst, renderPandocWith, route, saveSnapshot,
               setExtension, unsafeCompiler)
import Hakyll.Core.Metadata (lookupString)
import Hakyll.ShortcutLinks (applyAllShortcuts)
import Text.Pandoc.Options (WriterOptions (..))
import Text.Pandoc.Templates (compileTemplate)

import Website.Social (socialContext)

import qualified Data.Text as T
import qualified Text.Pandoc as Pandoc
import qualified Text.Pandoc.Walk as Pandoc.Walk


postsRules :: Rules ()
postsRules = match "posts/*" $ do
    route $ metadataRoute $ \metadata ->
        let shortNameRoute = case lookupString "shortName" metadata of
                Nothing   -> idRoute
                Just name -> constRoute name
        in composeRoutes shortNameRoute (setExtension "html")

    compile $ do
        rawPost <- getResourceString
        tocWriter <- unsafeCompiler withToc
        tocItem <- renderPandocWith defaultHakyllReaderOptions tocWriter rawPost
        let toc  = itemBody tocItem
        tags    <- getTags (itemIdentifier rawPost)

        let ctx = mconcat
                [ postContext tags
                , socialContext
                , constField "toc" toc
                ]

        customPandocCompiler
            >>= loadAndApplyTemplate "templates/post.html" ctx
            >>= saveSnapshot "content"
            >>= relativizeUrls

-- | Compose TOC from the markdown.
withToc :: IO WriterOptions
withToc = compileTemplate "myToc.txt" "$toc$" >>= \case
    Left err -> error $ toText err
    Right template -> pure $ defaultHakyllWriterOptions
        { writerTableOfContents = True
        , writerTOCDepth = 4
        , writerTemplate = Just template
        }

{- | My own pandoc compiler which adds anchors automatically and uses
@hakyll-shortcut-links@ library for shortcut transformations.
-}
customPandocCompiler :: Compiler (Item String)
customPandocCompiler = pandocCompilerWithTransformM
    defaultHakyllReaderOptions
    defaultHakyllWriterOptions
    (applyAllShortcuts . makeLinks)

-- | Modifie a headers to make it a link.
makeLinks :: Pandoc.Pandoc -> Pandoc.Pandoc
makeLinks =
    Pandoc.Walk.walk headerToLink
  where
    headerToLink :: Pandoc.Block -> Pandoc.Block
    headerToLink (Pandoc.Header level attr@(id_, _, _) content) =
        Pandoc.Header level attr
            [Pandoc.Link ("", ["anchor"], []) content ("#" <> id_, "")]
    headerToLink block = block

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
