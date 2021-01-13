-- xmonad config used by k4l1brx, modified from randomthought's config 

{-# LANGUAGE TypeSynonymInstances, DeriveDataTypeable, MultiParamTypeClasses, NoMonomorphismRestriction, FlexibleContexts #-}
-- ---------------------------------------------------------------------------
import System.IO


import Data.Monoid
import Data.Ratio ((%))
import Data.Word
import Control.Monad ((>=>), join, liftM, when, unless, forM)   -- For Custom Fullscreen Function
import GHC.Word
import System.Exit
import qualified Data.List as L
import XMonad.Util.Font
import XMonad.Layout.AvoidFloats
import XMonad hiding ( (|||) )
import XMonad.Actions.Navigation2D
import XMonad.Actions.UpdatePointer
import XMonad.Hooks.DynamicLog
import XMonad.Util.SpawnOnce 
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ServerMode
import qualified XMonad.Actions.FlexibleManipulate as Flex
import qualified XMonad.Layout.BoringWindows as BR
import XMonad.Layout.Decoration(Decoration, DefaultShrinker)
import XMonad.Layout.LayoutModifier(LayoutModifier(handleMess, modifyLayout,
                                    redoLayout),
                                    ModifiedLayout(..))
import XMonad.Layout.Simplest(Simplest(..))

import XMonad.Util.WorkspaceCompare
import XMonad.Actions.CycleWS
import XMonad.Layout.Reflect
import XMonad.Layout.DecorationMadness
import XMonad.Layout.BorderResize
import XMonad.Layout.TrackFloating
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.Place
import XMonad.Hooks.InsertPosition
import qualified XMonad.Layout.Magnifier as Mag

import XMonad.Layout hiding ( (|||) )
import XMonad.Layout.TabBarDecoration
import XMonad.Layout.Gaps
import XMonad.Layout.Fullscreen
import XMonad.Layout.BinarySpacePartition as BSP
import XMonad.Layout.NoBorders
import XMonad.Layout.IfMax

-- Layouts 
import XMonad.Layout.Tabbed
import XMonad.Layout.SimplestFloat
import XMonad.Layout.SimpleFloat
import XMonad.Layout.WindowArranger
import XMonad.Layout.ThreeColumns
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.ResizableTile -- for resizeable tall layout 
import XMonad.Layout.MouseResizableTile -- for mouse control  
--- Layout Modifiers 
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle
import qualified XMonad.Layout.ToggleLayouts as TL
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.Renamed

import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation

import XMonad.Layout.ZoomRow
import XMonad.Layout.Grid
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Cursor

import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Actions.FloatKeys
-- Tree Select 
import Data.Tree
import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Hooks.WorkspaceHistory
import qualified XMonad.StackSet as W

import XMonad.Actions.FloatSnap
import XMonad.Actions.Promote

import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Theme

import XMonad.Util.NamedScratchpad
import XMonad.Prompt.Shell 
import XMonad.Actions.CopyWindow
import XMonad.Actions.GridSelect
import XMonad.Util.WindowProperties


-----------------------------------Custom Layout---------------------------
----------------------------mupdf--------------------------------------------
-- Terminimport XMonad.Hooks.EwmhDesktopsal
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--

-- myTerminal = "~/.scripts/launch_kitty.sh"
myTerminalDir = "alacritty --working-directory `xcwd`"
myTerminal = "alacritty"

-- The command to lock the screen or show the screensaver.
myScreensaver = "~/.scripts/lock.sh"

-- The command to take a selective screenshot, where you select
-- what you'd like to capture on the screen.
mySelectScreenshotCliboard = "maim -s | xclip -selection clipboard -t image/png"

mySelectScreenshot = "maim -s ~/Pictures/MAIM_Screenshot_$(date +%F-%T).png && notify-send \"Maim\" \"Region Screenshot taken\" -t 2000"
-- The command to take a fullscreen screenshot.
myScreenshot = "maim ~/Pictures/MAIM_Screenshot_$(date +%F-%T).png && notify-send \"Maim\" \"Full Screenshot taken\" -t 2000"
-- The command to use as a launcher, to launch commands that don't have
-- preset keybindings.
myLauncher = "~/.scripts/rofi_app_launcher.sh"


-----------------------------------------------------------------------
------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWS = ["1 \xfbe2  ", "2 \xf269  ", "3 \xf0c3 ", "4 \xe62b ","5 \xe62b ", "6 \xf016  ", "7 \xf044 ", "8 \xf126","9 \xf152  "]

myWorkspaces :: [String]
myWorkspaces = clickable . map xmobarEscape
               $ ["1 \xfbe2  ", "2 \xf269  ", "3 \xf0c3 ", "4 \xe62b ","5 \xe62b ", "6 \xf016  ", "7 \xf044 ", "8 \xf126","9 \xf152  "]
  where
        clickable l = [ "<action=xdotool key super+" ++ show n ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,
                      let n = i ]
------------------------------------------------------------------------
-- Window rules
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
------------------------

-- Android studio fix 
(~=?) :: Eq a => Query [a] -> [a] -> Query Bool
q ~=? x = fmap (L.isInfixOf x) q
-- Do not treat menus and settings popup as a separate window.
manageIdeaCompletionWindow = (className =? "jetbrains-studio") <&&> (title ~=? "win") --> doIgnore

-- $ ["1 \xfbe2  ", "2 \xf269  ", "3 \xf0c3 ", "4 \xe62b ","5 \xe62b ", "6 \xf016  ", "7 \xf044 ", "8 \xf126","9 \xf152  "]
myManageHook = 
      (isDialog --> doF W.swapUp)                       -- Bring Dialog Window on Top of Parent Floating Window
       <+> insertPosition Below Newer                    -- Insert New Windows at the Bottom of Stack Area
       <+> manageIdeaCompletionWindow                    -- Adding Fix for Android Studio
       <+>
      composeAll
      [
      className =? "discord"                --> doShift ( myWorkspaces !! 0 )
      -- , className =? "okular"                --> doShift $ 
      , className =? "knotes"                --> doIgnore
      , resource  =? "desktop_window"               --> doIgnore
      , className =? "Galculator"                   --> doCenterFloat
      , className =? "Steam"                        --> doCenterFloat
      , className =? "popup-bottom-center"          --> doCenterFloat
      , className =? "Gimp"                         --> doCenterFloat
      , resource  =? "gpicview"                     --> doCenterFloat
      , className =? "MPlayer"                      --> doCenterFloat
      , className =? "Pavucontrol"                  --> doCenterFloat
      , className =? "Xfce4-power-manager-settings" --> doCenterFloat
      , className =? "Xchat"                        --> doShift "5:media"
      , className =? "stalonetray"                  --> doIgnore
      -- , isFullscreen                                --> (doF W.focusDown <+> doFullFloat)
      , isFullscreen                             --> doFullFloat
      ]

------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.

mySubTabbed  x = addTabs shrinkText myTabTheme $ subLayout [] Simplest x

outerGaps    = 0
myGaps       = gaps [(U, outerGaps), (R, outerGaps), (L, outerGaps), (D, outerGaps)]
addSpace     = renamed [CutWordsLeft 2] . spacing gap
tab          = avoidStruts
              $ renamed [Replace "[T]"]
               $ tabbedBottomAlways shrinkText myTabTheme

myTall = renamed [Replace "[]="]
          $ mySubTabbed $ BR.boringWindows 
          $ windowNavigation
          -- $ addTopBar
          $ addSpace
          $ windowArrange 
          -- $ tabBar shrinkText myTabTheme Bottom (gaps[(D, 18)] $ (Tall 1 (3/100) (1/2)))
          $ ResizableTall 1 (3/100) (1/2) []

myMagnifyTall = renamed [Replace "[MT]"]
          -- $ addTopBar
          $ addSpace
          $ windowArrange 
          -- $ tabBar shrinkText myTabTheme Bottom (gaps[(D, 18)] $ (Tall 1 (3/100) (1/2)))
          $ tabBar shrinkText myTabTheme Bottom (gaps[(D, 16)] $ (Mag.magnifier(ResizableTall 1 (3/100) (1/2) [])))

myMagnifyGrid = renamed [Replace "[MG]"]
      -- $ addTopBar
      $ windowNavigation
      $ addSpace
      $ tabBar shrinkText myTabTheme Bottom (gaps [(D, 16)] $ (Mag.magnifier $ Grid)) 

my3C = renamed [Replace "[=]"]
      $ mySubTabbed $ BR.boringWindows 
      $ windowNavigation
      $ addSpace
      $ ThreeCol 1 (3/100) (1/2)

myGrid = renamed [Replace "[G]"]
      $ mySubTabbed $ BR.boringWindows 
      $ windowNavigation
      $ addSpace
      $ Grid

myRez = renamed [Replace "[S]"]
      $ windowNavigation
      $ tabBar shrinkText myTabTheme Bottom (gaps [(D, 16)] $ simplestFloat)

-- layouts      = TL.toggleLayouts (avoidStruts myRez) (windowArrange (tab ||| avoidStruts (
layouts      = TL.toggleLayouts (avoidStruts myRez) (windowArrange (tab ||| avoidStruts (
                      myMagnifyGrid ||| myMagnifyTall ||| myTall ||| my3C ||| myGrid
                  )))

myLayoutSelect = [
         ("[T]", sendMessage $ JumpToLayout "[T]")
         ,("[]=", sendMessage $ JumpToLayout "[]=")
         ,("[G]",    sendMessage $ JumpToLayout "[G]")
         ,("[=]",    sendMessage $ JumpToLayout "[=]")
         ]

selectLayout     = runSelectedAction (myGSConfig $ myColor color4) myLayoutSelect

myGSConfig colorizer = (buildDefaultGSConfig colorizer)
  {gs_cellheight  = 50
  ,gs_cellwidth   = 125
  }

myLayout    = smartBorders
              $ mkToggle (NOBORDERS ?? FULL ?? EOT)
              $ layouts


-- Colorizer generator
myColor color _ isFg = do
  return $ if isFg
           then (color, color0)
           else (color0 ,color)

myNav2DConf = def
    { defaultTiledNavigation    = centerNavigation
    , floatNavigation           = centerNavigation
    , screenNavigation          = lineNavigation
    , layoutNavigation          = [("Full",          centerNavigation)
    -- line/center same results   ,("Tabs", lineNavigation)
    --                            ,("Tabs", centerNavigation)
                                  ]
    , unmappedWindowRect        = [("Full", singleWindowRect)
    -- works but breaks tab deco  ,("Tabs", singleWindowRect)
    -- doesn't work but deco ok   ,("Tabs", fullScreenRect)
                                  ]
    }
-------
-- Tree Menu
treeselectAction :: TS.TSConfig (X ()) -> X ()
treeselectAction myMenu = TS.treeselectAction myMenu
  [
    Node (TS.TSNode "Session" "Session" (return())) 
     [
       Node(TS.TSNode "Lock" "Lock the system" (spawn myScreensaver)) []
       , Node(TS.TSNode "Suspend" "Suspend" (spawn "systemctl suspend")) []
       , Node(TS.TSNode "Logout" "logout" (io (exitWith ExitSuccess))) []
       , Node(TS.TSNode "Reboot" "Reboot the system" (spawn "systemctl reboot")) []
       , Node(TS.TSNode "Shutdown" "Poweroff the system" (spawn "systemctl poweroff")) []
     ]
   , Node (TS.TSNode "Brightness" "Sets screen brightness using xbacklight" (return ()))
       [ Node (TS.TSNode "100%" "FULL POWER!!"            (spawn "xbacklight -set 100")) []
       , Node (TS.TSNode "75%" "Normal Brightness (75%)" (spawn "xbacklight -set 75"))  []
       , Node (TS.TSNode "50%" "Normal Brightness (50%)" (spawn "xbacklight -set 50"))  []
       , Node (TS.TSNode "25%"    "Quite dark"              (spawn "xbacklight -set 25"))  []
       ]
   ]
tsDefaultConfig :: TS.TSConfig myMenu
tsDefaultConfig = TS.TSConfig { 
                             TS.ts_hidechildren = True
                           , TS.ts_background   = 0xc083a598
                           , TS.ts_font         = "xft:Sans-16"
                           , TS.ts_node         = (0xff1d2021, 0xff83a598)
                           , TS.ts_nodealt      = (0xff1d2021, 0xff85b6a3)
                           , TS.ts_highlight    = (0xffffffff, 0xffb8bb26)
                           , TS.ts_extra        = 0xffb8bb26
                           , TS.ts_node_width   = 200
                           , TS.ts_node_height  = 30
                           , TS.ts_originX      = 20
                           , TS.ts_originY      = 20
                           , TS.ts_indent       = 80
                           , TS.ts_navigate     = myTreeNavigation
                           }
myTreeNavigation = M.fromList
    [ ((0, xK_Escape),   TS.cancel)
    , ((0, xK_Return),   TS.select)
    , ((0, xK_space),    TS.select)
    , ((0, xK_Up),       TS.movePrev)
    , ((0, xK_Down),     TS.moveNext)
    , ((0, xK_Left),     TS.moveParent)
    , ((0, xK_Right),    TS.moveChild)
    , ((0, xK_k),        TS.movePrev)
    , ((0, xK_j),        TS.moveNext)
    , ((0, xK_h),        TS.moveParent)
    , ((0, xK_l),        TS.moveChild)
    , ((0, xK_o),        TS.moveHistBack)
    , ((0, xK_i),        TS.moveHistForward)
    , ((0, xK_d),        TS.moveTo ["dev"])
    , ((0, xK_g),        TS.moveTo ["graphics"])
    , ((0, xK_m),        TS.moveTo ["music"])
    , ((0, xK_v),        TS.moveTo ["video"])
    , ((0, xK_w),        TS.moveTo ["web"])
    , ((mod4Mask, xK_b), TS.moveTo ["web", "browser"])
    , ((mod4Mask, xK_c), TS.moveTo ["web", "chat"])
    , ((mod4Mask, xK_m), TS.moveTo ["web", "email"])
    , ((mod4Mask, xK_r), TS.moveTo ["web", "rss"])
    , ((mod4Mask, xK_w), TS.moveTo ["web", "web conference"])
    , ((mod4Mask, xK_d), TS.moveTo ["dev", "docs"])
    , ((mod4Mask, xK_e), TS.moveTo ["dev", "emacs"])
    , ((mod4Mask, xK_f), TS.moveTo ["dev", "files"])
    , ((mod4Mask, xK_p), TS.moveTo ["dev", "programming"])
    , ((mod4Mask, xK_t), TS.moveTo ["dev", "terminal"])
    , ((mod4Mask, xK_z), TS.moveTo ["dev", "virtualization"])
    , ((mod4Mask, xK_g), TS.moveTo ["graphics", "gimp"])
    , ((mod4Mask, xK_i), TS.moveTo ["graphics", "image viewer"])
    , ((mod4Mask, xK_u), TS.moveTo ["music", "music player"])
    , ((mod4Mask, xK_o), TS.moveTo ["video", "obs"])
    , ((mod4Mask, xK_v), TS.moveTo ["video", "video player"])
    , ((mod4Mask, xK_k), TS.moveTo ["video", "kdenlive"])
    , ((mod4Mask .|. altMask, xK_h), TS.moveTo ["dev", "programming", "haskell"])
    , ((mod4Mask .|. altMask, xK_p), TS.moveTo ["dev", "programming", "python"])
    , ((mod4Mask .|. altMask, xK_s), TS.moveTo ["dev", "programming", "shell"])
    ]


-- getSortByIndexNoSP =
--         fmap (.namedScratchpadFilterOutWorkspace) getSortByIndex

windowsNoSP :: (WindowSet -> WindowSet) -> X ()
windowsNoSP = windows


myGoToSelected :: GSConfig Window -> X ()
myGoToSelected = withSelectedWindow $ windowsNoSP . W.focusWindow

gsconfig2 colorizer = (buildDefaultGSConfig colorizer) { gs_cellheight = 50, gs_cellwidth = 200 }


------------------------------------------------------------------------
-- Colors and borders

-- Color of current window title in xmobar.
xmobarTitleColor = background
xmobarCurrentBackground = color4
xmobarCurrentForeground = background

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#51AFEF"

-- Width of the window border in pixels.
myBorderWidth = 2

myNormalBorderColor     = color8
myFocusedBorderColor    = color4

base03  = "#002b36"
base02  = "#073642"
base01  = "#586e75"
base00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#fdf6e3"
yellow  = "#b58900"
orange  = "#cb4b16"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"

foreground   = "#d5c4a1"
background   = "#1d2021"
cursor       = "#d5c4a1"

color0       = "#1d2021"
color8       = "#665c54"

color1       = "#fb4934"
color9       = "#cc241d"

color2       = "#b8bb26"
color10      = "#b8bb26"

color3       = "#fabd2f"
color11      = "#fabd2f"

color12       = "#458588"
color4      = "#83a598"

color5       = "#d3869b"
color13      = "#d3869b"

color6       = "#8ec07c"
color14      = "#8ec07c"

color7       = "#d5c4a1"
color15      = "#fbf1c7"

-- sizes
gap         = 0
topbar      = 5
border      = 0
prompt      = 5
status      = 5

active      = blue
activeWarn  = color1
inactive    = base02
focusColor  = blue
unfocusColor = base02

-- myFont      = "-*-Zekton-medium-*-*-*-*-160-*-*-*-*-*-*"
-- myBigFont   = "-*-Zekton-medium-*-*-*-*-240-*-*-*-*-*-*"
-- myFont      = "xft:Inconsolata Nerd Font:size=9:bold:antialias=true"
-- myBigFont   = "xft:Inconsolata Nerd Font:size=9:bold:antialias=true"
-- myWideFont  = "xft:Inconsolata Nerd Font:"
--             ++ "style=Regular:pixelsize=180:hinting=true"

myFont      = "Utf8:JetBrains Mono:size=9:bold:antialias=true"
myBigFont   = "Utf8:JetBrains Mono:size=9:bold:antialias=true"
myWideFont  = "Utf8:JetBrains Mono:"
            ++ "style=Regular:pixelsize=180:hinting=true"
-- this is a "fake title" used as a highlight bar in lieu of full borders
-- (I find this a cleaner and less visually intrusive solution)
topBarTheme = def
    {
      fontName              = myFont
    , activeColor           = color4
    , inactiveColor         = color8
    , activeBorderColor     = color4
    , inactiveBorderColor   = color8
    , activeTextColor       = color4
    , inactiveTextColor     = color8
    , urgentBorderColor     = color1
    , urgentTextColor       = color1
    , decoHeight            = topbar
    }

-- addTopBar =  noFrillsDeco shrinkText topBarTheme

myTabTheme = def
    -- { fontName = "xft:LiberationSans-Bold:size=9:antialias=true,ipamincho:size=10"
    { fontName = "xft:Sarasa Gothic J:size=9:antialias=true"
    , activeColor           = color4
    , inactiveColor         = color8
    , activeBorderColor     = color4
    , inactiveBorderColor   = color8
    , activeTextColor       = background
    , inactiveTextColor     = foreground
    , decoHeight            = 16
    }

--

scratchpads = [
  NS "todo" spawnTerm findTerm manageTerm,
  NS "gen" spawnGen findGen manageTerm,
  NS "wiki" spawnWiki findWiki nonFloating
              ]
  where 
    role = stringProperty "WM_WINDOW_ROLE"
    -- spawnTerm = "GLFW_IM_MODULE=ibus kitty --name scratchpad --session ~/.config/kitty/todo.conf"
    -- spawnWiki = "GLFW_IM_MODULE=ibus kitty --name scratchpad_wiki --session ~/.config/kitty/vimwiki.conf"
    -- spawnGen = "GLFW_IM_MODULE=ibus kitty --name scratchpad_gen --title Scratchpad"
    spawnTerm = "st -c scratchpad -t Todo -e nvim ~/vimwiki/Reminder.wiki"
    spawnWiki = "st -c scratchpad_wiki -t Wiki -e nvim -c VimwikiIndex"
    spawnGen = "st -c scratchpad_gen -t Scratchpad"

    findTerm = resource =? "scratchpad"
    findGen = resource =? "scratchpad_gen"
    findWiki = resource =? "scratchpad_wiki"
    manageTerm = customFloating $ W.RationalRect l t w h -- and I'd like it fixed using the geometry below
      where
        -- reusing these variables is ok since they're confined to their own 
        -- where clauses 
        h = (1/2)       -- height, 10% 
        w = (1/2)       -- width, 100%
        t = 0.1            -- bottom edge
        l = (1 - w)/2-- centered left/right


------------------------------------------------------------------------
-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--

myModMask = mod4Mask
altMask = mod1Mask


myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ----------------------------------------------------------------------
  -- Custom key bindings
  --
  [
  ((modMask .|. controlMask .|. shiftMask, xK_k),
  spawn "xkill")
  , ((modMask .|. controlMask, xK_space),
  selectLayout)
  ]
  ++
  [
  ((modMask, xK_bracketright),
     spawn "~/.xmonad/pomobar.sh")
  , ((modMask .|. shiftMask, xK_bracketright),
     spawn "~/.xmonad/pomobar_stop.sh")
  ]
  ++
  [
   ((modMask, xK_v ), windows copyToAll) -- @@ Make focused window always visible
 , ((modMask .|. shiftMask, xK_v ),  killAllOtherCopies) -- @@ Toggle window state back
 , ((modMask .|. shiftMask, xK_c     ), kill1) -- @@ Close the focused window
  ]
  ++
  [
   ((modMask, xK_bracketleft), myGoToSelected $ gsconfig2 defaultColorizer)
   , ((modMask, xK_F8), spawn "~/.scripts/displayselect")
  ]
  ++
  [ ((modMask, xK_d),
     treeselectAction tsDefaultConfig)
  -- Start a terminal.  Terminal to start is specified by myTerminal variable.

   , ((modMask .|. altMask, xK_Return),
     spawn $ XMonad.terminal conf)

  -- Lock the screen using command specified by myScreensaver.
  , ((controlMask .|. altMask, xK_l),
     spawn myScreensaver)

  -- Spawn the launcher using command specified by myLauncher.
  -- Use this to launch programs without a key binding.
  , ((modMask, xK_p),
     spawn myLauncher)

  , ((modMask .|. shiftMask, xK_Return),
      spawn "pcmanfm-qt \"`xcwd`\"")
  -- Take a full screenshot using the command specified by myScreenshot.
  , ((modMask, xK_Print),
     spawn myScreenshot)

  , ((modMask .|. shiftMask .|. controlMask, xK_F8),
    spawn "~/.scripts/dmenurecord")
  -- Take a selective screenshot using the command specified by mySelectScreenshot.
  , ((modMask .|. shiftMask, xK_Print),
     spawn mySelectScreenshot)

  -- , ((modMask, xK_space),
     -- spawn "~/.scripts/Toggle_Ibus.sh")

  -- Toggle current focus window to fullscreen
  , ((modMask, xK_f), sendMessage $ Toggle FULL)
  , ((modMask, xK_s), sendMessage $ TL.Toggle "[S]")
  , ((modMask .|. shiftMask, xK_p), sendMessage $ JumpToLayout "[T]")

  -- Mute volume.
  , ((0, xF86XK_AudioMute),
     spawn "~/.scripts/volume_change.sh toggle")

  -- Decrease volume.
  , ((0, xF86XK_AudioLowerVolume),
     spawn "~/.scripts/volume_change.sh 4%-")

  -- Increase volume.
  , ((0, xF86XK_AudioRaiseVolume),
     spawn "~/.scripts/volume_change.sh 4%+")

  , ((0, xF86XK_MonBrightnessUp),
      spawn "~/.scripts/brightness_change.sh +")
          
  , ((0, xF86XK_MonBrightnessDown),
      spawn "~/.scripts/brightness_change.sh -")
  -- Audio previous.
  , ((0, 0x1008FF16),
     spawn "")

  -- Play/pause.
  , ((0, 0x1008FF14),
     spawn "")

  -- Audio next.
  , ((0, 0x1008FF17),
     spawn "")

  -- Eject CD tray.
  , ((0, 0x1008FF2C),
     spawn "eject -T")

  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Close focused window.
  , ((modMask .|. shiftMask, xK_w),
     kill)

  -- Cycle through the available layout algorithms.
  , ((modMask .|. altMask, xK_space),
     sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  , ((modMask, xK_n),
     refresh)

  -- Move focus to the next window.
  , ((modMask, xK_j),
     windows W.focusDown)
  -- Move focus to the previous window.
  , ((modMask, xK_k),
     windows W.focusUp)
  , ((modMask .|. altMask, xK_j),
    BR.focusDown)

  , ((modMask .|. altMask, xK_k),
    BR.focusUp)

  -- Move focus to the master window.
  , ((modMask, xK_m),
     windows W.focusMaster  )

  -- Swap the focused window and the master window.
  , ((modMask, xK_Return),
     windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j),
     windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k),
     windows W.swapUp)

  -- Shrink the master area.
  , ((modMask, xK_h),
     sendMessage Shrink)

  -- Expand the master area.
  , ((modMask, xK_l),
     sendMessage Expand)
  -- , ((modMask, xK_a), sendMessage ShrinkSlave) -- %! Shrink a slave area
  -- , ((modMask, xK_z), sendMessage ExpandSlave) -- %! Expand a slave area
  --
  , ((modMask, xK_z), incWindowSpacing 2) -- %! Inc Gap
  , ((modMask, xK_x), decWindowSpacing 2) -- %! Dec Gap
  , ((modMask .|. shiftMask, xK_a), setScreenWindowSpacing 0) -- %! Inc Gap
  , ((modMask , xK_a), toggleWindowSpacingEnabled) -- %! Inc Gap

  -- Push window back into tiling.
  , ((modMask, xK_t),
     withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma),
     sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period),
     sendMessage (IncMasterN (-1)))

  -- Toggle the status bar gap.
  -- TODO: update this binding with avoidStruts, ((modMask, xK_b),

  -- Quit xmonad.
  , ((modMask .|. altMask, xK_q),
     io (exitWith ExitSuccess))

  -- Restart xmonad.
  , ((modMask .|. altMask, xK_r),
     restart "xmonad" True)
  ]
  ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  -- mod-control-shift-[1..9] @@ Copy client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask), (copy, shiftMask .|. controlMask)]]
  ++

  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  -- [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
  --     | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
  --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
  -- ++
  -- Bindings for manage sub tabs in layouts please checkout the link below for reference
  -- https://hackage.haskell.org/package/xmonad-contrib-0.13/docs/XMonad-Layout-SubLayouts.html
  [
    -- Tab current focused window with the window to the left
    ((modMask .|. controlMask, xK_h), sendMessage $ pullGroup L)
    -- Tab current focused window with the window to the right
  , ((modMask .|. controlMask, xK_l), sendMessage $ pullGroup R)
    -- Tab current focused window with the window above
  , ((modMask .|. controlMask, xK_k), sendMessage $ pullGroup U)
    -- Tab current focused window with the window below
  , ((modMask .|. controlMask, xK_j), sendMessage $ pullGroup D)

  -- Tab all windows in the current workspace with current window as the focus
  , ((modMask .|. controlMask, xK_m), withFocused (sendMessage . MergeAll))
  -- Group the current tabbed windows
  , ((modMask .|. controlMask, xK_u), withFocused (sendMessage . UnMerge))

  -- Toggle through tabes from the right
  , ((modMask, xK_Tab), onGroup W.focusDown')
  ]

  ++
  [ ((modMask, xK_u), namedScratchpadAction scratchpads "todo")
   , ((modMask, xK_i), namedScratchpadAction scratchpads "wiki")
   , ((modMask, xK_g), namedScratchpadAction scratchpads "gen")
  ]
  ++
  [
    ((modMask, xK_o), shellPrompt myXPromptConfig)
    , ((modMask .|. shiftMask, xK_o), spawn "~/.scripts/mpdmenu")
  ]
  ++
  [
   ((modMask .|. controlMask              , xK_equal ), sendMessage Mag.MagnifyMore)
   , ((modMask .|. controlMask              , xK_minus), sendMessage Mag.MagnifyLess)
  ]
  ++
  [
      ((modMask  .|. controlMask              , xK_s    ), sendMessage  Arrange         )
      , ((modMask .|. controlMask .|. shiftMask, xK_s    ), sendMessage  DeArrange       )
      , ((modMask.|. controlMask              , xK_Left ), sendMessage (MoveLeft      valueInt))
      , ((modMask.|. controlMask              , xK_Right), sendMessage (MoveRight     valueInt))
      , ((modMask.|. controlMask              , xK_Down ), sendMessage (MoveDown      valueInt))
      , ((modMask.|. controlMask              , xK_Up   ), sendMessage (MoveUp        valueInt))
      , ((modMask.|. shiftMask, xK_Left ), sendMessage (IncreaseLeft  valueInt))
      , ((modMask.|. shiftMask, xK_Right), sendMessage (IncreaseRight valueInt))
      , ((modMask.|. shiftMask, xK_Down), sendMessage (IncreaseDown valueInt))
      , ((modMask.|. shiftMask, xK_Up), sendMessage (IncreaseUp valueInt))
      , ((modMask.|. controlMask .|. shiftMask, xK_Left ), sendMessage (DecreaseLeft  valueInt))
      , ((modMask.|. controlMask .|. shiftMask, xK_Right), sendMessage (DecreaseRight valueInt))
      , ((modMask.|. controlMask .|. shiftMask, xK_Down ), sendMessage (DecreaseDown  valueInt))
      , ((modMask.|. controlMask .|. shiftMask, xK_Up   ), sendMessage (DecreaseUp   valueInt))
  ] 
  where 
    valueInt :: Int 
    valueInt = 50

------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    ((modMask .|. controlMask, button1),
      -- (\w -> focus w >> mouseResizeWindow w >> afterDrag (withFocused $ windows . W.sink)))
      (\w -> focus w >> mouseResizeWindow w))
    , ((modMask, button1),
    (\w -> focus w >> mouseMoveWindow w ))
    , ((modMask, button2),
       (\w -> focus w >> mouseResizeWindow w))
  ]


