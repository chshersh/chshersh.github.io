port module Port exposing (..)


port newTab : String -> Cmd msg


port focusButton : String -> Cmd msg


port scrollElement : { id : String, delta : Int } -> Cmd msg


port scrollToElement : String -> Cmd msg
