module Model exposing (..)

import Browser.Navigation as Nav
import Element exposing (Device)
import Model.Info exposing (Info)
import Url


type alias Model =
    { device : Device
    , info : Info
    , key : Nav.Key
    , url : Url.Url
    }
