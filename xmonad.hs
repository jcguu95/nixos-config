import XMonad
import XMonad.Util.Run(spawnPipe)

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad defaultConfig
        { modMask = mod4Mask
        , terminal = "alacritty"
        }
