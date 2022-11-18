-- __  ____  __                       _
-- \ \/ /  \/  | ___  _ __   __ _  __| |
--  \  /| |\/| |/ _ \| '_ \ / _` |/ _` |
--  /  \| |  | | (_) | | | | (_| | (_| |
-- /_/\_\_|  |_|\___/|_| |_|\__,_|\__,_|
--
  -- Par Viahduc

  -- Voici les fonctions importes
import XMonad

  -- Actions
  
  -- Data

  -- Hooks
import XMonad.Hooks.EwmhDesktops        --Pour plus de compatibilite
import XMonad.Hooks.DynamicLog          --Pour communiquer avec XMobar
import XMonad.Hooks.StatusBar           --XMobar
import XMonad.Hooks.StatusBar.PP        --XMobar
import XMonad.Hooks.ManageHelpers       --Fenetres qui flottent
import XMonad.Hooks.Script              --autostart script ?? a verifier
import XMonad.Hooks.WindowSwallowing    --swallowing de fenetre par un terminal
import XMonad.Hooks.ManageDocks

  -- Layout
import XMonad.Layout.ThreeColumns       --Layout 3 colonnes
import XMonad.Layout.Magnifier          --Zoom
import XMonad.Layout.Renamed            --permet de rename les layout
import XMonad.Layout.NoBorders          --pour le true fullscreen
import XMonad.Layout.SimpleFloat
import XMonad.Layout.Maximize
import XMonad.Layout.Spacing            --Absolument horrible! Pire aventure de ma vie.
import XMonad.Layout.Gaps               --Absolument horrible! Pire aventure de ma vie.

  -- Util
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab
import XMonad.Util.Loggers              --XMobar
import XMonad.Util.SpawnOnce
import XMonad.Util.ClickableWorkspaces  --pour pouvoir clicker, pas utilise pour l'instant
import XMonad.Util.WorkspaceCompare
import XMonad.Util.NamedScratchpad

  -- Couleurs
  -- Options: Cyborg
import Colors.Cyborg
  -- Definir des valeurs

myTerminal :: String
myTerminal = "alacritty"    -- Terminaux disponibles: "alacritty" et "st"
 
myModMask :: KeyMask
myModMask = mod4Mask        -- mod1mask = alt et mod4mask = super

myBrowser :: String
myBrowser = "brave-browser" -- Navigateurs disponibles: "brave-browser", "firefox" et "qute-browser"

myEditor :: String
myEditor = myTerminal ++ " -e vim"

myBorderWidth :: Dimension
myBorderWidth = 2

myNormalBorderColor :: String
myNormalBorderColor  = borderNormalColor

myFocusedBorderColor :: String
myFocusedBorderColor = borderFocusedColor

myWorkspaces         = ["input","file","web","music","game","text","mail","virt","nan"]
-- myWorkspaces      = ["1",    "2",   "3",  "4",    "5",   "6",   "7",   "8",   "9"  ]

myHandleEventHook = swallowEventHook (className =? "st" <||> className =? "Termite") (return True)

mySort = getSortByXineramaRule

myFilter = filterOutWs [scratchpadWorkspaceTag]

-- Le Terme doShift permet de deplacer un programme dans un espace de travail defini par defaut
-- Le Terme doFloat ne force pas un programme a etre dans la mosaique-- 
myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Org.gnome.Nautilus" --> doShift ( myWorkspaces !! 1 )
    , className =? "Brave-browser"      --> doShift ( myWorkspaces !! 2 )
    , className =? "Clementine"         --> doShift ( myWorkspaces !! 3 )
    , className =? "Deadbeef"           --> doShift ( myWorkspaces !! 3 )
    , className =? "Steam"              --> doShift ( myWorkspaces !! 4 )
    , className =? "Lutris"             --> doShift ( myWorkspaces !! 4 )
    , className =? "discord"            --> doShift ( myWorkspaces !! 5 )
    , className =? "thunderbird"        --> doShift ( myWorkspaces !! 6 )
    , className =? "Geary"              --> doShift ( myWorkspaces !! 6 )
    , className =? "Virt-manager"       --> doShift ( myWorkspaces !! 7 )
    , className =? "Gimp"               --> doFloat
    , className =? "Gnome-calculator"   --> doFloat
    , className =? "steam_app_3590"     --> doFloat --Plants vs Zombies
    , className =? "ATLauncher"         --> doFloat
    , isDialog		                --> doFloat
    ]

--Autostart
myStartupHook = do
        spawnOnce "picom &"
	spawnOnce "conky &" 
	spawnOnce "conky -c /home/viahduc/.config/conky/Display2.conf"
	spawnOnce "conky -c /home/viahduc/.config/conky/Display3.conf"
	spawnOnce "nitrogen --restore &"
        spawn ("trayer --edge top --align right --SetDockType True --SetPartialStrut true --expand true --width 10 --transparent true --alpha 0 " ++ trayerColor ++ " --height 21 --monitor 1 &")
        spawnOnce "flameshot &"
        spawnOnce "clementine &"
	spawnOnce "blueman-applet &"
	spawnOnce "lxpolkit &"
	spawnOnce "volumeicon &"
        spawnOnce "volumeicon &" --Il doit y en avoir deux.
	spawnOnce "/usr/bin/emacs --daemon &"
	spawnOnce "twmnd &"
        spawnOnce "watch -n 600 dnf check-update --refresh --quiet &"
        spawnOnce "flatpak run com.discordapp.Discord"
       
xmobar1 = statusBarPropTo "_XMONAD_LOG_1" "xmobar -x 0 ~/.config/xmobar/xmobarrc1" (pure myXmobarPP)
xmobar2 = statusBarPropTo "_XMONAD_LOG_2" "xmobar -x 1 ~/.config/xmobar/xmobarrc2" (pure myXmobarPP)
xmobar3 = statusBarPropTo "_XMONAD_LOG_3" "xmobar -x 2 ~/.config/xmobar/xmobarrc3" (pure myXmobarPP)

--Fonction Main
main :: IO ()
main = xmonad 
     . ewmhFullscreen 
     . ewmh
     . docks
     . withEasySB (xmobar1 <> xmobar2 <> xmobar3) defToggleStrutsKey
     $ myConfig

myConfig = def
    { modMask            = myModMask
    , layoutHook         = myLayout
    , terminal           = myTerminal
    , workspaces         = myWorkspaces
    , normalBorderColor  = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
    , borderWidth        = myBorderWidth
    , manageHook         = myManageHook --pour que des fenêtres se mettent en flottant par d�faut
    , startupHook        = myStartupHook
    , handleEventHook    = myHandleEventHook
    }
   `additionalKeysP`
    [ ("M-p",     spawn "dmenu_run -fn 'Ubuntu:weight=bold:size=10:antialias=true:hinting=true' -h 21 -nf '#B22222'" )
    , ("M-o",     spawn "~/.local/bin/keylang/keylang2.sh"    ) --clavier americain
    , ("M-i",     spawn "~/.local/bin/keylang/keylang1.sh"    ) --clavier canadien
    , ("M-u",     sendMessage ToggleOff   ) --eteindre le zoom
    , ("M-S-u",   sendMessage ToggleOn    ) --demarrer le zoom
    , ("M-q",     spawn "xmonad --recompile" )
    , ("M-S-b",   spawn (myBrowser) )
    , ("M-b",     sendMessage ToggleStruts)
    , ("M-S-n",   withFocused (sendMessage . maximizeRestore))
    ]

--Layout
--myLayout = avoidStruts (tiled ||| maximize threeCol ||| lessBorders Never $ noBorders Full)
myLayout = avoidStruts (tiled ||| maximize threeCol ||| noBorders Full)
    where
      threeCol     = renamed [Replace "ThreeCol"  ]$ ThreeColMid nmaster delta ratio
      tiled        = renamed [Replace "Tiled"     ]$ Tall nmaster delta ratio
      nmaster      = 1               --Nombre par défaut de fênetre dans l'écran maître
      ratio        = 1/2             --Proportion par défaut utilisé par l'écran maitre
      delta        = 3/100           --Pourcentage qui change quand tu "resize" des fenêtre

--XMobar
myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = xmobarColor separatorColor "" " | "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" separatorColor 2
    , ppHidden          = xmobarColor usedunusedColor "" . wrap " " ""
    , ppHiddenNoWindows = xmobarColor unusedunusedColor "" . wrap " " ""
    , ppUrgent          = xmobarColor urgentColor "" . wrap (xmobarColor urgentIndicatorColor "" "!") (xmobarColor urgentIndicatorColor "" "!")
    , ppOrder           = myOrder
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    myOrder [ws, l, _, wins] = [ws, l, wins]
    formatFocused   = wrap (xmobarColor usedunusedColor ""   "[") (xmobarColor usedunusedColor ""   "]") . xmobarColor separatorColor "" . ppWindow
    formatUnfocused = wrap (xmobarColor unusedunusedColor "" "[") (xmobarColor unusedunusedColor "" "]") . xmobarColor dotsColor ""      . ppWindow

    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 0
    
    blue, espacevide, red, white, yellow :: String -> String
    magenta        = xmobarColor "#6495ED" "" -- separateur pour le truc pas modifiable dans xmobar
    blue           = xmobarColor "#6495ed" "" -- les 3 petits points
    white          = xmobarColor "#fea51a" "" -- les parantheses carres et l'espace avec qqc mais qui est pas actif
    yellow         = xmobarColor "#ffc978" "" -- urgent^^
    red            = xmobarColor "#fea51a" ""
    espacevide     = xmobarColor "#319b54" "" -- espace de travail pas utiliser
