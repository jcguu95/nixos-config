import XMonad
import XMonad.Util.Run(spawnPipe)
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
myWorkspaces = clickable . (map xmobarEscape) $ ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
  where
        clickable l = [ "<action=xdotool key super+" ++ show (n) ++ "> " ++ ws ++ " </action>" | (i,ws) <- zip [1..9] l, let n = i]
myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "qutebrowser"

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
        ]
main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ docks defaultConfig
        { layoutHook = avoidStruts $ layoutHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , modMask  = myModMask
        , terminal = myTerminal
        , workspaces = myWorkspaces
        , borderWidth = myBorderWidth
        , normalBorderColor = myNormColor
        , focusedBorderColor = myFocusColor
        } `additionalKeysP` myKeys
