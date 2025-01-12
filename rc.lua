-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")



-- This is used later as the default terminal and editor to run.
terminal   = "konsole"
editor     = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
HOME       = "/home/mohammedaouamri"
SCRIPTS    = HOME .. "/" .. ".scripts/"

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}



local function init_copyq()
    local function is_copyq_running()
        local handle = io.popen("pgrep -x copyq")
        local result = handle:read("*a")
        handle:close()
        return result ~= ""
    end

    -- Spawn copyq if it's not already running
    if not is_copyq_running() then
        awful.spawn("copyq")
    end
end


local function init_gromitmpx()
    local function is_gromitmpx_running()
        local handle = io.popen("pgrep -x gromit-mpx")
        local result = handle:read("*a")
        handle:close()
        return result ~= ""
    end

    -- Spawn copyq if it's not already running
    if not is_gromitmpx_running() then
        awful.spawn("gromit-mpx")
    end
end


local function init_flameshot()
    local function is_flameshot_running()
        local handle = io.popen("pgrep -x flameshot")
        local result = handle:read("*a")
        handle:close()
        return result ~= ""
    end

    -- Spawn copyq if it's not already running
    if not is_flameshot_running() then
        awful.spawn("flameshot")
    end
end


local function init()
    beautiful.init("~/.config/awesome/monokai/theme.lua")

    -- init-wallpaper
    awful.spawn("zsh " .. HOME .. "/" .. ".fehbg");

    -- init-clipboard
    init_copyq()

    -- init-gromit-mpx
    init_gromitmpx()

    -- init-screen-shoots
    init_flameshot()
end

init()




