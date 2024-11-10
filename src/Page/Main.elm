module Page.Main exposing (..)

import Element exposing (..)
import Element.Events exposing (..)
import Msg exposing (..)
import View.Element exposing (..)


page : Element Msg
page =
    el [ centerX, centerY ] (txt "chshersh")