------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  setWMName "LG3D"
  spawn     "~/.xmonad/startup.sh"
  setWindowSpacingEnabled False
  spawnOnce     "picom -b"
  setDefaultCursor xC_left_ptr

------------------------------------------------------------------------

myBackgroundColor = background

myContentColor = foreground


myXPromptConfig :: XPConfig
myXPromptConfig =
  XPC
    { promptBorderWidth = 3
    , font = "xft:Sarasa Gothic J:size=12:antialias=true"
    , alwaysHighlight = True
    , height = 30
    , historySize = 256
    , bgColor = myBackgroundColor
    , fgColor = myContentColor
    , bgHLight = color4
    , fgHLight = myBackgroundColor
    , borderColor = color4
    , position = Top
    , autoComplete = Nothing
    , showCompletionOnTab = False
    , searchPredicate = fuzzyMatch
    , defaultPrompter = id
    , sorter = const id
    , maxComplRows = Just 5
    , promptKeymap = defaultXPKeymap
    , completionKey = (0, xK_Tab)
    , changeModeKey = xK_grave
    , historyFilter = id
    , defaultText = []
    }

------------------------------------------------------------------------

padding = replicate 10 ' '

-- Run xmonad with all the defaults we set up.


main = do

  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc.hs"


  xmonad $ docks
         $ withNavigation2DConfig myNav2DConf
         $ additionalNav2DKeys (xK_Up, xK_Left, xK_Down, xK_Right)
                               [
                                  (mod4Mask,               windowGo  )
                                -- , (mod4Mask .|. shiftMask, windowSwap)
                               ]
                               False
         $ ewmh
         $ defaults {
         logHook = dynamicLogWithPP (namedScratchpadFilterOutWorkspacePP xmobarPP {
                ppCurrent = xmobarColor xmobarCurrentForeground xmobarCurrentBackground . wrap ("<box type=Full color=" ++ color4 ++ ">")  " </box>"
                -- Hidden workspaces (no windows)
                , ppHiddenNoWindows = xmobarColor color8 "" .wrap ("<box type=Full color=" ++ background ++ ">")  " </box>"
                 -- Visible but not current workspace (Xinerama only)
                , ppVisible = xmobarColor color4 "" .wrap ("<box type=Full color=" ++ background ++ ">")  " </box>"
                 -- Hidden workspaces in xmobar
                , ppHidden = xmobarColor color4  "" .wrap ("<box type=Full color=" ++ background ++ ">")  " </box>"
                , ppSep = ""
               , ppLayout = xmobarColor background color2 .wrap ("<action=xdotool key super+alt+space><box type=Full color=" ++ color2 ++ "><fn=1> ") " </fn></box></action>"
                , ppTitle = xmobarColor color2 "" . wrap ("<fn=2> ")  " </fn>"
                , ppOutput = hPutStrLn xmproc
         })
         -- >> updatePointer (0.75, 0.75) (0.75, 0.75)
      }

------------------------------------------------------------------------

defaults = def {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- key bindings
    keys               = myKeys,
    mouseBindings      = myMouseBindings,
    handleEventHook = handleEventHook def <+> docksEventHook <+> fullscreenEventHook,
    -- handleEventHook = serverModeEventHookCmd <+> serverModeEventHook <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn) <+> docksEventHook <+> fullscreenEventHook,
    -- hooks, layouts
    layoutHook         = myLayout,
    -- handleEventHook    = handleEventHook def <+> fullscreenEventHook,
    manageHook         = namedScratchpadManageHook scratchpads <+> manageDocks <+> myManageHook,
    startupHook        = myStartupHook
}
