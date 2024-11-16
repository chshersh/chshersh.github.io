module Model.Msg exposing (..)

import Model.Dimensions exposing (Dimensions)
import Time


type Msg
    = SetScreenSize Dimensions
    | AnimationTick Time.Posix
    | Drop
    | AboutClicked
