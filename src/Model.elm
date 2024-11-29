module Model exposing (..)

import Browser.Navigation as Nav
import Element exposing (Device)
import Model.Info exposing (Info)
import Model.Route exposing (Route)


type alias Model =
    { device : Device
    , info : Info
    , key : Nav.Key
    , route : Route
    }
