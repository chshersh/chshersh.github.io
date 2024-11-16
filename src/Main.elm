module Main exposing (..)

import Browser
import Browser.Events as Events
import Element exposing (classifyDevice)
import Model exposing (Model)
import Model.Dimensions exposing (Dimensions)
import Model.Msg exposing (Msg(..))
import View exposing (view)



-- MAIN


main : Program Dimensions Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


init : Dimensions -> ( Model, Cmd Msg )
init dimensions =
    let
        device =
            classifyDevice dimensions
    in
    let
        model =
            { device = device }
    in
    ( model
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        SetScreenSize dimensions ->
            let
                device =
                    classifyDevice dimensions
            in
            let
                model =
                    { device = device }
            in
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ Events.onResize (\w h -> SetScreenSize { width = w, height = h }) ]
