----------------
------var-------
----------------
local vars = require("variables")
local func = require("modules.functions")

-------------
----binds----
-------------
hl.bind(vars.mainMod .. " + Q", hl.dsp.exec_cmd(vars.terminal))    --terminal
hl.bind(vars.mainMod .. " + L", hl.dsp.exec_cmd(vars.lockscreen))  --hyprlock
hl.bind(vars.mainMod .. " + E", hl.dsp.exec_cmd(vars.terminal .. " -e " .. vars.fileManager_TUI))
hl.bind(vars.mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(vars.fileManager_GUI))
hl.bind(vars.mainMod .. " + R", hl.dsp.exec_cmd(vars.menu))
hl.bind(vars.mainMod .. " + M", hl.dsp.exec_cmd(vars.musicPlayer))
hl.bind(vars.mainMod .. " + F", hl.dsp.exec_cmd(vars.browser))
hl.bind(vars.mainMod .. " + O", hl.dsp.exec_cmd(vars.notes)) --obsidian
hl.bind(vars.mainMod .. " + SHIFT + O", hl.dsp.exec_cmd(vars.codeTextEditor)) --vscode
hl.bind(vars.mainMod .. " + T", hl.dsp.exec_cmd(vars.toDo))
hl.bind(vars.mainMod .. " + D", hl.dsp.exec_cmd(vars.chat))

--window_binds / workspace_binds--
hl.bind(vars.mainMod .. " + V", hl.dsp.window.float())
hl.bind(vars.mainMod .. " + C", hl.dsp.window.close())        --Close window
hl.bind(vars.mainMod .. " + left", hl.dsp.focus({direction = "left"}))
hl.bind(vars.mainMod .. " + right", hl.dsp.focus({direction = "right"}))
hl.bind(vars.mainMod .. " + up", hl.dsp.focus({direction = "up"}))
hl.bind(vars.mainMod .. " + down", hl.dsp.focus({direction = "down"}))
hl.bind(vars.mainMod .. " + J", hl.dsp.layout("togglesplit"))

--workspaces system_binds

hl.bind(vars.mainMod .. " + TAB", func.changeMonitor) --Change monitor
for i = 1, 5 do --Assign workspaces keys
    local key = tostring(i)
    hl.bind(vars.mainMod .. " + " .. key, function()
        if func.getSecondMonitor() then
            hl.dispatch(hl.dsp.focus({ workspace = i + 5 }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = i }))
        end
    end)
    hl.bind(vars.mainMod .. " + SHIFT + " .. key, function()
    if func.getSecondMonitor() then
        hl.dispatch(hl.dsp.window.move({ workspace = i + 5 }))
    else
        hl.dispatch(hl.dsp.window.move({ workspace = i }))
        end
    end)
end



hl.bind(vars.mainMod .. " + SHIFT + Tab", hl.dsp.window.move({ monitor = "+1" }))

hl.bind(vars.mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(vars.mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(vars.mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(vars.mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))

--workspaces system_binds end

hl.bind(vars.mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(vars.mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


--system_binds--
hl.bind(vars.mainMod .. " + Escape", hl.dsp.exec_cmd("hyprshutdown --dry-run")) --WIP
hl.bind(vars.mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot --freeze -m region"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind(vars.mainMod .. " + F3",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind(vars.mainMod .. " + F2", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind(vars.mainMod .. " + F1",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })