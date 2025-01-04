module Page.Main exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import FontAwesome as Icon exposing (Icon)
import FontAwesome.Regular as Icon
import Html exposing (article)
import Html.Attributes exposing (class)
import Model exposing (Model)
import Model.Blog as Blog
import Model.Info exposing (Info(..))
import Model.Key exposing (ScrollState(..))
import Model.Msg exposing (Msg(..))
import Model.Social as Social
import View.Code exposing (code)
import View.Color as Color
import View.Element exposing (..)
import View.Font exposing (monoFont)
import View.Key as ViewKey
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
        , t [ centerX ] "Senior SWE @ Bloomberg"
        , t [ centerX, Font.color Color.suvaGrey ] "Functional Programming Adept"
        ]


linksRow : List (Attribute msg) -> List (Element msg) -> Element msg
linksRow attrs =
    row ([ centerX, Font.size 24, spacing 10 ] ++ attrs)


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


ggSocial : Model -> Social.T -> Element Msg
ggSocial model s =
    column [ spacing 7 ] [ social s, ViewKey.viewSocial model s ]


icon : Icon hasId -> Element msg
icon i =
    el [] (html <| Icon.view i)


menu : Int -> List (Attribute Msg) -> Model -> Element Msg
menu clipSize attrs model =
    column [ width fill ]
        [ scrollHint model.scrollState
        , row ([ width fill, spacing 10 ] ++ attrs)
            [ column
                [ centerX
                , paddingEach { edges | left = 10, right = 10 }
                , spacing 10
                , alignTop
                ]
                [ ViewKey.viewButton model About
                , ViewKey.viewButton model Blog
                ]
            , column
                [ htmlAttribute <| Html.Attributes.id "scrollable-info"
                , width fill
                , height (fill |> maximum clipSize)
                , paddingEach { edges | right = 10 }
                , scrollbarY
                , htmlAttribute (class "custom-scrollbar")
                ]
                [ viewInfo model
                ]
            ]
        ]


scrollHint : ScrollState -> Element msg
scrollHint scrollState =
    let
        downHint =
            case scrollState of
                ScrollDown ->
                    t [ Font.color Color.yellow ] "j/↓"

                _ ->
                    mono [] "j/↓"

        upHint =
            case scrollState of
                ScrollUp ->
                    t [ Font.color Color.yellow ] "k/↑"

                _ ->
                    mono [] "k/↑"
    in
    row
        [ centerX
        , Font.size 12
        , Font.color Color.suvaGrey
        , spacing 15
        , paddingEach { edges | bottom = 10 }
        ]
        [ downHint, upHint ]


viewInfo : Model -> Element msg
viewInfo model =
    let
        content =
            case model.info of
                About ->
                    about

                Blog ->
                    blog
    in
    column
        [ width fill
        , htmlAttribute (class "reset-scrollbar")
        ]
        [ content ]


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
        [ t_ "Hi, I'm Dmitrii (he/him), based in London, UK." ]
    , paragraph []
        [ t_ "This entire website is written in "
        , bold "Elm"
        , t_ ", and this is how you know I'm a nerd."
        ]
    , paragraph []
        [ t_ "I'm a Senior Software Engineer at Bloomberg." ]
    , paragraph []
        [ t_ "At my job, I primarily use "
        , bold "OCaml"
        , t_ " alongside "
        , bold "Python"
        , t_ ", "
        , bold "TypeScript"
        , t_ " and "
        , bold "C++."
        ]
    , paragraph []
        [ t_ "I'm passionate about Functional Programming," ]
    , paragraph []
        [ t_ "  and I have professional experience with "
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
    , paragraph [] [ t_ "A brief summary of my work:" ]
    , t_ ""
    ]
        ++ unorderedList
            [ paragraph [] [ bold "10+", t_ " years of professional experience" ]
            , paragraph [] [ bold "10+", t_ " talks on multiple conferences and meetups" ]
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
        , label =
            row [ spacing 10 ]
                [ icon Icon.filePdf
                , el [ Font.family monoFont, centerX ] (text "Download CV")
                ]
        }


blog : Element msg
blog =
    column
        [ width fill
        , height fill
        , Background.color Color.elevatedGrey
        , spacing 20
        , paddingEach { edges | top = 5, bottom = 5, left = 10 }
        ]
        (List.indexedMap viewArticle Blog.articles)


viewArticle : Int -> Blog.T -> Element msg
viewArticle i article =
    let
        newTag =
            if i == 0 then
                mono [ Font.color Color.yellow, Font.bold ] " NEW"

            else
                none
    in
    link
        [ padding 10
        , width fill
        , Font.color Color.gainsboro
        , mouseOver [ Font.color Color.yellow ]
        ]
        { url = Blog.mkPath article
        , label =
            column [ spacing 10 ]
                [ paragraph []
                    [ mono [ Font.color Color.blue ] "{"
                    , mono [] article.title
                    , mono [ Font.color Color.blue ] "}"
                    , newTag
                    ]
                , paragraph []
                    [ tSecondary [] article.createdAt ]
                ]
        }
