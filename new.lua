--{{{ Required
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
local tyrannical = require("tyrannical")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")
local lain       = require("lain")
local revelation = require("revelation")
local awesompd = require("awesompd/awesompd")

-- Shortcuts
local shorter = require("shorter")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")

-- Keydoc
local keydoc = require("keydoc")
--}}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

run_once( os.getenv("HOME") .. "/.config/awesome/themes/steamburn/.fehbg")
run_once("compton -CGb")
run_once("nm-applet")
run_once("thunar --daemon")
run_once("urxvtd")
run_once("xfce4-power-manager")
-- }}}

-- {{{ Variable definitions
-- localization
os.setlocale(os.getenv("LANG"))

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/steamburn/theme.lua")

-- revelation
revelation.init()

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "brackets" or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"
altkey = "Mod1"

-- user defined
browser    = "chromium"
gui_editor = "gvim"
graphics   = "gimp"

-- lain
lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol    = 1

local layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.max,
    lain.layout.uselessfair.horizontal,
    lain.layout.uselesstile,
    lain.layout.uselessfair,
    lain.layout.termfair,
    lain.layout.uselesspiral.dwindle,
    lain.layout.centerfair,
    lain.layout.cascade,
    lain.layout.cascadetile,
    lain.layout.centerwork
}
-- }}}

-- First, set some settings
tyrannical.settings.default_layout =  awful.layout.suit.floating
tyrannical.settings.mwfact = 0.66

-- {{{ Tags
tyrannical.tags = {
    {
        -- Main
        name        = "♻",
        init        = true,
        exlusive    = false,
        screen      = {1},
        layout      = awful.layout.suit.floating,
        class       = {}
    },
    {
        -- Term
        name        = "⌥",                 -- Call the tag "Term"
        init        = false,                   -- Load the tag on startup
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {1},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.floating, -- Use the tile layout
        instance    = {"dev", "ops"},         -- Accept the following instances. This takes precedence over 'class'
        class       = { --Accept the following classes, refuse everything else (because of "exclusive=true")
                        "xterm" , "urxvt" , "URxvt" ,"XTerm"
        }
    } ,
    {
        -- Web
        name        = "✉",
        init        = true,
        exclusive   = true,
        screen      = 1,
        layout      = lain.layout.cascadetile,
        exec_once   = { "chromium" },
        class       = { "Chromium", "Deluge", "Deluge-Gtk" }
    } ,
    {
        -- Files
        name        = "☭",
        init        = false,
        exclusive   = false,
        screen      = 1,
        layout      = lain.layout.cascadetile,
        -- exec_once   = {"Thunar"}, When the tag is accessed for the first time, execute this command
        class       = { "Thunar", "Xarchiver" }
    } ,
    {
        -- Dev
        name        = "⚡",
        init        = false,
        exclusive   = true,
        screen      = 1,
        layout      = lain.layout.cascadetile,
        class       = { "Gvim", "Atom", "Brackets" }
    } ,
    {
        -- Media
        name        = "‣",
        init        = false,
        exclusive   = true,
        screen      = 1,
        layout      = lain.layout.cascadetile,
        class       = { "Vlc" }
    },
    {
        -- Games
        name        = "☠",
        init        = false,
        exclusive   = true,
        screen      = 1,
        layout      = awful.layout.suit.floating,
        class       = { "Wine", "Steam", "PlayOnLinux" }
    },
    {
        name        = "doc",
        init        = false, -- This tag wont be created at startup, but will be when one of the
                             -- client in the "class" section will start. It will be created on
                             -- the client startup screen
        exclusive   = true,
        layout      = lain.layout.cascadetile,
        class       = { "Assistant","Okular", "Evince","EPDFviewer","xpdf","Xpdf","Zathura"}
    },
}

-- Ignore the tag "exclusive" property for the following clients (matched by classes)
tyrannical.properties.intrusive = {
    "feh", "Xephyr",
}

-- Ignore the tiled layout for the matching clients
tyrannical.properties.floating = {
    "Wine", "wine", "PlayOnLinux"
}

-- Make the matching clients (by classes) on top of the default layout
tyrannical.properties.ontop = {
    "Xephyr"
}

-- Force the matching clients (by classes) to be centered on the screen on init
tyrannical.properties.centered = {
    "urxvt", "Wine", "PlayOnLinux"
}

tyrannical.settings.block_children_focus_stealing = true --Block popups ()
tyrannical.settings.group_children = true --Force popups/dialogs to have the same tags as the parent client
-- }}}

-- Do not honor size hints request for those classes
tyrannical.properties.size_hints_honor = { xterm = false, URxvt = false, aterm = false, sauer_client = false, mythfrontend  = false}


-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "reload", awesome.restart },
   { "quit", awesome.quit },
   { "reboot", "reboot" },
   { "shutdown", "shutdown" }
}
 
appsmenu = {
   { "brackets", "brackets" },
   { "urxvt", "urxvt" },
   { "ncmpcpp", terminal .. " -e ncmpcpp" },
   { "chromium", "chromium" },
   { "thunar", "thunar" },
   { "ranger", terminal .. " -e ranger" },
   { "gvim", "gvim" },
   { "gimp", "gimp" },
   { "feh", "feh" },
   { "birdie", "birdie" },
   { "deluge", "deluge" },
   { "hexchat", "hexchat" },
   { "obs", "obs" },
   { "ssr", "simplescreenrecorder" },
   { "vlc", "vlc" },
   { "zathura", "zathura" },
   { "bleachbit", "bleachbit" },
   { "seahorse", "seahorse" }
}
 
