module Page.Main exposing (..)

import Animator
import Color as ElmColor
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input exposing (button)
import FontAwesome as Icon exposing (Icon)
import FontAwesome.Styles
import Model exposing (Model, State(..))
import Model.Msg exposing (Msg(..))
import Model.Social as Social
import View.Color as Color
import View.Element exposing (..)
import View.Font exposing (monoFont)
import View.SayMyName as Logo


pageDefault : Model -> Element Msg
pageDefault model =
    column
        [ centerX, centerY, spacing 40 ]
        [ html FontAwesome.Styles.css
        , logo 20
        , title 24
        , linksRow
            [ gitHub, youTube, x, twitch, blueSky, linkedIn, email ]
        , menu model
        ]


pagePhone : Model -> Element Msg
pagePhone _ =
    column
        [ centerX, centerY, spacing 20 ]
        [ html FontAwesome.Styles.css
        , logo 8
        , title 12
        , column [ centerX, spacing 10 ]
            [ linksRow [ gitHub, youTube, x, twitch ]
            , linksRow [ blueSky, linkedIn, email ]
            ]
        ]


edges : { top : Int, right : Int, bottom : Int, left : Int }
edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }


logo : Int -> Element Msg
logo logoFontSize =
    column
        [ centerX, Font.size logoFontSize ]
        (List.map t_ Logo.youGoddamnRight)


title : Int -> Element Msg
title titleFontSize =
    column
        [ centerX
        , Font.size titleFontSize
        , padding 10
        , Background.color Color.elevatedGrey
        ]
        [ t [ centerX ] "Dmitrii Kovanikov"
        , t [ centerX ] "Senior Software Engineer @ Bloomberg"
        ]


linksRow : List (Element Msg) -> Element Msg
linksRow =
    row [ centerX, Font.size 24, spacing 10 ]


gitHub : Element Msg
gitHub =
    social Social.gitHub


youTube : Element Msg
youTube =
    social Social.youTube


x : Element Msg
x =
    social Social.x


twitch : Element Msg
twitch =
    social Social.twitch


blueSky : Element Msg
blueSky =
    social Social.blueSky


linkedIn : Element Msg
linkedIn =
    social Social.linkedIn


email : Element Msg
email =
    social Social.email


social : Social.T -> Element Msg
social s =
    newTabLink
        [ paddingEach { top = 10, left = 10, right = 10, bottom = 10 }
        , width fill
        , Background.color Color.elevatedGrey
        , Font.color Color.gainsboro
        , Border.rounded 4
        , mouseOver [ Background.color Color.yellow, Font.color Color.elevatedGrey ]
        ]
        { url = s.url, label = icon s.icon }


icon : Icon hasId -> Element msg
icon i =
    el [] (html <| Icon.view i)


menu : Model -> Element Msg
menu model =
    column [ centerX, spacing 10 ]
        [ menuButton model (Just AboutClicked) "About"

        -- , menuButton Nothing "Experience"
        -- , menuButton Nothing "Projects"
        -- , menuButton Nothing "Blog"
        ]


menuButton : Model -> Maybe Msg -> String -> Element Msg
menuButton model onPress label =
    let
        bgColor =
            fromRgb <|
                ElmColor.toRgba <|
                    Animator.color model.timeline <|
                        \state ->
                            if state == Default then
                                ElmColor.black

                            else
                                ElmColor.white
    in
    button
        [ centerX
        , width fill
        , Font.size 20
        , padding 10
        , Border.rounded 16
        , Background.color bgColor
        , Font.color Color.gainsboro
        , mouseOver [ Background.color Color.yellow, Font.color Color.elevatedGrey ]
        , onLoseFocus Drop
        ]
        { onPress = onPress
        , label = el [ Font.family monoFont, centerX ] (text label)
        }
