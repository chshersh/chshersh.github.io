module Model.Link exposing (..)

import FontAwesome exposing (Icon, WithoutId)
import FontAwesome.Brands as Icon
import FontAwesome.Regular as Icon


type alias T =
    { name : String
    , icon : Icon WithoutId
    }


all : List T
all =
    [ { name = "GitHub", icon = Icon.github }
    , { name = "YouTube", icon = Icon.youtube }
    , { name = "𝕏 (ex-Twitter)", icon = Icon.xTwitter }
    , { name = "Twitch", icon = Icon.twitch }
    , { name = "LinkedIn", icon = Icon.linkedin }
    , { name = "Contact Me", icon = Icon.envelope }
    ]
