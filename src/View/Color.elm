module View.Color exposing (..)

import Element exposing (Color, rgb255)


grey : Int -> Color
grey n =
    rgb255 n n n



-- | #121212


darkGrey : Color
darkGrey =
    grey 18



-- | #1E1E1E


elevatedGrey : Color
elevatedGrey =
    grey 30



-- | #E2E2E2


gainsboro : Color
gainsboro =
    grey 226



-- | #FFC107


yellow : Color
yellow =
    rgb255 255 193 7
