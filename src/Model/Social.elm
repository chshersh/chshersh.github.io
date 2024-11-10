module Model.Social exposing (..)

import FontAwesome exposing (Icon, WithoutId)
import FontAwesome.Brands as Icon
import FontAwesome.Regular as Icon


type alias T =
    { name : String
    , icon : Icon WithoutId
    , url : String
    }


all : List T
all =
    [ { name = "GitHub"
      , icon = Icon.github
      , url = "https://github.com/chshersh"
      }
    , { name = "YouTube"
      , icon = Icon.youtube
      , url = "https://youtube.com/c/chshersh"
      }
    , { name = "ex-Twitter"
      , icon = Icon.xTwitter
      , url = "https://x.com/chshersh"
      }
    , { name = "Twitch"
      , icon = Icon.twitch
      , url = "https://www.twitch.tv/chshersh"
      }
    , { name = "LinkedIn"
      , icon = Icon.linkedin
      , url = "https://www.linkedin.com/in/chshersh/"
      }
    , { name = "Contact Me"
      , icon = Icon.envelope
      , url = "mailto:chshersh@gmail.com?subject=Question"
      }
    ]
