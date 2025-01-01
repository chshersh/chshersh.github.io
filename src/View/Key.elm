module View.Key exposing (..)

import Element exposing (..)
import Element.Font as Font
import Model exposing (Model)
import Model.Info exposing (Info(..), showInfo)
import Model.Key exposing (KeyState(..))
import Model.Social as Social
import View.Color as Color
import View.Element exposing (..)


viewSocial : Model -> Social.T -> Element msg
viewSocial model social =
    let
        gg attrs =
            mono (Font.size 16 :: attrs)

        y =
            gg [ Font.color Color.yellow ]

        w =
            gg [ Font.color Color.suvaGrey ]

        r =
            row [ centerX ]

        plain =
            w ("gg" ++ String.fromChar social.gg)
    in
    case model.keyState of
        Start ->
            r [ plain ]

        Go _ ->
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


viewInfo : Model -> Info -> Element msg
viewInfo model info =
    let
        infoEl =
            t [ alignLeft ] <| showInfo info

        infoChar =
            case info of
                About ->
                    "a"

                Blog ->
                    "b"

        gEl =
            tSecondary [ alignRight ] ("g" ++ infoChar)

        buttonRow =
            row [ spacing 30, width fill ]

        plainRow =
            buttonRow [ infoEl, gEl ]

        y =
            mono [ Font.color Color.yellow ]
    in
    case model.keyState of
        Start ->
            plainRow

        Go goInfo ->
            if info == goInfo then
                buttonRow [ infoEl, row [ alignRight ] [ y ("g" ++ infoChar) ] ]

            else
                plainRow

        G ->
            buttonRow [ infoEl, row [ alignRight ] [ y "g", tSecondary [] infoChar ] ]

        GG ->
            plainRow

        GoGo _ ->
            plainRow
