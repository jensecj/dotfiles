local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")


-- clock widget
mytextclock = awful.widget.textclock("%d/%m/%y - %H:%M", 30)


-- battery widget
mybattery = wibox.widget.textbox()
updatebattery = function()
   fh = assert(io.popen("acpi | tr -d ,% | tr -s ' ' '\n' | sed -n '3,4p'", "r"))
   batstat = fh:read("*l")
   batval = fh:read("*l")
   fh:close()

   if batstat == "Charging" then
      mybattery:set_text(batval .. "C")
   else
      mybattery:set_text(batval .. "%")
   end
end

mybattery:set_text("battery | ")
mybatterytimer = timer({ timeout = 60 })
mybatterytimer:connect_signal("timeout", updatebattery)
updatebattery()
mybatterytimer:start()


-- volume widget
myvolume = wibox.widget.textbox()
updatevolume = function()
   fh = assert(io.popen("amixer -c 1 sget Master | sed -n '5p' | tr -s ' ' '\n' | sed -n -e 5p -e 7p | tr -d []%", "r"))
   value = fh:read("*l")
   status = fh:read("*l")
   fh:close()

   if status == "on" then
      myvolume:set_text(value .. "%")
   else
      myvolume:set_text(value .. "M")
   end
end

updatevolume()

-- ram usage widget
myram = wibox.widget.textbox()
updateram = function ()
   fh = assert(io.popen("free -m | sed -n 3p | tr -s ' ' | tr -s ' ' '\n' | sed -n 3p", "r"))
   value = fh:read("*all")
   fh:close()

   active = tonumber(active)

   myram:set_text(value .. "MB")
end

myramtimer = timer({ timeout = 5 })
myramtimer:connect_signal("timeout", updateram)
updateram()
myramtimer:start()


-- cpu usage widget (TODO: fix, sometimes this goes above 100%)
mycpu = wibox.widget.textbox()
jiffies = {}
function activecpu ()
   local s = 0
   for line in io.lines("/proc/stat") do
      local cpu, newjiffies = string.match(line, "(cpu%d*) +(%d+)")
      if cpu and newjiffies then
         if not jiffies[cpu] then
            jiffies[cpu] = newjiffies
         end
         --The string.format prevents your task list from jumping around
         --when CPU usage goes above/below 10%
         s = s + tonumber(newjiffies-jiffies[cpu])
         jiffies[cpu] = newjiffies
      end
   end
   return s
end

updatecpu = function ()
   mycpu:set_text(string.format("%d", (activecpu()/8)) .. "%")
end

mycputimer = timer({ timeout = 3 })
mycputimer:connect_signal("timeout", updatecpu)
updatecpu()
mycputimer:start()


-- hdd usage widget
myhdd = wibox.widget.textbox()
updatehdd = function ()
   fh = assert(io.popen("df | grep -m 1 '/dev/sda1' | tr -s ' ' | cut -d' ' -f 5", "r"))
   usage = fh:read("*all")
   fh:close()
   myhdd:set_text(usage)
end

myhddtimer = timer({ timeout = 300 })
myhddtimer:connect_signal("timeout", updatehdd)
updatehdd()
myhddtimer:start()


-- wifi strength widget
mywifi = wibox.widget.textbox()
updatewifi = function ()
   fh = assert(io.popen("cat /proc/net/wireless | grep -m 1 wlp3s0 | tr -s ' ' | cut -d' ' -f 3 | tr -d .", "r"))
   status = fh:read("*all")
   fh:close()

   if status == "" then
      mywifi:set_text("offline")
   else
      mywifi:set_text(status)
   end
end

mywifitimer = timer({ timeout = 3 })
mywifitimer:connect_signal("timeout", updatewifi)
updatewifi()
mywifitimer:start()
