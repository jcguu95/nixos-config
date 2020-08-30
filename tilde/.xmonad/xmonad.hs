import XMonad hiding ( Color -- imports modules: Main, Core, Config, Layout, ManageHook, Operations
                     )
import XMonad.Hooks.ManageDocks ( docks
                                )
import XMonad.Hooks.EwmhDesktops ( ewmh
                                 )

import XMonad.Local.Bindings.Bind ( mapBindings
                                  , storeBindings
                                  )
import XMonad.Local.Bindings.Keys ( myKeys
                                  )
import qualified XMonad.Local.Config.Theme as T
import XMonad.Local.Config.Workspace ( workspaceIds
                                     )
import XMonad.Local.Layout.Hook ( myLayoutHook
                                )
import XMonad.Local.Log.Hook ( myLogHook
                             )
import XMonad.Local.Log.XMobar ( spawnXMobar
                               )
import XMonad.Local.Manage.Hook ( myManageHook
                                )
import XMonad.Local.Startup.Hook ( myStartupHook
                                 )
import XMonad.Local.Urgency.Hook ( applyUrgencyHook
                                 )

-- testing

import XMonad.Layout.Tabbed
import XMonad.Layout.Circle
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spiral
import XMonad.Layout.NoBorders
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Hooks.ManageDocks

---

main :: IO ()
main = do xmproc <- spawnXMobar
          let (applicableKeys , explainableBindings) = mapBindings $ myKeys . modMask
              c = def { borderWidth        = T.borderWidth T.myTheme
                      , normalBorderColor  = T.inactiveBorderColor T.myTheme
                      , focusedBorderColor = T.activeBorderColor T.myTheme
                      , terminal           = "alacritty"
                      , focusFollowsMouse  = False
                      , clickJustFocuses   = False
                      , modMask            = mod4Mask
                      , keys               = applicableKeys
                      , workspaces         = workspaceIds
                      -- , layoutHook         = myLayoutHook
                      , layoutHook         = myLayout
                      , manageHook         = myManageHook
                      , startupHook        = myStartupHook
                      , logHook            = myLogHook xmproc
                      }
              fc = storeBindings explainableBindings . docks . applyUrgencyHook . ewmh $ c
          xmonad fc

--- testing

myLayout = smartBorders $ mkToggle (NOBORDERS ?? FULL ?? EOT) $ avoidStruts $
           tiled
           ||| Mirror tiled
--         ||| Full
--         ||| tabbed shrinkText defaultTheme
           ||| threeCol
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio
     threeCol = ThreeCol nmaster delta ratio
     -- The default number of windows in the master pane
     nmaster = 1
     -- Default proportion of screen occupied by master pane
     ratio   = 1/2
     -- Percent of screen to increment by when resizing panes
     delta   = 2/100
