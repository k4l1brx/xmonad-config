-- http://projects.haskell.org/xmobar/
-- install xmobar with these flags: --flags="with_alsa" --flags="with_mpd" --flags="with_xft"  OR --flags="all_extensions"
-- you can find weather location codes here: http://weather.noaa.gov/index.html


Config { font    = "xft:Inconsolata Nerd Font:size=9:antialias=true:hinting=true,Sarasa Gothic J:size=9:antialias=true:hinting=true"
       -- , additionalFonts = [ "xft:Wuncon Siji:pixelsize=13" ]
       , bgColor = "#1d2021"
       , fgColor = "#00acc1"
       -- On the Top, 1000% screen width
       , position = Top
       , lowerOnStart = True , hideOnStart = False
       , allDesktops = True
       , persistent = True
       , iconRoot = "/home/hts/.xmonad/xpm/"  -- default: "."
       , commands = [
                    Run Com "/home/hts/.xmonad/trayer-padding-icon.sh" [] "trayerpad" 10
                    , Run Battery        [ "--template" , "<fc=#83A598>\xf240  </fc><acstatus>"
                             , "--Low"      , "10"        -- units: %
                             , "--High"     , "80"        -- units: %
                             , "--low"      , "darkred"
                             , "--normal"   , "darkorange"
                             , "--high"     , "darkgreen"

                             , "--" -- battery specific options
                                       -- discharging status
                                       , "-o", "<left>% (<timeleft>)"
                                       -- AC "on" status
                                       , "-O", "<fc=#dAA520>Charging</fc> <left>%"
                                       -- chaged status
                                       , "-i", "<fc=#b8bb26>Charged</fc>"
                             ] 50

                      -- Time and date
                    , Run Date "<fc=#83a598></fc><fc=#FF0025,#83a598>\xf133 %H:%M %a %d %m %Y</fc>" "date" 50
                    , Run DynNetwork     [ "--template" , " <fc=#8ec07c><dev> \xf175<rx>KB \xf176<tx>KB</fc>"
                              ,"--Low"      , "1000"       -- units: B/s
                             , "--High"     , "5000"       -- units: B/s
                             , "--low"      , "darkgreen"
                             , "--normal"   , "darkorange"
                             , "--high"     , "darkred"
                             ] 10
                    , Run Wireless "" [
                    "--template", "<fc=#8ec07c><qualitybar></fc>"
                    ] 50

                      -- Volume control
                    , Run Alsa "pulse" "Master" ["-t", "<fc=#B8BB26>\xf028 <volume>%<status></fc>" 
                      
                    ]

                    , Run Kbd            [ ("de" , "<fc=#FABD2F>\xf40b  DE</fc>")
                             , ("us"         , "<fc=#FABD2F>\xf40b  US</fc>")
                             ]

                    , Run PipeReader "\xe386 Timer:/home/hts/.xmonad/fifo" "pipe"
                      -- Prints out the left side items such as workspaces, layout, etc.
                      -- The workspaces are set to be 'clickable' in .xmonad/xmonad.hs
                    , Run UnsafeStdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
           , template = "<action=`~/.scripts/rofi_app_launcher.sh`><fc=#FABD2F><icon=haskell_20.xpm/></fc></action> %UnsafeStdinReader% }{<fc=#1d2021,#83a598></fc><action=`kitty --session ~/.config/kitty/nmtui.conf`>%dynnetwork% %wi%</action><fc=#83a598></fc><fc=#fcfcfc></fc><action=`xfce4-power-manager-settings`> %battery% </action><fc=#fcfcfc></fc><action=`~/.scripts/Toggle_Keymap.sh`>%kbd%</action><fc=#fcfcfc></fc> %alsa:pulse:Master% <fc=#fb4934>%pipe%</fc> %date%<fc=#1d2021,#83a598></fc> %trayerpad%"
       }
