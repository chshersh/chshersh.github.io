module Page.Main exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input exposing (button)
import FontAwesome as Icon exposing (Icon)
import FontAwesome.Styles
import Model exposing (Model)
import Model.Info exposing (Info(..), showInfo)
import Model.Msg exposing (Msg(..))
import Model.Social as Social
import View.Code exposing (code)
import View.Color as Color
import View.Element exposing (..)
import View.Font exposing (monoFont)
import View.List exposing (unorderedList)
import View.SayMyName as Logo


pageDefault : Model -> Element Msg
pageDefault model =
    column
        [ centerX, width fill, height fill, spacing 50 ]
        [ html FontAwesome.Styles.css
        , column [ height (fillPortion 3), centerX, width fill, spacing 30 ]
            [ logo 20
            , title 24
            , linksRow
                [ gitHub, youTube, x, twitch, blueSky, linkedIn, email ]
            ]
        , menu model
        ]


pagePhone : Model -> Element Msg
pagePhone _ =
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


edges : { top : Int, right : Int, bottom : Int, left : Int }
edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }


logo : Int -> Element Msg
logo logoFontSize =
    column
        [ centerX, Font.size logoFontSize, alignBottom ]
        (List.map t_ Logo.youGoddamnRight)


title : Int -> Element Msg
title titleFontSize =
    column
        [ centerX
        , Font.size titleFontSize
        , padding 10
        , spacing 3
        , Background.color Color.elevatedGrey
        , alignBottom
        ]
        [ t [ centerX ] "Dmitrii Kovanikov"
        , t [ centerX ] "Senior Software Engineer @ Bloomberg"
        , t [ centerX, Font.color Color.suvaGrey ] "Functional Programming Adept"
        ]


linksRow : List (Element Msg) -> Element Msg
linksRow =
    row [ centerX, Font.size 24, spacing 10, alignBottom ]


gitHub : Element Msg
gitHub =
    social Social.gitHub


youTube : Element Msg
youTube =
    social Social.youTube


x : Element Msg
x =
    social Social.x


twitch : Element Msg
twitch =
    social Social.twitch


blueSky : Element Msg
blueSky =
    social Social.blueSky


linkedIn : Element Msg
linkedIn =
    social Social.linkedIn


email : Element Msg
email =
    social Social.email


social : Social.T -> Element Msg
social s =
    newTabLink
        [ padding 10
        , width fill
        , Background.color Color.elevatedGrey
        , Font.color Color.gainsboro
        , Border.rounded 4
        , mouseOver [ Background.color Color.yellow, Font.color Color.elevatedGrey ]
        ]
        { url = s.url, label = icon s.icon }


icon : Icon hasId -> Element msg
icon i =
    el [] (html <| Icon.view i)


menu : Model -> Element Msg
menu model =
    row [ width fill, height (fillPortion 2), spacing 10 ]
        [ column
            [ centerX
            , paddingEach { edges | left = 20 }
            , spacing 10
            ]
            [ menuButton model About
            , menuButton model Blog
            ]
        , column [ width fill, height fill, paddingEach { edges | right = 20, bottom = 20 } ]
            [ viewInfo model.info
            ]
        ]


menuButton : Model -> Info -> Element Msg
menuButton _ info =
    button
        [ centerX
        , width fill
        , Font.size 20
        , padding 10
        , Border.rounded 16
        , Background.color Color.elevatedGrey
        , Font.color Color.gainsboro
        , mouseOver [ Background.color Color.yellow, Font.color Color.elevatedGrey ]
        ]
        { onPress = Just (Selected info)
        , label = el [ Font.family monoFont, centerX ] (text <| showInfo info)
        }


viewInfo : Info -> Element msg
viewInfo info =
    case info of
        About ->
            about

        _ ->
            t [ width fill, height fill, Background.color Color.elevatedGrey, padding 10 ] (showInfo info)


about : Element msg
about =
    let
        bold =
            t [ Font.bold ]
    in
    code <|
        [ paragraph []
            [ t_ "Hi, I'm Dmitrii (he/him). This entire website is written in "
            , bold "Elm"
            , t_ ", and this is how you know I'm a nerd."
            ]
        , paragraph []
            [ t_ "I'm a Senior Software Engineer at Bloomberg. At my job, I primarily use "
            , bold "OCaml"
            , t_ " alongside "
            , bold "Python"
            , t_ ", "
            , bold "TypeScript"
            , t_ " and "
            , bold "C++."
            ]
        , paragraph []
            [ t_ "I'm passionate about Functional Programming, and I have professional experience with "
            , bold "OCaml"
            , t_ ", "
            , bold "Haskell"
            , t_ ", "
            , bold "Elm"
            , t_ ", "
            , bold "PureScript"
            , t_ ", "
            , bold "Nix"
            , t_ ", "
            , bold "Rust"
            , t_ " and "
            , bold "Kotlin."
            ]
        , t_ ""
        , t_ "A brief summary of my experience:"
        , t_ ""
        ]
            ++ unorderedList
                [ paragraph [] [ bold "10+", t_ " years of professional experience" ]
                , paragraph [] [ bold "10+", t_ " talks on multiple conferences and meetups (YOW! Lambda Jam, Haskell Love et al.)" ]
                , paragraph [] [ bold "7", t_ " Functional Programming courses created" ]
                , paragraph [] [ bold "50+", t_ " open-source projects authored" ]
                ]
            ++ [ t_ ""
               , t_ "All opinions are my own."
               ]
