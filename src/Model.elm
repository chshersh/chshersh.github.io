module Model exposing (..)

import Animator
import Element exposing (Device)


type State
    = Default
    | About
    | Experience
    | Projects
    | Blog


type alias Model =
    { device : Device
    , timeline : Animator.Timeline State
    }
