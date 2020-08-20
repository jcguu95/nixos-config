module XMonad.Local.Config.Color ( Colors (..)
                                 , Color
                                 , myColors
                                 ) where

type Color = String

data Colors = Colors { color0 :: Color
                     , color1 :: Color
                     , color2 :: Color
                     , color3 :: Color
                     , color4 :: Color
                     , color5 :: Color
                     , color6 :: Color
                     , color7 :: Color
                     , color8 :: Color
                     , color9 :: Color
                     , colorA :: Color
                     , colorB :: Color
                     , colorC :: Color
                     , colorD :: Color
                     , colorE :: Color
                     , colorF :: Color
                     }
  deriving (Eq, Read, Show)

myColors :: Colors
myColors = Colors { color0 = "#282828" -- black
                  , color8 = "#928374"

                  , color1 = "#cc241d" -- red
                  , color9 = "#fb4934"

                  , color2 = "#98971a" -- green
                  , colorA = "#b8bb26"

                  , color3 = "#d79921" -- yellow
                  , colorB = "#fabd2f"

                  , color4 = "#458588" -- blue
                  , colorC = "#83a598"

                  , color5 = "#b16286" -- magenta
                  , colorD = "#d3869b"

                  , color6 = "#689d6a" -- cyan
                  , colorE = "#83c07c"

                  , color7 = "#a89984" -- white
                  , colorF = "#ebdbb2"
                  }
