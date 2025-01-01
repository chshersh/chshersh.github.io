module View.Key exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button)
import Html.Attributes
import Model exposing (Model)
import Model.Info exposing (Info(..), getButtonId, showInfo)
import Model.Key exposing (KeyState(..))
import Model.Msg exposing (Msg(..))
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
            mono [ alignLeft ] <| showInfo info

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


menuButton : Info -> Element Msg -> Element Msg
menuButton info labelEl =
    button
        [ centerX
        , width fill
        , Font.size 20
        , paddingEach { top = 5, bottom = 5, left = 15, right = 15 }
        , Border.rounded 16
        , Border.solid
        , Border.width 2
        , Border.color Color.darkGrey
        , Background.color Color.elevatedGrey
        , Font.color Color.gainsboro
        , mouseOver [ Background.color Color.yellow, Font.color Color.elevatedGrey ]
        , focused [ Border.color Color.blue ]
        , htmlAttribute <| Html.Attributes.id <| getButtonId info
        ]
        { onPress = Just (Selected info)
        , label = labelEl
        }


viewButton : Model -> Info -> Element Msg
viewButton model info =
    let
        menuLabelEl =
            viewInfo model info
    in
    menuButton info menuLabelEl
