module Website.Posts
       ( postsRules
       , postsContextCompiler
       , postContext
       ) where

import Hakyll (Compiler, Context, Item (..), Rules, compile, composeRoutes, constField, constRoute,
               dateField, defaultContext, defaultHakyllReaderOptions, defaultHakyllWriterOptions,
               field, functionField, getResourceString, getTags, idRoute, listField, loadAll,
               loadAndApplyTemplate, makeItem, match, metadataRoute, pandocCompilerWithTransformM,
               recentFirst, relativizeUrls, renderPandocWith, route, saveSnapshot, setExtension,
               unsafeCompiler)
import Hakyll.Core.Metadata (MonadMetadata (..), lookupString)
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
    posts <- loadAll "posts/*" >>= filterM isPost >>= recentFirst
    pure $ listField "posts" (postContext []) (pure posts)
  where
    isPost :: Item a -> Compiler Bool
    isPost postItem = do
        metadata <- getMetadata $ itemIdentifier postItem
        pure $ case lookupString "title" metadata of
            Nothing                       -> True
            Just "Haskell Revitalisation" -> False
            Just _other                   -> True

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
