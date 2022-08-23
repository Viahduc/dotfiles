--Config de XMonad
--Par Viahduc

import XMonad
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab
import XMonad.Layout.ThreeColumns       --Layout 3 colonnes
import XMonad.Layout.Magnifier          --Zoom
import XMonad.Hooks.EwmhDesktops        --Pour plus de compatibilité
import XMonad.Hooks.DynamicLog          --Pour communiquer avec XMobar
import XMonad.Hooks.StatusBar           --XMobar
import XMonad.Hooks.StatusBar.PP        --XMobar
import XMonad.Util.Loggers		--XMobar
import XMonad.Hooks.ManageHelpers	--Fenêtres qui flottent
import XMonad.Layout.Renamed		--permet de rename les layout
import XMonad.Hooks.Script		--autostart script
import XMonad.Util.SpawnOnce
import XMonad.Hooks.WindowSwallowing	--swallowing de fenetre
import XMonad.Util.ClickableWorkspaces  --pour pouvoir clicker
import XMonad.Layout.NoBorders          --pour le true fullscreen
import XMonad.Layout.SimpleFloat

--Définir des valeurs

myTerminal           = "alacritty"
myBorderWidth        = 2
myWorkspaces         = ["input","file","web","music","game","text","mail","vbox","nan"]
myNormalBorderColor  = "#808080"
myFocusedBorderColor = "#B22222"
myHandleEventHook = swallowEventHook (className =? "Alacritty" <||> className =? "Termite") (return True)

--Programme qui "float"
myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> 		    doFloat
    , className =? "minecraft-launcher" --> doFloat
    , className =? "gnome-calculator"   --> doFloat
    , isDialog		  --> 		    doFloat
    ]

--Autostart
myStartupHook = do
	spawnOnce "xrandr --output DVI-D-0 --mode 1920x1080 --pos 3840x0 --rotate normal --rate 59 --output HDMI-0 --mode 1920x1080 --pos 0x1 --rotate normal --rate 59 --output DP-0 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --rate 59"
        spawnOnce "picom &"
	spawnOnce "conky &" 
	spawnOnce "conky -c /home/viahduc/.config/conky/Display2.conf"
	spawnOnce "conky -c /home/viahduc/.config/conky/Display3.conf"
	spawnOnce "nitrogen --restore &"
        spawnOnce "trayer --edge top --align right --SetDockType True --SetPartialStrut true --expand true --width 15 --transparent true --alpha 0 --tint 0xffd3d3d3 --height 21 --monitor 1 &"
        spawnOnce "xmobar -x 0 ~/.xmobarcc"
	spawnOnce "xmobar -x 1 /home/viahduc/.config/xmonad/.xmobarrc2 &"
	spawnOnce "xmobar -x 2 /home/viahduc/.config/xmonad/.xmobarrc2 &"
        spawnOnce "flameshot &"
        spawnOnce "clementine &"
	spawnOnce "blueman-applet &"
	spawnOnce "lxpolkit &"
	spawnOnce "volumeicon &"
	spawnOnce "/usr/bin/emacs --daemon &"
	spawnOnce "twmnd &"
--Fonction Main

main :: IO ()
main = xmonad 
     . ewmhFullscreen 
     . ewmh 
     . withEasySB (statusBarProp "xmobar -x 0 ~/.xmobarrc && xmobar -x 1 /home/viahduc/.config/xmonad/.xmobarrc2" (pure myXmobarPP)) defToggleStrutsKey
     $ myConfig

myConfig = def
    { modMask     = mod4Mask  --ça permet de faire en sorte que la touche maitre soit Super (Windows)
    , layoutHook  = myLayout
    , terminal    = myTerminal
    , workspaces  = myWorkspaces
    , normalBorderColor = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
    , borderWidth = myBorderWidth
    , manageHook  = myManageHook --pour que des fenêtres se mettent en flottant par d�faut
    , startupHook = myStartupHook
    , handleEventHook = myHandleEventHook
    }
   `additionalKeysP`
    [ ("M-p",     spawn "dmenu_run -l 18 -g 3 -i -fn 'xft:Ubuntu Mono:size:12:antialias:true'" )
    , ("M-i",     spawn "setxkbmap us"    ) --clavier américain
    , ("M-o",     spawn "setxkbmap ca"    ) --clavier canadien
    , ("M-u",     sendMessage ToggleOff   ) --éteindre le zoom
    , ("M-S-u",   sendMessage ToggleOn    ) --démarrer le zoom
    , ("M-q",     spawn "xmonad --recompile" )
    , ("M-y",	  spawn "joy"		  )
    , ("M-S-b",   spawn "brave-browser"   )
    ]

--Layout

myLayout = tiled ||| Mirror tiled ||| threeCol ||| noBorders Full -- ||| noBorders simpleFloat
    where
      threeCol     = renamed [Replace "ThreeCol"  ]$ magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio --Défini le "layout threeCol"
      tiled        = renamed [Replace "Tiled"     ]$ magnifiercz' 1.5 $ Tall nmaster delta ratio
      nmaster      = 1               --Nombre par défaut de fênetre dans l'écran maître
      ratio        = 1/2             --Proportion par défaut utilisé par l'écran maitre
      delta        = 3/100           --Pourcentage qui change quand tu "resize" des fenêtre
--XMobar

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " • "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#2a52be" 2
    , ppHidden          = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = myOrder
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    myOrder [ws, l, _, wins] = [ws, l, wins]
    formatFocused   = wrap (white    "[") (white    "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue    . ppWindow

    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30
    
    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#6495ed" ""
    blue     = xmobarColor "#2a52be" ""
    white    = xmobarColor "#CD5C5C" ""
    yellow   = xmobarColor "#ffc978" ""
    red      = xmobarColor "#ea3c53" ""
    lowWhite = xmobarColor "#000000" ""
