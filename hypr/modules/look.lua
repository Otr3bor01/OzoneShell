local theme = require("state.theme")


hl.config({
    general = {
        gaps_in = theme.gaps_in,
        gaps_out = theme.gaps_out,
        border_size = theme.border_size,
        col = {
            inactive_border = { colors = theme.inactive_gradient, angle = theme.angle },
            active_border = { colors = theme.active_gradient, angle = theme.angle }
        },
        resize_on_border = true,
        layout = theme.layoutType,
    },
    decoration = {
        rounding       = 10,
        rounding_power = 2,
        shadow = {
            enabled = false
        },
    blur = {
        enabled = true
        }
    },

    animations = {
        enabled = true,
    }
})

---animations---
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global",        enabled = true,  speed = 2,   bezier = "default" })

    --WINDOWS
    hl.animation({ leaf = "windows",       enabled = true,  speed = 2, spring = "easy" })
        hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 3.5,  bezier = "easeOutQuint",         style = "popin"})
        hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 2, bezier = "linear",       style = "popin" })
        hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "linear"})

    --FADE
    hl.animation({ leaf = "fade",          enabled = true,  speed = 2, bezier = "quick" })
        hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 3, bezier = "almostLinear" })
        hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 2, bezier = "almostLinear" })

    --LAYERS    
    hl.animation({ leaf = "layers",        enabled = true,  speed = 2, bezier = "easeOutQuint" })
        hl.animation({ leaf = "layersIn",      enabled = true,  speed = 2,    bezier = "easeOutQuint", style = "popin" })
        hl.animation({ leaf = "layersOut",     enabled = true,  speed = 2,  bezier = "linear",       style = "popin" })
    
    --FADELAYERS
    hl.animation({ leaf = "fadeLayers", enabled = true, speed = 2, bezier = "almostLinear"})
        hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.5, bezier = "almostLinear" })
        hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 2, bezier = "almostLinear" })
    
    --WORKSPACES
    hl.animation({ leaf = "workspaces",    enabled = true,  speed = 2, bezier = "almostLinear", style = "slide" })
        hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 2, bezier = "almostLinear", style = "slide" })
        hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 2, bezier = "almostLinear", style = "slide" })
        hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 2, bezier = "almostLinear", style = "slidevert"})
        hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 2, bezier = "almostLinear", style = "slidevert"})
        
    --ZOOMFACTOR
    hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 1,    bezier = "quick" })

    --BORDER
    hl.animation({ leaf = "border",        enabled = true,  speed = 7, bezier = "easeOutQuint" })