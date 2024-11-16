module View exposing (..)

import Element exposing (..)
import Element.Background as Background
import Html exposing (Html)
import Model exposing (Model)
import Model.Msg exposing (Msg)
import Page.Main exposing (page)
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
    page
        { logoFontSize = 8
        , titleFontSize = 12
        }


tabletLayout : Element Msg
tabletLayout =
    page
        { logoFontSize = 20
        , titleFontSize = 24
        }


desktopLayout : Element Msg
desktopLayout =
    page
        { logoFontSize = 20
        , titleFontSize = 24
        }


bigDesktopLayout : Element Msg
bigDesktopLayout =
    page
        { logoFontSize = 20
        , titleFontSize = 24
        }
