module Page.Layout exposing (..)

import Element exposing (..)
import FontAwesome.Styles
import Model exposing (Model)
import Model.Msg exposing (Msg)
import Page.Main exposing (..)


desktop : Model -> Element Msg
desktop model =
    column
        [ centerX, width fill, height fill, spacing 50, scrollbarY ]
        [ html FontAwesome.Styles.css
        , column [ height (fillPortion 4), centerX, width fill, spacing 30 ]
            [ logo 20
            , title 24
            , linksRow
                [ gitHub, youTube, x, twitch, blueSky, linkedIn, email ]
            ]
        , menu model
        ]


phone : Model -> Element Msg
phone _ =
    column
        [ centerX, centerY, spacing 20 ]
        [ html FontAwesome.Styles.css
        , logo 8
        , title 12
        , column [ centerX, spacing 10 ]
            [ linksRow [ gitHub, youTube, x, twitch ]
            , linksRow [ blueSky, linkedIn, email ]
            ]
        ]
