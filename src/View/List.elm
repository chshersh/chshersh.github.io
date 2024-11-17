module View.List exposing (..)

import Element exposing (..)
import Element.Font as Font
import View.Color exposing (yellow)
import View.Element exposing (..)


unorderedList : List (Element msg) -> List (Element msg)
unorderedList =
    List.map toUnorderedLine


toUnorderedLine : Element msg -> Element msg
toUnorderedLine item =
    row [ width fill ]
        [ t_ "  "
        , mono [ Font.color yellow ] "▪ "
        , item
        ]
