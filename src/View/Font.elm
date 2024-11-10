module View.Font exposing (..)

import Element.Font as Font exposing (Font)


{-| Font for the code
-}
monoFont : List Font
monoFont =
    [ Font.external
        { name = "JetBrains Mono"
        , url = "https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap"
        }
    ]
