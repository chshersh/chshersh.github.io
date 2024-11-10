-- Custom elements


module View.Element exposing (..)

import Element exposing (Element, el)
import Element.Font as Font
import View.Font exposing (monoFont)


txt : String -> Element msg
txt s =
    el [ Font.family monoFont ] (Element.text s)
