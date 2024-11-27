module Page.Main exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input exposing (button)
import FontAwesome as Icon exposing (Icon)
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


edges : { top : Int, right : Int, bottom : Int, left : Int }
edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }


logo : List (Attribute msg) -> Element msg
logo attrs =
    column
        ([ centerX, paddingEach { edges | top = 20 } ] ++ attrs)
        (List.map t_ Logo.youGoddamnRight)


title : List (Attribute msg) -> Element msg
title attrs =
    column
        ([ centerX
         , padding 10
         , spacing 3
         , Background.color Color.elevatedGrey
         ]
            ++ attrs
        )
        [ t [ centerX ] "Dmitrii Kovanikov"
        , t [ centerX ] "Senior Software Engineer @ Bloomberg"
        , t [ centerX, Font.color Color.suvaGrey ] "Functional Programming Adept"
        ]


linksRow : List (Attribute msg) -> List (Element msg) -> Element msg
linksRow attrs =
    row ([ centerX, Font.size 24, spacing 10 ] ++ attrs)


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


menu : List (Attribute Msg) -> Model -> Element Msg
menu attrs model =
    row ([ width fill, spacing 10 ] ++ attrs)
        [ column
            [ centerX
            , paddingEach { edges | left = 20 }
            , spacing 10
            ]
            [ menuButton model About
            , menuButton model Blog
            ]
        , column
            [ width fill
            , height (fill |> maximum 300)
            , paddingEach { edges | right = 20, bottom = 20 }
            , scrollbarY
            ]
            [ viewInfo model.info
            ]
        ]


menuButton : Model -> Info -> Element Msg
menuButton _ info =
    button
        [ centerX
        , width fill
        , Font.size 20
        , paddingEach { top = 5, bottom = 5, left = 15, right = 15 }
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

        Blog ->
            t [ width fill, height fill, Background.color Color.elevatedGrey, padding 10 ]
                "Magic dwarfs are working really hard on this section!"


about : Element msg
about =
    column
        [ width fill
        , height fill
        , Background.color Color.elevatedGrey
        , spacing 10
        , paddingEach { edges | top = 5, bottom = 5 }
        ]
        [ aboutCode
        , row [ paddingEach { edges | left = 15 } ] [ downloadCV ]
        ]


aboutCode : Element msg
aboutCode =
    code aboutText


aboutText : List (Element msg)
aboutText =
    let
        bold =
            t [ Font.bold ]
    in
    [ paragraph []
        [ t_ "Hi, I'm Dmitrii (he/him), based in London, UK. This entire website is written in "
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
    , paragraph [] [ t_ "A brief summary of my experience:" ]
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


downloadCV : Element msg
downloadCV =
    download
        [ Font.size 20
        , paddingEach { top = 5, bottom = 5, left = 15, right = 15 }
        , Border.rounded 4
        , Border.color Color.gainsboro
        , Border.width 2
        , Background.color Color.elevatedGrey
        , Font.color Color.gainsboro
        , mouseOver
            [ Background.color Color.yellow
            , Border.color Color.yellow
            , Font.color Color.elevatedGrey
            ]
        ]
        { url = "/files/CV_Dmitrii_Kovanikov.pdf"
        , label = el [ Font.family monoFont, centerX ] (text "🗎 Download CV")
        }