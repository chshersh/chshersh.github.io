module Page.Main exposing (..)

import Element exposing (..)
import Element.Events exposing (..)
import Msg exposing (..)
import View.Element exposing (..)
import View.SayMyName as Logo


page : Element Msg
page =
    column [ centerX, centerY ] [ logo ]


logo : Element Msg
logo =
    column [] (List.map txt Logo.youGoddamnRight)
