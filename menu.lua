
local awful = require("awful")
local beautiful = require("beautiful")


-- Define the main menu
local mymainmenu = awful.menu({
    items = {
        { "Open Terminal", "alacritty" }, -- Replace "alacritty" with your terminal
        { "Restart Awesome", awesome.restart },
        { "Quit Awesome", function() awesome.quit() end }
    }

})

-- Define the launcher widget
local mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

-- Return the launcher for use in rc.lua
return mylauncher
