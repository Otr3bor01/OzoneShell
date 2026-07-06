local theme = {
    blackN =         "#1A1228",
    redN =           "#C94F6B",
    greenN =         "#5A8A5E",
    yellowN =        "#C98A2A",
    purpleN =        "#5C4BA0",
    pinkN =          "#9B4FA6",
    blueN =          "#7A9EBF",
    whiteN=          "#D9D0E8",

    blackB =         "#352748",
    redB =           "#E8718E",
    greenB =         "#7ABF7E",
    yellowB =        "#F0B84A",
    purpleB =        "#9580D6",
    pinkB =          "#C87DD4",
    blueB =          "#A8C8E8",
    whiteB =         "#F2EEF9",

    backgroundColor =    "#120D1E",
    foregroundColor =    "#D9D0E8",
    iconsColor =         "#C87DD4",

    gapsIn = 5,
    gapsOut = 20,
    borderSize = 4,
    layoutType = "dwindle",
    angle = 220,
}
--gradient using preexistent colors
theme.activeGradient = {theme.whiteN, theme.purpleB}
theme.inactiveGradient = {theme.purpleN, theme.blackB}
--
return theme