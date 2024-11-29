module View exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Model exposing (Model)
import Model.Msg exposing (Msg)
import Page.Layout as Layout
import View.Color as Color


view : Model -> Browser.Document Msg
view model =
    let
        device =
            model.device

        responsiveLayout =
            case ( device.class, device.orientation ) of
                ( Phone, _ ) ->
                    phoneLayout

                ( Tablet, _ ) ->
                    tabletLayout

                ( Desktop, Portrait ) ->
                    tabletLayout

                ( Desktop, _ ) ->
                    desktopLayout

                ( BigDesktop, _ ) ->
                    bigDesktopLayout
    in
    { title = "Dmitrii Kovanikov @ chshersh"
    , body =
        [ layout
            [ Background.color Color.darkGrey, height fill, width fill ]
            (responsiveLayout model)
        ]
    }



-- LAYOUTS


phoneLayout : Model -> Element Msg
phoneLayout =
    Layout.phone


tabletLayout : Model -> Element Msg
tabletLayout =
    Layout.desktop


desktopLayout : Model -> Element Msg
desktopLayout =
    Layout.desktop


bigDesktopLayout : Model -> Element Msg
bigDesktopLayout =
    Layout.bigDesktop
