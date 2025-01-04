module Main exposing (..)

import Browser
import Browser.Events as Events
import Browser.Navigation as Nav
import Element exposing (classifyDevice)
import Json.Decode as Decode exposing (Decoder)
import Model exposing (Model)
import Model.Dimensions exposing (Dimensions)
import Model.Info exposing (Info(..))
import Model.Key exposing (KeyState(..), ScrollState(..))
import Model.Msg exposing (Msg(..))
import Model.Route exposing (Route(..), toRoute)
import Update exposing (update)
import Url
import View exposing (view)



-- MAIN


main : Program Dimensions Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


init : Dimensions -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init dimensions url key =
    let
        device =
            classifyDevice dimensions

        model =
            { device = device
            , info = About
            , key = key
            , route = toRoute url
            , keyState = Start
            , scrollState = NoScroll
            , blogPosition = 0
            }
    in
    ( model
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Events.onResize (\w h -> SetScreenSize { width = w, height = h })
        , Events.onKeyDown (Decode.map KeyPressed keyDecoder)
        ]


keyDecoder : Decoder String
keyDecoder =
    Decode.field "key" Decode.string