gamesmenu = {
   { "banished", "primusrun /usr/share/playonlinux/playonlinux --run 'Banished' %F" },
   { "bo-isaac", "primusrun /usr/share/playonlinux/playonlinux --run 'isaac' %F" },
   { "cs:go", "primusrun steam steam://rungameid/730" },
   { "cs:source", "primusrun steam steam://rungameid/240" },
   { "don't starve", "primusrun steam steam://rungameid/219740" },
   { "dota 2", "primusrun steam steam://rungameid/570" },
   { "half-life", "primusrun steam steam://rungameid/70" },
   { "half-life 2", "primusrun steam steam://rungameid/220" },
   { "hl2: episode one", "primusrun steam steam://rungameid/380" },
   { "league of legends", "primusrun /usr/share/playonlinux/playonlinux --run 'League of Legends' %F" },
   { "minecraft", "primusrun minecraft" },
   { "osu!", "primusrun /usr/share/playonlinux/playonlinux --run 'osu!' %F" },
   { "playonlinux", "primusrun playonlinux" },
   { "portal", "primusrun steam steam://rungameid/400" },
   { "portal 2", "primusrun steam steam://rungameid/620" },
   { "steam" , "primusrun steam" },
   { "witcher 2", "primusrun steam steam://rungameid/20920" }
}
 
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu },
                                    { "apps", appsmenu },
                				    { "games", gamesmenu },
                                    { "file manager", "thunar"},
                                    { "terminal", terminal },
				                    { "web browser", browser },
				                    { "text editor", geditor }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
markup = lain.util.markup
gray   = "#94928F"

-- Create a textclock widget
mytextclock = awful.widget.textclock(" %H:%M ")

--{{{ Calendar
lain.widgets.calendar:attach(mytextclock)
--}}}

--{{{ Mpd
musicwidget = awesompd:create()
musicwidget.font = "Tamsyn" 
musicwidget.scrolling = true
musicwidget.output_size = 30
musicwidget.update_interval = 5
musicwidget.path_to_icons = (os.getenv("HOME") .. "/.config/awesome/awesompd/icons")
musicwidget.jamendo_format = awesompd.FORMAT_MP3
musicwidget.show_album_cover = true
musicwidget.album_cover_size = 50
musicwidget.mpd_config = (os.getenv("HOME") .. "/.mpd/mpd.conf")
musicwidget.browser = "chromium"
musicwidget.ldecorator = " "
musicwidget.rdecorator = " "
  
musicwidget.servers = {
     { server = "localhost",
          port = 6600 } }
 
musicwidget:register_buttons({ { "", awesompd.MOUSE_LEFT, musicwidget:command_playpause() },
                               { "", awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
 			                   { "", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
 			                   { "", awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() }  
                            })

musicwidget:run()
---}}}

-- ALSA volume
volumewidget = lain.widgets.alsa({
    settings = function()
        header = " Vol "
        vlevel  = volume_now.level

        if volume_now.status == "off" then
            vlevel = vlevel .. "M "
        else
            vlevel = vlevel .. " "
        end

        widget:set_markup(markup(gray, header) .. vlevel)
    end
})

-- Separator
first = wibox.widget.textbox(markup.font("Tamsyn 4", " "))
spr = wibox.widget.textbox(' ')

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
txtlayoutbox = {}
mytaglist = {}
mytasklist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end))
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

-- Writes a string representation of the current layout in a textbox widget
function updatelayoutbox(layout, s)
    local screen = s or 1
    local txt_l = beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(screen))] or ""
    layout:set_text(txt_l)
end

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    txtlayoutbox[s] = wibox.widget.textbox(beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(s))])
    awful.tag.attached_connect_signal(s, "property::selected", function ()
        updatelayoutbox(txtlayoutbox[s], s)
    end)
    awful.tag.attached_connect_signal(s, "property::layout", function ()
        updatelayoutbox(txtlayoutbox[s], s)
    end)
    txtlayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Empty wibox for conky
    -- mystatusbar = awful.wibox({ position = "bottom", screen = 1, ontop = false, width = 1, height = 16 })
    
    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(first)
    left_layout:add(mytaglist[s])
    left_layout:add(spr)
    left_layout:add(txtlayoutbox[s])
    left_layout:add(spr)
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(spr)
    right_layout:add(musicwidget.widget)
    right_layout:add(volumewidget)
    right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}



-- Add keyboard shortcuts
dofile(awful.util.getdir("config") .. "/shortcuts.lua")

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
	                 size_hints_honor = false } },

    { rule = { class = "URxvt" },
          properties = { opacity = 0.99 } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized_horizontal = true,
                         maximized_vertical = true,
                        floating = true } },

    { rule = { role = "_NET_WM_STATE_FULLSCREEN" },
         properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_color = beautiful.border_normal
        else
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do -- Floaters always have borders
                if awful.client.floating.get(c) or layout == "floating" then
                    c.border_width = beautiful.border_width

                -- No borders with only one visible client
                elseif #clients == 1 or layout == "max" then
                    clients[1].border_width = 0
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
      end)
end
-- }}}
