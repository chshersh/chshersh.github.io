module Model.Social exposing (..)

import FontAwesome exposing (Icon, WithoutId)
import FontAwesome.Brands as Icon
import FontAwesome.Regular as Icon


type alias T =
    { name : String
    , icon : Icon WithoutId
    , url : String
    }


gitHub : T
gitHub =
    { name = "GitHub"
    , icon = Icon.github
    , url = "https://github.com/chshersh"
    }


youTube : T
youTube =
    { name = "YouTube"
    , icon = Icon.youtube
    , url = "https://youtube.com/c/chshersh"
    }


x : T
x =
    { name = "ex-Twitter"
    , icon = Icon.xTwitter
    , url = "https://x.com/chshersh"
    }


twitch : T
twitch =
    { name = "Twitch"
    , icon = Icon.twitch
    , url = "https://www.twitch.tv/chshersh"
    }


blueSky : T
blueSky =
    { name = "BlueSky"
    , icon = Icon.bluesky
    , url = "https://bsky.app/profile/chshersh.com"
    }


linkedIn : T
linkedIn =
    { name = "LinkedIn"
    , icon = Icon.linkedin
    , url = "https://www.linkedin.com/in/chshersh/"
    }


email : T
email =
    { name = "Contact Me"
    , icon = Icon.envelope
    , url = "mailto:chshersh@gmail.com?subject=Question"
    }
