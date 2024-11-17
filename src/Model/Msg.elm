module Model.Msg exposing (..)

import Model.Dimensions exposing (Dimensions)
import Model.Info exposing (Info)


type Msg
    = SetScreenSize Dimensions
    | Selected Info
