module Website.Main
       ( main
       ) where

import Hakyll (applyAsTemplate, compile, compressCss, compressCssCompiler, constRoute,
               copyFileCompiler, create, createRedirects, defaultContext, hakyll, idRoute,
               loadAndApplyTemplate, makeItem, match, relativizeUrls, route, templateBodyCompiler,
               (.||.))
import Hakyll.Web.Feed (renderAtom, renderRss)
import Hakyll.Web.Sass (sassCompiler)

import Website.Experience (mentorshipExperienceContext, workExperienceContext)
import Website.Feed (feedCompiler)
import Website.Posts (postsContextCompiler, postsRules)
import Website.Project (projectsContext)
import Website.Social (socialContext)

main :: IO ()
main =  hakyll $ do
    match ("images/**" .||. "fonts/**" .||. "js/*" .||. "files/*") $ do
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
    createRedirects  -- short-names for the old posts
        [ ("comonadic-builders.html", "posts/2019-03-25-comonadic-builders")
        , ("travis.html", "posts/2019-02-25-haskell-travis")
        ]

    -- Main page
    create ["index.html"] $ do
        route idRoute
        compile $ do
            postsCtx <- postsContextCompiler
            let ctx = defaultContext
                   <> workExperienceContext
                   <> mentorshipExperienceContext
                   <> projectsContext
                   <> socialContext
                   <> postsCtx

            makeItem ""
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/index.html" ctx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

    -- RSS feeds
    create ["atom.xml"] $ do
        route idRoute
        compile (feedCompiler renderAtom)


    create ["rss.xml"] $ do
        route idRoute
        compile (feedCompiler renderRss)
