module Page.Main exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import FontAwesome as Icon exposing (Icon)
import FontAwesome.Styles
import Model.Msg exposing (Msg)
import Model.Social as Social
import View.Color as Color
import View.Element exposing (..)
import View.SayMyName as Logo


page : Int -> Element Msg
page logoFontSize =
    column [ centerX, centerY, spacing 40 ]
        [ html FontAwesome.Styles.css
        , logo logoFontSize
        , title
        , links
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
    let
        toLogoLine =
            t [ Font.size logoFontSize ]
    in
    column [] (List.map toLogoLine Logo.youGoddamnRight)


title : Element Msg
title =
    column
        [ centerX
        , Font.size 24
        , padding 10
        , Background.color Color.elevatedGrey
        ]
        [ t [ centerX ] "Dmitrii Kovanikov"
        , t [ centerX ] "Senior Software Engineer @ Bloomberg"
        ]


links : Element Msg
links =
    row
        [ centerX
        , Font.size 24
        , spacing 10
        ]
        (List.map social Social.all)


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
