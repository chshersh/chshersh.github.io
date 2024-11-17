module Model exposing (..)

import Element exposing (Device)
import Model.Info exposing (Info)


type alias Model =
    { device : Device
    , info : Info
    }
