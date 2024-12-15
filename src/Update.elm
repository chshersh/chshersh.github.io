port module Update exposing (..)

import Browser
import Browser.Navigation as Nav
import Dict
import Element exposing (classifyDevice)
import Model exposing (Model)
import Model.Dimensions exposing (Dimensions)
import Model.Info exposing (Info)
import Model.Key as Key
import Model.Msg exposing (Msg(..))
import Model.Route exposing (toRoute)
import Model.Social as Social
import Url


port newTab : String -> Cmd msg


selected : Model -> Info -> ( Model, Cmd Msg )
selected model info =
    ( { model | info = info }
    , Cmd.none
    )


linkClicked : Model -> Browser.UrlRequest -> ( Model, Cmd Msg )
linkClicked model urlRequest =
    case urlRequest of
        Browser.Internal url ->
            ( model, Nav.load (Url.toString url) )

        Browser.External href ->
            ( model, Nav.load href )


urlChanged : Model -> Url.Url -> ( Model, Cmd Msg )
urlChanged model url =
    ( { model | route = toRoute url }
    , Cmd.none
    )


keyPressed : Model -> String -> ( Model, Cmd Msg )
keyPressed model key =
    let
        parsedKey =
            Key.parseKey key

        nextState =
            Key.handleKey model.keyState parsedKey

        nextCmd =
            case nextState of
                Key.GoGo gg ->
                    case Dict.get gg Social.socials of
                        Nothing ->
                            Cmd.none

                        Just social ->
                            newTab social.url

                _ ->
                    Cmd.none
    in
    ( { model | keyState = nextState }
    , nextCmd
    )


setScreenSize : Model -> Dimensions -> ( Model, Cmd Msg )
setScreenSize model dimensions =
    let
        device =
            classifyDevice dimensions

        newModel =
            { model | device = device }
    in
    ( newModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Selected info ->
            selected model info

        LinkClicked urlRequest ->
            linkClicked model urlRequest

        UrlChanged url ->
            urlChanged model url

        KeyPressed key ->
            keyPressed model key

        SetScreenSize dimensions ->
            setScreenSize model dimensions
