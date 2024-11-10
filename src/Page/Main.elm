module Page.Main exposing (..)

import Element exposing (..)
import Element.Events exposing (..)
import Element.Font as Font
import Msg exposing (..)
import View.Element exposing (..)
import View.SayMyName as Logo


page : Element Msg
page =
    column [ centerX, centerY ] [ logo, title ]


logo : Element Msg
logo =
    column [] (List.map t_ Logo.youGoddamnRight)


title : Element Msg
title =
    column [ centerX, Font.size 24 ]
        [ t [ centerX ] "Dmitrii Kovanikov"
        , t [ centerX ] "Senior Software Engineer @ Bloomberg"
        ]
