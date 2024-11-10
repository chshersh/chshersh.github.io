module Main exposing (..)

import Element exposing (layout)
import Element.Background as Background
import Html exposing (Html)
import Msg exposing (Msg)
import Page.Main as Main
import View.Color as Color
import View.Element exposing (..)


main : Html Msg
main =
    layout [ Background.color Color.darkGrey ] <| Main.page
