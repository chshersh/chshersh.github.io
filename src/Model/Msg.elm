module Model.Msg exposing (..)

import Browser
import Model.Dimensions exposing (Dimensions)
import Model.Info exposing (Info)
import Url


type
    Msg
    -- Resize events
    = SetScreenSize Dimensions
      -- Browser navigation events
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
      -- Custom messages
    | Selected Info