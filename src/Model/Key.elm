module Model.Key exposing (..)

import Model.Info exposing (Info(..))


type Key
    = Letter Char
    | Other


parseKey : String -> Key
parseKey key =
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


handleKey : KeyState -> Key -> KeyState
handleKey keyState key =
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

        ( Letter 'g', Go _ ) ->
            G

        ( Letter 'g', GoGo _ ) ->
            G

        ( Letter c, GG ) ->
            GoGo c

        ( _, _ ) ->
            Start
