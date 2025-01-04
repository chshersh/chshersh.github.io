port module Update exposing (..)

import Browser
import Browser.Navigation as Nav
import Dict
import Element exposing (classifyDevice)
import Model exposing (Model)
import Model.Dimensions exposing (Dimensions)
import Model.Info exposing (Info, getButtonId)
import Model.Key as Key
import Model.Msg exposing (Msg(..))
import Model.Route exposing (toRoute)
import Model.Social as Social
import Url


port newTab : String -> Cmd msg


port focusButton : String -> Cmd msg


port scrollElement : { id : String, delta : Int } -> Cmd msg


selected : Model -> Info -> ( Model, Cmd Msg )
selected model info =
    ( { model | info = info, keyState = Key.Go info }
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


getScrollCmd : Model -> Key.Key -> Cmd Msg
getScrollCmd _ key =
    case key of
        Key.Letter 'j' ->
            scrollElement { id = "scrollable-info", delta = 50 }

        Key.Letter 'k' ->
            scrollElement { id = "scrollable-info", delta = -50 }

        _ ->
            Cmd.none


keyPressed : Model -> String -> ( Model, Cmd Msg )
keyPressed model key =
    let
        parsedKey =
            Key.parseKey key

        scrollCmd =
            getScrollCmd model parsedKey

        nextState =
            Key.handleKey model.keyState parsedKey

        info =
            case nextState of
                Key.Go newInfo ->
                    newInfo

                _ ->
                    model.info

        nextCmd =
            case nextState of
                Key.Go goToInfo ->
                    focusButton (getButtonId goToInfo)

                Key.GoGo gg ->
                    case Dict.get gg Social.socials of
                        Nothing ->
                            Cmd.none

                        Just social ->
                            newTab social.url

                _ ->
                    Cmd.none

        finalCmd =
            Cmd.batch [ nextCmd, scrollCmd ]
    in
    ( { model | keyState = nextState, info = info }
    , finalCmd
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
