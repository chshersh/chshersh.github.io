module Model.Info exposing (..)

import FontAwesome.Solid exposing (info)


type Info
    = About
    | Blog


showInfo : Info -> String
showInfo info =
    case info of
        About ->
            "About"

        Blog ->
            "Blog"


getButtonId : Info -> String
getButtonId info =
    case info of
        About ->
            "button-about"

        Blog ->
            "button-blog"
