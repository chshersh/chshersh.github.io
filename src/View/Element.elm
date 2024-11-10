-- Custom elements


module View.Element exposing (..)

import Element exposing (Element, el)
import Element.Font as Font
import View.Color exposing (..)
import View.Font exposing (monoFont)


t : List (Element.Attribute msg) -> String -> Element msg
t attrs s =
    let
        customAttrs =
            [ Font.family monoFont, Font.color gainsboro ]
    in
    el (customAttrs ++ attrs) (Element.text s)


t_ : String -> Element msg
t_ =
    t []
