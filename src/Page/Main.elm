module Page.Main exposing (..)

import Element exposing (..)
import Element.Events exposing (..)
import Element.Font as Font
import FontAwesome as Icon exposing (Icon)
import FontAwesome.Styles
import Model.Link as Link
import Msg exposing (..)
import View.Color exposing (gainsboro)
import View.Element exposing (..)
import View.SayMyName as Logo


page : Element Msg
page =
    column [ centerX, centerY ] [ logo, title, links ]


edges : { top : Int, right : Int, bottom : Int, left : Int }
edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }


logo : Element Msg
logo =
    column [] (List.map t_ Logo.youGoddamnRight)


title : Element Msg
title =
    column [ centerX, Font.size 24, paddingEach { edges | top = 10 } ]
        [ t [ centerX ] "Dmitrii Kovanikov"
        , t [ centerX ] "Senior Software Engineer @ Bloomberg"
        ]


links : Element Msg
links =
    column [ centerX, Font.size 24, paddingEach { edges | top = 40 } ]
        (html FontAwesome.Styles.css :: List.map link Link.all)


link : Link.T -> Element Msg
link l =
    row [ paddingEach { edges | top = 15 } ]
        [ icon l.icon
        , t_ l.name
        ]


icon : Icon hasId -> Element msg
icon i =
    el [ Font.color gainsboro, paddingEach { edges | right = 10 } ] (html <| Icon.view i)
