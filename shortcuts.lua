local awful        = require( "awful"       )
local shorter      = require( "shorter" )

shorter.Navigation = {
     desc = "Navigate between clients by direction",

    -- By direction client focus
    { desc = "Move down to client",
        key = {{ modkey }, "j" },
        fct = function ()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end
    },
    
    { desc = "Move to client on top",
        key = {{ modkey }, "k" },
        fct = function ()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end
    },

    { desc = "Move to client on Left"
      fct = function ()
          awful.client.focus.bydirection("left")
          if client.focus then client.focus:raise() end
      end
    },

    { desc = "Move to client on right",
      key = {{ modkey }, "l" },
      fct = function ()
          awful.client.focus.bydirection("right")
          if client.focus then client.focus:raise() end
      end
    },

    { desc = "Revelation",
      key = {{ modkey }, "e" },
      fct = function ()
                revelation
        end
    },
}

shorter.Launch = {
    
    { desc = "Launch a terminal",
      key = {{ modkey }, "Return" },
      fct = function ()
            awful.util.spawn(terminal)
        end },

    { desc = "Show Application menu",
      key = {{ modkey }, "p" },
      fct = function ()
            mymainmenu:show({ keygrabber = true})
        end },

    { desc = "Run a command",
      key={{  modkey },            "r"},
      fct = function ()
            awful.prompt.run({ prompt = "Run: ", hooks = {
                {{ },"Return",function(command)
                    local result = awful.util.spawn(command)
                    mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                    return true
                end},
                {{ "Mod1" },"Return",function(command)
                    local result = awful.util.spawn(command,{intrusive=true})
                    mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                    return true
                end},
                {{ "Shift" },"Return",function(command)
                    local result = awful.util.spawn(command,{intrusive=true,ontop=true,floating=true})
                    mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                    return true
                end}
            }},
            mypromptbox[mouse.screen].widget,
            function (com)
                    local result = awful.util.spawn(com)
                    if type(result) == "string" then
                        mypromptbox[mouse.screen].widget:set_text(result)
                    end
                    return true
            end, awful.completion.shell,
            awful.util.getdir("cache") .. "/history")
        end
    },
}

shorter.Session = {
    { desc = "Restart Awesome",
      key = {{ modkey, "Control" }, "r" },
      fct = awesome.restart },

    { desc = "Quit Awesome",
      key = {{ modkey, "Shift" }, "q" },
      fct = awesome.quit },
}

-- {{{ Mouse bindings 
root.buttons( awful.util.table.join (
    awful.button({ }, 3, function () end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

