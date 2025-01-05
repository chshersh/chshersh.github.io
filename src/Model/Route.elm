module Model.Route exposing (Route(..), parseUrl)

import Url
import Url.Parser exposing ((</>), Parser, fragment, map, oneOf, parse, s, string, top)


type Route
    = Home
    | About
    | BlogPos (Maybe Int)
    | Blog String
    | NotFound


parseBlogFragment : Maybe String -> Maybe Int
parseBlogFragment maybeStr =
    Maybe.andThen String.toInt maybeStr


route : Parser (Route -> a) a
route =
    oneOf
        [ map Home top
        , map Home (s "index.html")
        , map About (s "about")
        , map BlogPos (s "blog" </> fragment parseBlogFragment)
        , map Blog (s "blog" </> string)
        ]


parseString : String -> Route
parseString string =
    case Url.fromString string of
        Nothing ->
            NotFound

        Just url ->
            Maybe.withDefault NotFound (parse route url)


parseUrl : Url.Url -> Route
parseUrl url =
    url |> Url.toString |> parseString
