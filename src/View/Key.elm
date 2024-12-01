module View.Key exposing (..)

import Element exposing (..)
import Element.Font as Font
import Model exposing (Model)
import Model.Key exposing (KeyState(..))
import Model.Social as Social
import View.Color as Color
import View.Element exposing (..)


gg : List (Attribute msg) -> String -> Element msg
gg attrs =
    mono (Font.size 16 :: attrs)


y : String -> Element msg
y =
    gg [ Font.color Color.yellow ]


w : String -> Element msg
w =
    gg [ Font.color Color.gainsboro ]


r : List (Element msg) -> Element msg
r =
    row [ centerX ]


viewSocial : Model -> Social.T -> Element msg
viewSocial model social =
    let
        plain =
            w ("gg" ++ String.fromChar social.gg)
    in
    case model.keyState of
        Start ->
            r [ plain ]

        G ->
            r [ y "g", w (String.fromList [ 'g', social.gg ]) ]

        GG ->
            r [ y "gg", w (String.fromChar social.gg) ]

        GoGo ggLetter ->
            if social.gg == ggLetter then
                r [ y ("gg" ++ String.fromChar social.gg) ]

            else
                r [ plain ]
