port module Update exposing (..)

import Array
import Browser
import Browser.Navigation as Nav
import Dict
import Element exposing (classifyDevice)
import Html exposing (article)
import Model exposing (Model)
import Model.Blog exposing (articlesArr, mkPath, totalArticles)
import Model.Dimensions exposing (Dimensions)
import Model.Info exposing (Info(..), getButtonId)
import Model.Key as Key
import Model.Msg exposing (Msg(..))
import Model.Route exposing (toRoute)
import Model.Social as Social
import Url


port newTab : String -> Cmd msg


port focusButton : String -> Cmd msg


port scrollElement : { id : String, delta : Int } -> Cmd msg


port scrollToElement : String -> Cmd msg


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


handleScroll : Model -> Key.Key -> ( Model, Cmd Msg )
handleScroll initialModel key =
    let
        scrollState =
            Key.parseScrollState key

        model =
            { initialModel | scrollState = scrollState }
    in
    case model.info of
        About ->
            case scrollState of
                Key.NoScroll ->
                    ( model, Cmd.none )

                Key.ScrollDown ->
                    ( model, scrollElement { id = "scrollable-info", delta = 50 } )

                Key.ScrollUp ->
                    ( model, scrollElement { id = "scrollable-info", delta = -50 } )

        Blog ->
            let
                increment =
                    case scrollState of
                        Key.NoScroll ->
                            0

                        Key.ScrollDown ->
                            1

                        Key.ScrollUp ->
                            -1

                newBlogPosition =
                    modBy totalArticles (model.blogPosition + increment + totalArticles)

                articleId =
                    "article-" ++ String.fromInt newBlogPosition
            in
            ( { model | blogPosition = newBlogPosition }, scrollToElement articleId )


loadArticle : Model -> Key.Key -> Cmd Msg
loadArticle model key =
    let
        loadArticleAt i =
            case Array.get i articlesArr of
                Nothing ->
                    Cmd.none

                Just article ->
                    Nav.load (mkPath article)
    in
    case model.info of
        About ->
            Cmd.none

        Blog ->
            case key of
                Key.Enter ->
                    loadArticleAt model.blogPosition

                Key.Letter 'l' ->
                    loadArticleAt model.blogPosition

                _ ->
                    Cmd.none


keyPressed : Model -> String -> ( Model, Cmd Msg )
keyPressed initialModel key =
    let
        parsedKey =
            Key.parseKey key

        ( model, scrollCmd ) =
            handleScroll initialModel parsedKey

        nextState =
            Key.handleKeyState model.keyState parsedKey

        info =
            case nextState of
                Key.Go newInfo ->
                    newInfo

                _ ->
                    model.info

        nextCmd =
            case nextState of
                Key.Go About ->
                    focusButton (getButtonId About)

                Key.Go Blog ->
                    Cmd.batch
                        [ focusButton (getButtonId Blog)
                        , scrollToElement ("article-" ++ String.fromInt model.blogPosition)
                        ]

                Key.GoGo gg ->
                    case Dict.get gg Social.socials of
                        Nothing ->
                            Cmd.none

                        Just social ->
                            newTab social.url

                _ ->
                    Cmd.none

        goToArticleCmd =
            loadArticle model parsedKey

        finalCmd =
            Cmd.batch [ nextCmd, scrollCmd, goToArticleCmd ]
    in
    ( { model
        | keyState = nextState
        , info = info
      }
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
