module View.Code exposing (..)

import Element exposing (..)
import Element.Background as Background
import View.Color as Color
import View.Element exposing (tSecondary)


code : List (Element msg) -> Element msg
code items =
    let
        last =
            List.length items + 1

        maxLen =
            String.length <| String.fromInt last
    in
    column
        [ width fill
        , height fill
        , Background.color Color.elevatedGrey
        , padding 10
        , spacing 5
        ]
        (List.indexedMap (toLine maxLen) items)


toLine : Int -> Int -> Element msg -> Element msg
toLine maxLen i item =
    row [ spacing 15 ]
        [ tSecondary [] <| String.padLeft maxLen ' ' <| String.fromInt (i + 1)
        , item
        ]
