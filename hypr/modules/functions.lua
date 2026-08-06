local secondMonitor = false
local targetMonitor = ""


local function targetMonitorUpdate(secMon)
    local tarMon = ""
    if secMon then
        tarMon = "DP-2"
    else
        tarMon = "DP-1"
    end
    return tarMon
end

local function updateState()
    local f = io.open("/tmp/hypr_secondMonitor", "w")
    if f then
        f:write(secondMonitor and "true" or "false")
        f:close()
    end
end

local function changeMonitor()
    secondMonitor = not secondMonitor
    updateState()
    targetMonitor = targetMonitorUpdate(secondMonitor)
    hl.dispatch(hl.dsp.focus({monitor = targetMonitor}))
end

local function changeMonitorAndMove()
    secondMonitor = not secondMonitor
    updateState()
    targetMonitor = targetMonitorUpdate(secondMonitor)
    hl.dispatch(hl.dsp.window.move({ monitor = "+1" }))
end

local function getSecondMonitor()
    return secondMonitor
end



local function brightness(direction)
    local mon = hl.get_active_monitor()
    hl.dispatch(hl.dsp.exec_cmd('qs ipc call brightness ' .. tostring(direction) .. ' ' .. tostring(mon.name)))
end

return {
    brightness = brightness,
    targetMonitorUpdate = targetMonitorUpdate,
    updateState = updateState,
    changeMonitor = changeMonitor,
    getSecondMonitor = getSecondMonitor,
    changeMonitorAndMove = changeMonitorAndMove,
}