-- {{{ Variable definitions
-- Themes define colours, icns, font and wallpapers.


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
--
awful.layout.layouts = {
    awful.layout.suit.spiral,
    -- awful.layout.suit.tile,
    awful.layout.suit.tile.right,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}


function get_wallpaper(path)
    path = path or "/home/mohammedaouamri/.wallpaper"
    local matches = {}

    -- Use `ls` to list files
    local p = io.popen("ls -1 " .. path)
    if not p then
        error("Failed to open directory: " .. path)
    end

    for file in p:lines() do
        table.insert(matches, { file,
            function()
                awful.spawn("feh --bg-fill  " .. path .. "/" .. file)
            end
        })
    end

    p:close()
    return matches
end

mymainmenu = awful.menu({
    items =


    {
        { "awesome",       myawesomemenu, beautiful.awesome_icon },
        -- get_wallpaper_widget(),
        { "open terminal", terminal },
        { "Wallpapers", function()
            awful.spawn(SCRIPTS .. "/" .. "awesome" .. "/" .. "wallselect.sh")
        end }
    }
})

mylauncher = require("menu");
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()
mykeyboardlayout.layouts = { "fr", "ara" }
local current_index = 1

-- Function to cycle through layouts
local function cycle_layout()
    current_index = (current_index % #mykeyboardlayout.layouts) + 1
    local next_layout = mykeyboardlayout.layouts[current_index]
    os.execute("setxkbmap " .. next_layout)
    -- mykeyboardlayout:set_layout(next_layout)
end

-- Add a button to cycle layouts on click
mykeyboardlayout:buttons(
    gears.table.join(
        awful.button({}, 1, function() -- Left mouse button
            cycle_layout()
        end)
    )
)

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock("   |   %b %d %a %I:%M")


-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "一 ", "二 ", "三 ", "四 ", "五 ", "六 ", "七 ", "八 ", "九 " }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    local awful = require("awful")
    local wibox = require("wibox")

    -- Create a textbox widget

    local cava_widget = wibox.widget {
        widget = wibox.widget.textbox,
        -- align = "center",

        valign = "center",
        font = "FiraCodeNerdFont 16"
    }
    -- Update the widget with Cava data
    awful.spawn.with_line_callback(SCRIPTS .. "awesome" .. "/" .. "cava.sh", {
        stdout = function(line)
            cava_widget.text = line
        end
    })

    local battery_widget = wibox.widget {
        widget = wibox.widget.textbox,
        -- align = "center",
        valign = "center",
        font = "FiraCodeNerdFont 16"
    }

    awful.spawn.with_line_callback(SCRIPTS .. "awesome" .. "/" .. "battery.sh", {
        stdout = function(line)
            battery_widget.text = line
        end
    })

    local volum_widget = wibox.widget {
        widget = wibox.widget.textbox,
        -- align = "center",
        valign = "center",
        font = "FiraCodeNerdFont 16"
    }

    awful.spawn.with_line_callback(SCRIPTS .. "awesome" .. "/" .. "volum.sh", {
        stdout = function(line)
            volum_widget.text = line
        end
    })

    -- Periodically update the widget
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        -- acavalier_button,

        cava_widget,
        -- awful.widget.text()
        -- s.mytasklist, -- Middle widget
        --
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            volum_widget,
            battery_widget,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(

    awful.key({ modkey, }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    awful.key({ modkey, }, "w", function() mymainmenu:show() end,
        { description = "show main menu", group = "awesome" }),
    awful.key({ modkey }, "a", function() awful.spawn("rofi -show drun -theme ~/.config/rofi/styles/style_7.rasi   ") end,
        { description = "launch rofi run", group = "launcher" }),
    awful.key({ modkey }, "e", function() awful.spawn("dolphin") end,
        { description = "launch dolphin", group = "launcher" }),
    awful.key({ modkey }, "f", function() awful.spawn("firefox-nightly") end,
        { description = "launch firefox nightly ", group = "launcher" }),
    awful.key({ modkey }, "space", function() awful.spawn("krunner") end,
        { description = "launch krunner", group = "launcher" }),
    awful.key({ modkey }, "t", function() awful.spawn(terminal) end,
        { description = "launch " .. terminal, group = "launcher" }),
    awful.key({ modkey }, "XF86MonBrightnessUp", function() awful.spawn("brillo -A 15") end,
        { description = "brightness", group = "control" }),
    awful.key({ modkey }, "XF86MonBrightnessDown", function() awful.spawn("brillo -U 15") end,
        { description = "brightness", group = "control" }),

    -- Layout manipulation

    awful.key({ modkey, }, "v", function()
            init_copyq();
            awful.spawn("copyq show")
        end,
        { description = "show the clipboard", group = "clipboard" }),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),
    awful.key({ modkey, }, "j", function() awful.client.focus.byidx(1) end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key({ modkey, }, "k", function() awful.client.focus.byidx(-1) end,
        { description = "focus previous by index", group = "client" }
    ),
    awful.key({ modkey, "Shift" }, "j", awful.tag.viewprev,
        { description = "to previous workspace", group = "tag" }),
    awful.key({ modkey, "Shift" }, "k", awful.tag.viewnext,
        { description = "to next workspace", group = "tag" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, "Shift", "Mod1" }, "j", function()
        local c = client.focus
        if c then
            local screen = awful.screen.focused()
            local prev_tag = screen.tags[screen.selected_tag.index - 1] or screen.tags[9]
            c:move_to_tag(prev_tag)
            awful.tag.viewprev()
        end
    end),
    awful.key({ modkey, "Shift", "Mod1" }, "k", function()
        local c = client.focus
        if c then
            local screen = awful.screen.focused()
            local next_tag = screen.tags[screen.selected_tag.index + 1] or screen.tags[1]
            c:move_to_tag(next_tag)
            awful.tag.viewnext()
        end
    end),




    -- Standard program

    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),


    -- awful.key({ modkey,           }, "space", function () awful.layout.inc( )                end,
    --           {description = "select next", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    --           {description = "select previous", group = "layout"}),






    -- NOTE : audio
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn("/home/mohammedaouamri/.scripts/increase_volume")
    end, { description = "increase volume", group = "media" }),

    -- Volume Down
    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -10%")
    end, { description = "decrease volume", group = "media" }),

    -- Mute/Unmute Audio
    awful.key({}, "XF86AudioMute", function()
        awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    end, { description = "toggle mute", group = "media" }),

    -- Mute/Unmute Microphone
    awful.key({}, "XF86AudioMicMute", function()
        awful.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle")
    end, { description = "toggle mic mute", group = "media" }),




    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Prompt
    awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }),

    awful.key({ modkey }, "x",
        function()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }),
    -- Menubar
    awful.key({ modkey }, "p", function() awful.spawn("flameshot gui") end,
        { description = "show the menubar", group = "launcher" })
)

