module Main exposing (..)

import Browser
import Browser.Events as Events
import Browser.Navigation as Nav
import Element exposing (classifyDevice)
import Model exposing (Model)
import Model.Dimensions exposing (Dimensions)
import Model.Info exposing (Info(..))
import Model.Msg exposing (Msg(..))
import Model.Route exposing (Route(..), toRoute)
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
            }
    in
    ( model
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Selected info ->
            ( { model | info = info }
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | route = toRoute url }
            , Cmd.none
            )

        SetScreenSize dimensions ->
            let
                device =
                    classifyDevice dimensions

                newModel =
                    { model | device = device }
            in
            ( newModel, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Events.onResize (\w h -> SetScreenSize { width = w, height = h })
        ]
