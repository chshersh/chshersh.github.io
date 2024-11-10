module Main exposing (..)

import Element exposing (layout)
import Html exposing (Html)
import Msg exposing (Msg)
import Page.Main as Main


main : Html Msg
main =
    layout [] <| Main.page
