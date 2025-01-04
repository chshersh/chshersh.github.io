module Model.Blog exposing (..)

import Array
import Model.Blog.Data as Blog


type alias T =
    Blog.Article


mkPath : T -> String
mkPath article =
    "/blog/" ++ article.path ++ ".html"


mkArticleId : Int -> String
mkArticleId i =
    "article-" ++ String.fromInt i


totalArticles : Int
totalArticles =
    List.length articles


articlesArr : Array.Array T
articlesArr =
    Array.fromList articles


articles : List T
articles =
    Blog.articles
