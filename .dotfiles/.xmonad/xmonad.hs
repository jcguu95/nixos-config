import XMonad
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Actions.CopyWindow (kill1)

-- For xmobar
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
-- --- ------

myModMask :: KeyMask
myModMask = mod4Mask

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces :: [String]
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "qutebrowser"

myFileManager :: String
myFileManager = "\"alacritty -e ranger\""

myEditor :: String
myEditor = "nvim"

myBorderWidth :: Dimension
myBorderWidth = 1

myNormColor :: String
myNormColor = "#292d3e"

myFocusColor :: String
myFocusColor = "#bbc5ff"

myKeys :: [(String, X ())]
myKeys =
        [ ("M-q", kill1) -- Kill the currently focused client
        , ("M-<Return>", spawn myTerminal)
        , ("M-w", spawn myBrowser) 
        , ("M-r", spawn myFileManager) -- TODO: It does not work.
        ]

myStartupHook :: X ()
myStartupHook = do
          -- spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x000000 --height 16 &"
          spawnOnce "/usr/bin/emacs --daemon &"

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ docks defaultConfig
        { layoutHook = avoidStruts $ layoutHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , startupHook        = myStartupHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        } `additionalKeysP` myKeys
