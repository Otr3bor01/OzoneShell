hl.monitor({
    output = "DP-2",
    mode = "1920x1080@144",
    position = "0x0",
    scale = "1"
})

hl.monitor({
    output = "DP-1",
    mode = "2560x1440@170",
    position = "1920x0",
    scale = "1.333333"
})

for i=1,5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1", persistent = true})
end
for i=6,10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-2", persistent = true})
end