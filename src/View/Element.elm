-- Custom elements


module View.Element exposing (..)

import Element exposing (Element, el)
import Element.Font as Font
import View.Font exposing (monoFont)
import View.Color exposing (..)


txt : String -> Element msg
txt s =
    el [ Font.family monoFont, Font.color gainsboro ] (Element.text s)
