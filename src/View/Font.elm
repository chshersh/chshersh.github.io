module View.Font exposing (..)

import Element.Font as Font exposing (Font)


monoFont : List Font
monoFont =
    [ Font.monospace
    , Font.external
        { name = "Noto Sans Mono"
        , url = "https://fonts.googleapis.com/css2?family=Inconsolata:wght@200..900&family=Noto+Sans+Mono&display=swap"
        }
    ]
