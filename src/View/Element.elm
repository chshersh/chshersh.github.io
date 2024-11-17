-- Custom elements


module View.Element exposing (..)

import Element exposing (Element, el)
import Element.Font as Font
import View.Color exposing (..)
import View.Font exposing (monoFont)


mono : List (Element.Attribute msg) -> String -> Element msg
mono attrs s =
    el (Font.family monoFont :: attrs) (Element.text s)


t : List (Element.Attribute msg) -> String -> Element msg
t attrs =
    mono (Font.color gainsboro :: attrs)


tSecondary : List (Element.Attribute msg) -> String -> Element msg
tSecondary attrs =
    mono (Font.color suvaGrey :: attrs)


t_ : String -> Element msg
t_ =
    t []
