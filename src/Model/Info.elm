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
