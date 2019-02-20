{-# LANGUAGE TupleSections    #-}
{-# LANGUAGE TypeApplications #-}

module Chshersh.Main
       ( main
       ) where

import Hakyll (applyAsTemplate, compile, compressCss, compressCssCompiler, constRoute,
               copyFileCompiler, create, defaultContext, hakyll, idRoute, makeItem, match, route,
               templateBodyCompiler, (.||.))
import Hakyll.Web.Sass (sassCompiler)

import Chshersh.Posts (postsContextCompiler, postsRules)
import Chshersh.Social (socialContext)


main :: IO ()
main =  hakyll $ do
    match ("images/*" .||. "fonts/**" .||. "js/*" .||. "files/*") $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "scss/resume.scss" $ do
        route $ constRoute "css/resume.css"
        let compressCssItem = fmap compressCss
        compile (compressCssItem <$> sassCompiler)

    postsRules

    -- Main page
    create ["index.html"] $ do
        route idRoute
        compile $ do
            postsCtx <- postsContextCompiler
            let ctx = defaultContext
                   <> socialContext
                   <> postsCtx

            makeItem ""
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/index.html" ctx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

--     -- Posts pages
--     match "posts/*" $ do
--         route $ setExtension "html"
--         compile $ do
--             i   <- getResourceString
--             pandoc <- renderPandocWith defaultHakyllReaderOptions withToc i
--             let toc = itemBody pandoc
--             tgs <- getTags (itemIdentifier i)
--             let postTagsCtx = postCtxWithTags tgs <> constField "toc" toc
--             pandocCompiler
--                 >>= loadAndApplyTemplate "templates/post.html" postTagsCtx
--                 >>= loadAndApplyTemplate "templates/posts-default.html" postTagsCtx
--                 >>= relativizeUrls
--
--     -- All posts page
--     create ["posts.html"] $ compilePosts "Posts" "templates/posts.html" "posts/*"
--
--     -- build up tags
--     tags <- buildTags "posts/*" (fromCapture "tags/*.html")
--
--     tagsRules tags $ \tag ptrn -> do
--         let title = "Posts tagged \"" ++ tag ++ "\""
--         compilePosts title "templates/tag.html" ptrn
--
--
--     ----------------------------------------------------------------------------
--     -- Project pages
--     ----------------------------------------------------------------------------
--     match "projects/*" $ do
--         route $ setExtension "html"
--         compile $ pandocCompiler
--             >>= loadAndApplyTemplate "templates/readme.html" defaultContext
--             >>= loadAndApplyTemplate "templates/posts-default.html" defaultContext
--             >>= relativizeUrls
--
--     -- All projects page
--     create ["projects.html"] $ compileProjects "Projects" "templates/readmes.html" "projects/*"
--
--
--     -- Render the 404 page, we don't relativize URL's here.
--     create ["404.html"] $ do
--         route idRoute
--         compile $ makeItem ""
--             >>= applyAsTemplate defaultContext
--             >>= loadAndApplyTemplate "templates/404.html" defaultContext
--
--
-- -- | Compose TOC from the markdown.
-- withToc :: WriterOptions
-- withToc = defaultHakyllWriterOptions
--     { writerTableOfContents = True
--     , writerTOCDepth = 4
--     , writerTemplate = Just "$toc$"
--     }
--
-- compilePosts :: String -> Identifier -> Pattern -> Rules ()
-- compilePosts title page pat = do
--     route idRoute
--     compile $ do
--         posts <- recentFirst =<< loadAll pat
--         let ids = map itemIdentifier posts
--         tagsList <- ordNub . concat <$> traverse getTags ids
--         let ctx = postCtxWithTags tagsList
--                <> constField "title" title
--                <> constField "description" "Kowainik blog"
--                <> listField "posts" postCtx (return posts)
--                <> defaultContext
--
--         makeItem ""
--             >>= loadAndApplyTemplate page ctx
--             >>= loadAndApplyTemplate "templates/posts-default.html" ctx
--             >>= relativizeUrls
--
-- compileProjects :: String -> Identifier -> Pattern -> Rules ()
-- compileProjects title page pat = do
--     route idRoute
--     compile $ do
--         projects <- moreStarsFirst =<< loadAll pat
--         let projectsCtx = stripExtension <> defaultContext
--         let ctx = constField "title" title
--                <> constField "description" "Kowainik projects"
--                <> listField "readmes" projectsCtx (pure projects)
--                <> projectsCtx
--
--         makeItem ""
--             >>= loadAndApplyTemplate page ctx
--             >>= loadAndApplyTemplate "templates/posts-default.html" ctx
--             >>= relativizeUrls
--   where
--     moreStarsFirst :: MonadMetadata m => [Item a] -> m [Item a]
--     moreStarsFirst = sortByM $ getItemStars . itemIdentifier
--       where
--         sortByM :: (Monad m, Ord k) => (a -> m k) -> [a] -> m [a]
--         sortByM f xs = map fst . sortBy (flip $ comparing snd) <$>
--             mapM (\x -> (x,) <$> f x) xs
--
--     getItemStars
--         :: MonadMetadata m
--         => Identifier    -- ^ Input page
--         -> m Int         -- ^ Parsed GitHub Stars
--     getItemStars id' = do
--         metadata <- getMetadata id'
--         let mbStar = lookupString "stars" metadata >>= readMaybe @Int
--
--         maybe starError pure mbStar
--       where
--         starError = error "Couldn't parse stars"
--
--
