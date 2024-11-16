module View exposing (..)

import Element exposing (..)
import Element.Background as Background
import Html exposing (Html)
import Model exposing (Model)
import Model.Msg exposing (Msg)
import Page.Main exposing (pageDefault, pagePhone)
import View.Color as Color


view : Model -> Html Msg
view model =
    let
        device =
            model.device
    in
    let
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
    layout [ Background.color Color.darkGrey, height fill, width fill ] responsiveLayout



-- LAYOUTS


phoneLayout : Element Msg
phoneLayout =
    pagePhone


tabletLayout : Element Msg
tabletLayout =
    pageDefault


desktopLayout : Element Msg
desktopLayout =
    pageDefault


bigDesktopLayout : Element Msg
bigDesktopLayout =
    pageDefault
