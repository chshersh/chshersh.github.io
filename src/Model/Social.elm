module Model.Social exposing (..)

import Dict
import FontAwesome exposing (Icon, WithoutId)
import FontAwesome.Brands as Icon
import FontAwesome.Regular as Icon


type alias T =
    { name : String
    , icon : Icon WithoutId
    , url : String
    , gg : Char
    }


gitHub : T
gitHub =
    { name = "GitHub"
    , icon = Icon.github
    , url = "https://github.com/chshersh"
    , gg = 'h'
    }


youTube : T
youTube =
    { name = "YouTube"
    , icon = Icon.youtube
    , url = "https://youtube.com/c/chshersh"
    , gg = 'y'
    }


x : T
x =
    { name = "ex-Twitter"
    , icon = Icon.xTwitter
    , url = "https://x.com/chshersh"
    , gg = 'x'
    }


twitch : T
twitch =
    { name = "Twitch"
    , icon = Icon.twitch
    , url = "https://www.twitch.tv/chshersh"
    , gg = 't'
    }


blueSky : T
blueSky =
    { name = "BlueSky"
    , icon = Icon.bluesky
    , url = "https://bsky.app/profile/chshersh.com"
    , gg = 'b'
    }


linkedIn : T
linkedIn =
    { name = "LinkedIn"
    , icon = Icon.linkedin
    , url = "https://www.linkedin.com/in/chshersh/"
    , gg = 'l'
    }


email : T
email =
    { name = "Contact Me"
    , icon = Icon.envelope
    , url = "mailto:chshersh@gmail.com?subject=Question"
    , gg = 'e'
    }


socials : Dict.Dict Char T
socials =
    Dict.fromList
        [ ( 'h', gitHub )
        , ( 'y', youTube )
        , ( 'x', x )
        , ( 't', twitch )
        , ( 'b', blueSky )
        , ( 'l', linkedIn )
        , ( 'e', email )
        ]
