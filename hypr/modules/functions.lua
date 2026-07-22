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

local function getSecondMonitor()
    return secondMonitor
end

local function updateSecretWorkspaceFile(ws)
    if not ws or not ws.name then return end
    local isSpecial = ws.name:match("^special:") ~= nil
    local f = io.open("/tmp/hypr_secretWorkspace", "w")
    if f then
        f:write(isSpecial and "true" or "false")
        f:close()
    end
end

hl.on("workspace.active", function(ws) --Check for changes 
    hl.notification.create({ text = "workspace.active: " .. tostring(ws and ws.name), timeout = 3000 }) --Debug
    updateSecretWorkspaceFile(ws)
end)

return {
    targetMonitorUpdate = targetMonitorUpdate,
    updateState = updateState,
    changeMonitor = changeMonitor,
    getSecondMonitor = getSecondMonitor,
}