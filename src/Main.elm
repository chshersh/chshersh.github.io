module Main exposing (..)

import Animator
import Browser
import Browser.Events as Events
import Element exposing (classifyDevice)
import Model exposing (Model, State(..))
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

        model =
            { device = device
            , timeline = Animator.init Default
            }
    in
    ( model
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AnimationTick newTime ->
            ( Animator.update newTime animator model
            , Cmd.none
            )

        Drop ->
            ( { model
                | timeline = Animator.go Animator.quickly Default model.timeline
              }
            , Cmd.none
            )

        AboutClicked ->
            ( { model
                | timeline = Animator.go Animator.quickly About model.timeline
              }
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
subscriptions model =
    Sub.batch
        [ Events.onResize (\w h -> SetScreenSize { width = w, height = h })
        , Animator.toSubscription AnimationTick model animator
        ]



-- ANIMATOR


animator : Animator.Animator Model
animator =
    Animator.animator
        |> Animator.watchingWith
            .timeline
            (\newTimeline model ->
                { model | timeline = newTimeline }
            )
            (\state -> state /= Default)
