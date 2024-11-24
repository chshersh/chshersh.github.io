module Page.Layout exposing (..)

import Element exposing (..)
import Element.Font as Font
import FontAwesome.Styles
import Model exposing (Model)
import Model.Msg exposing (Msg)
import Page.Main exposing (..)


bigDesktop : Model -> Element Msg
bigDesktop model =
    column
        [ centerX, width fill, height fill, spacing 50, scrollbarY ]
        [ html FontAwesome.Styles.css
        , column [ height (fillPortion 4), centerX, width fill, spacing 30 ]
            [ logo [ Font.size 20, alignBottom ]
            , title [ Font.size 24, alignBottom ]
            , linksRow
                [ alignBottom ]
                [ gitHub, youTube, x, twitch, blueSky, linkedIn, email ]
            ]
        , menu model
        ]


desktop : Model -> Element Msg
desktop model =
    column
        [ centerX, width fill, height fill, spacing 50, scrollbarY ]
        [ html FontAwesome.Styles.css
        , column [ height (fillPortion 4), centerX, width fill, spacing 30 ]
            [ logo [ Font.size 20 ]
            , title [ Font.size 24 ]
            , linksRow []
                [ gitHub, youTube, x, twitch, blueSky, linkedIn, email ]
            ]
        , menu model
        ]


phone : Model -> Element Msg
phone _ =
    column
        [ centerX, centerY, spacing 20 ]
        [ html FontAwesome.Styles.css
        , logo [ Font.size 8 ]
        , title [ Font.size 12 ]
        , column [ centerX, spacing 10 ]
            [ linksRow [] [ gitHub, youTube, x, twitch ]
            , linksRow [] [ blueSky, linkedIn, email ]
            ]
        ]
