module Model.Route exposing (Route(..), toRoute)

import Url
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


type Route
    = Home
    | Blog String
    | NotFound


route : Parser (Route -> a) a
route =
    oneOf
        [ map Home top
        , map Blog (s "blog" </> string)
        ]


parseString : String -> Route
parseString string =
    case Url.fromString string of
        Nothing ->
            NotFound

        Just url ->
            Maybe.withDefault NotFound (parse route url)


toRoute : Url.Url -> Route
toRoute url =
    url |> Url.toString |> parseString
