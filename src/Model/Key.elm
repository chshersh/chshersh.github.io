module Model.Key exposing (..)

import Model.Info exposing (Info(..))


type Key
    = Letter Char
    | ArrowDown
    | ArrowUp
    | Other


parseKey : String -> Key
parseKey key =
    case key of
        "ArrowUp" ->
            ArrowUp

        "ArrowDown" ->
            ArrowDown

        _ ->
            case String.uncons key of
                Nothing ->
                    Other

                Just ( head, tail ) ->
                    if not (String.isEmpty tail) then
                        Other

                    else if 'a' <= head && head <= 'z' then
                        Letter head

                    else
                        Other


type KeyState
    = Start
    | G
    | Go Info
    | GG
    | GoGo Char


handleKeyState : KeyState -> Key -> KeyState
handleKeyState keyState key =
    case ( key, keyState ) of
        ( Other, _ ) ->
            Start

        ( Letter 'g', Start ) ->
            G

        ( Letter 'a', G ) ->
            Go About

        ( Letter 'b', G ) ->
            Go Blog

        ( Letter 'g', G ) ->
            GG

        ( Letter 'g', GG ) ->
            G

        ( Letter 'g', Go _ ) ->
            G

        ( Letter 'g', GoGo _ ) ->
            G

        ( Letter c, GG ) ->
            GoGo c

        ( _, _ ) ->
            Start


type ScrollState
    = NoScroll
    | ScrollDown
    | ScrollUp


parseScrollState : Key -> ScrollState
parseScrollState key =
    case key of
        Letter 'j' ->
            ScrollDown

        ArrowDown ->
            ScrollDown

        Letter 'k' ->
            ScrollUp

        ArrowUp ->
            ScrollUp

        _ ->
            NoScroll
