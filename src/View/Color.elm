module View.Color exposing (..)

import Element exposing (Color, rgb255)


grey : Int -> Color
grey n =
    rgb255 n n n


darkGrey : Color
darkGrey =
    grey 18


elevatedGrey : Color
elevatedGrey =
    grey 30


suvaGrey : Color
suvaGrey =
    grey 145


gainsboro : Color
gainsboro =
    grey 226


yellow : Color
yellow =
    rgb255 255 193 7