clientkeys = gears.table.join(
    awful.key({ modkey, }, "F11",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, }, "q", function(c) c:kill() end,
        { description = "close", group = "client" }),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" })

--  awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
--      { description = "toggle keep on top", group = "client" })
--   awful.key({ modkey,           }, "n",
--       function (c)
--           -- The client currently has the input focus, so it cannot be
--           -- minimized, since minimized clients can't have the focus.
--           c.minimized = true
--       end ,
--       {description = "minimize", group = "client"}),
--   awful.key({ modkey,           }, "m",
--       function (c)
--           c.maximized = not c.maximized
--           c:raise()
--       end ,
--       {description = "(un)maximize", group = "client"}),
--   awful.key({ modkey, "Control" }, "m",
--       function (c)
--           c.maximized_vertical = not c.maximized_vertical
--           c:raise()
--       end ,
--       {description = "(un)maximize vertically", group = "client"}),
--   awful.key({ modkey, "Shift"   }, "m",
--       function (c)
--           c.maximized_horizontal = not c.maximized_horizontal
--           c:raise()
--       end ,
--       {description = "(un)maximize horizontally", group = "client"})

)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            floating = false, -- Ensure all windows default to non-floating (tiled)
        }
    },

    -- Floating clients (specific exceptions).
    {
        rule_any = {
            instance = {
                "DTA",   -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer"
            },
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true }
    },

    -- Rule for KRunner
    {
        rule = { class = "krunner" },
        properties = {
            floating = true,
            ontop = true,
            focus = true,
            placement = awful.placement.centered
        },
    },

    -- Specific rule for Konsole
    {
        rule = { class = "konsole" },
        properties = {
            floating = false,
            maximized = false,
            maximized_horizontal = false,
            maximized_vertical = false,
            size_hints_honor = false, -- Ensure no auto-resizing based on hints
        },
        callback = function(c)
            c:connect_signal("request::geometry", function()
                c.maximized = false
                c.maximized_horizontal = false
                c.maximized_vertical = false
            end)
        end,
    },

    -- Specific rule for Firefox Nightly
    {
        rule = { class = "firefox-nightly" },
        properties = {
            floating = false,
            maximized = false,
            maximized_horizontal = false,
            maximized_vertical = false,
            size_hints_honor = false, -- Ensure no auto-resizing based on hints
        },
        callback = function(c)
            c:connect_signal("request::geometry", function()
                c.maximized = false
                c.maximized_horizontal = false
                c.maximized_vertical = false
            end)
        end,
    },
}
-- }}}
---- Add a titlebar if titlebars_enabled is set to true in the rules.
if false then
    client.connect_signal("request::titlebars", function(c)
        -- buttons for the titlebar
        local buttons = gears.table.join(
            awful.button({}, 1, function()
                c:emit_signal("request::activate", "titlebar", { raise = true })
                awful.mouse.client.move(c)
            end),
            awful.button({}, 3, function()
                c:emit_signal("request::activate", "titlebar", { raise = true })
                awful.mouse.client.resize(c)
            end)
        )

        awful.titlebar(c):setup {
            { -- Left
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout  = wibox.layout.fixed.horizontal
            },
            { -- Middle
                { -- Title
                    align  = "center",
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout  = wibox.layout.flex.horizontal
            },
            { -- Right
                awful.titlebar.widget.floatingbutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.stickybutton(c),
                awful.titlebar.widget.ontopbutton(c),
                awful.titlebar.widget.closebutton(c),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
    end)
end

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
awful.spawn.with_shell("setxkbmap fr") -- Replace 'us' with your desired layout
