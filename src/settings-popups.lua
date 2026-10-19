local tweenSettingsPopup=Window:CreatePopup({
    Title="Tween Slider Settings",
    Width=520,
    Height=500,
    Columns=2,
    Divider=true
})

otherTab:AddButton("open_tween_settings", {
    Text="Tween Sliders", Description="Open every movement tween speed slider",
    Column=1,
    Callback=function() tweenSettingsPopup:Show() end
})

tweenSettingsPopup:AddSection("Farming Tweens",{Column=1})
tweenSettingsPopup:AddSlider("tween_farm_speed",{
    Text="Farm Tween Speed", Min=50, Max=2000, Step=50, Default=S.FARM_SPEED,
    Integer=true, Column=1, Callback=function(v) S.FARM_SPEED=v end
})
tweenSettingsPopup:AddSlider("tween_chest_speed",{
    Text="Chest Tween Speed", Min=50, Max=2000, Step=50, Default=S.CHEST_SPEED,
    Integer=true, Column=1, Callback=function(v) S.CHEST_SPEED=v end
})
tweenSettingsPopup:AddSlider("tween_fruit_speed",{
    Text="Fruit Tween Speed", Min=50, Max=2000, Step=50, Default=S.FRUIT_SPEED,
    Integer=true, Column=1, Callback=function(v) S.FRUIT_SPEED=v end
})
tweenSettingsPopup:AddSlider("tween_npc_speed",{
    Text="NPC Travel Speed", Min=50, Max=2000, Step=50, Default=S.NPC_TWEEN_SPEED,
    Integer=true, Column=1, Callback=function(v) S.NPC_TWEEN_SPEED=v end
})

tweenSettingsPopup:AddSection("World Tweens",{Column=2})
tweenSettingsPopup:AddSlider("tween_level_speed",{
    Text="Level Tween Speed", Min=50, Max=2000, Step=50, Default=AFL.tweenSpeed,
    Integer=true, Column=2, Callback=function(v) AFL.tweenSpeed=v end
})
tweenSettingsPopup:AddSlider("tween_raid_speed",{
    Text="Raid Tween Speed", Min=50, Max=2000, Step=50, Default=S.RAID_TWEEN_SPEED,
    Integer=true, Column=2, Callback=function(v) S.RAID_TWEEN_SPEED=v end
})
tweenSettingsPopup:AddSlider("tween_mastery_speed",{
    Text="Mastery Tween Speed", Min=50, Max=2000, Step=50, Default=S.MASTERY_TWEEN_SPEED,
    Integer=true, Column=2, Callback=function(v) S.MASTERY_TWEEN_SPEED=v end
})
tweenSettingsPopup:AddSlider("tween_boat_speed",{
    Text="Boat Tween Speed", Min=50, Max=2000, Step=50, Default=S.BOAT_TWEEN_SPEED,
    Integer=true, Column=2, Callback=function(v) S.BOAT_TWEEN_SPEED=v end
})

tweenSettingsPopup:AddButton("close_tween_settings",{
    Text="Close", Column=2, Callback=function() tweenSettingsPopup:Hide() end
})

pvpTab:AddSection("PvP", { Column = 1 })

pvpTab:AddToggle("void_pull", {
    Text="Escape (risky)", Description="Sends you to Y=100000",
    Default=false, Column=1,
    Callback=function(v) S.voidPull=v; notify(v and "Go Up ON!" or "Go Up OFF!","laced.club",2) end
})

pvpTab:AddToggle("sky_pull", {
    Text="Go Back Down (risky)", Description="Brings you back to Y=100",
    Default=false, Column=1,
    Callback=function(v) S.skyPull=v; notify(v and "Go Down ON!" or "Go Down OFF!","laced.club",2) end
})

pvpTab:AddToggle("pvp_aura", {
    Text="PvP Aura", Description="Fires RegisterHit on the nearest player. MATCHA PRO ONLY!",
    Default=false, Keybind=true, Column=1,
    Callback=function(v)
        _pvpAuraEnabled = v
        notify(v and "PvP Aura ON!" or "PvP Aura OFF!", "laced.club", 2)
    end
})
pvpTab:AddToggle("pvp_aura_alt_part", {
    Text="Use ModelHitbox", Description="Toggle between Head and ModelHitbox hit part.",
    Default=false, Column=1,
    Callback=function(v)
        _pvpAuraAltPart = v
        notify("Hit part: " .. (v and "ModelHitbox" or "Head"), "laced.club", 2)
    end
})
pvpTab:AddSlider("pvp_aura_range", {
    Text="PvP Range", Description="Max distance to target players (studs)",
    Min=10, Max=300, Default=100, Integer=true, Column=1,
    Callback=function(v) _pvpAuraMaxDist = v end
})

pvpTab:AddSection("Glitches", { Column = 2 })

pvpTab:AddToggle("sanguine_z_boost", {
    Text="Sanguine Z Boost", Description="Boosts current velocity during Sanguine Art Z",
    Default=false, Column=2,
    Callback=function(v) S.sanguineZBoost=v end
})

pvpTab:AddToggle("dragon_talon_z_boost", {
    Text="Dragon Talon Z Boost", Description="Boosts current velocity after pressing Z",
    Default=false, Column=2,
    Callback=function(v) S.dragonTalonZBoost=v end
})

pvpTab:AddToggle("yama_z_boost", {
    Text="Yama Z Boost", Description="Boosts current velocity after pressing Z",
    Default=false, Column=2,
    Callback=function(v) S.yamaZBoost=v end
})

pvpTab:AddToggle("tushita_x_boost", {
    Text="Tushita X Boost", Description="Boosts current velocity after pressing X",
    Default=false, Column=2,
    Callback=function(v) S.tushitaXBoost=v end
})

pvpTab:AddToggle("fox_lamp_x_boost", {
    Text="Fox Lamp X Boost", Description="Boosts current velocity after pressing X",
    Default=false, Column=2,
    Callback=function(v) S.foxLampXBoost=v end
})

pvpTab:AddToggle("soul_guitar_m1_boost", {
    Text="Soul Guitar M1", Description="Boosts after Q + M1 within 0.5 seconds",
    Default=false, Column=2,
    Callback=function(v) S.soulGuitarM1Boost=v end
})

pvpTab:AddToggle("diamond_m1_boost", {
    Text="Diamond M1", Description="Sanguine-style boost when M1 is released with Diamond-Diamond equipped",
    Default=false, Column=2,
    Callback=function(v) S.diamondM1Boost=v end
})

pvpTab:AddToggle("flame_f_boost", {
    Text="Flame F Boost", Description="Boosts current velocity after pressing F",
    Default=false, Column=2,
    Callback=function(v) S.flameFBoost=v end
})

pvpTab:AddSection("PvP misc", { Column = 1 })

pvpTab:AddToggle("r_to_x", {
    Text="R to X", Description="Automatically taps X when you press R",
    Default=false, Column=1,
    Callback=function(v) S.rToX=v end
})

pvpTab:AddToggle("r_to_x_then_z", {
    Text="R to X then Z", Description="Taps X when you press R, waits 25ms, then taps Z",
    Default=false, Column=1,
    Callback=function(v) S.rToXThenZ=v end
})

pvpTab:AddToggle("flame_r_to_c", {
    Text="Flame R to C", Description="FLAME, When u flashstep = flame C move",
    Default=false, Column=1,
    Callback=function(v) S.flameRToC=v end
})

local glitchSettingsPopup=Window:CreatePopup({
    Title="Glitch Slider Settings",
    Width=520,
    Height=680,
    Columns=2,
    Divider=true
})

pvpTab:AddButton("open_glitch_settings", {
    Text="Adjust Glitch Sliders", Description="Open individual settings for every boost glitch",
    Column=2,
    Callback=function() glitchSettingsPopup:Show() end
})

local glitchSliderProfiles={
    {key="sanguine",label="Sanguine Z",column=1,color=Color3.fromRGB(220,45,65)},
    {key="dragonTalon",label="Dragon Talon Z",column=1,color=Color3.fromRGB(255,125,25)},
    {key="yama",label="Yama Z",column=1,color=Color3.fromRGB(160,75,255)},
    {key="tushita",label="Tushita X",column=1,color=Color3.fromRGB(40,190,255)},
    {key="foxLamp",label="Fox Lamp X",column=2,color=Color3.fromRGB(255,80,190)},
    {key="soulGuitar",label="Soul Guitar M1",column=2,color=Color3.fromRGB(70,220,125)},
    {key="diamond",label="Diamond M1",column=2,color=Color3.fromRGB(70,220,255)},
    {key="flame",label="Flame F",column=2,color=Color3.fromRGB(255,205,40)},
}

for _,entry in ipairs(glitchSliderProfiles) do
    local profileKey=entry.key
    local profile=S.glitchSettings[profileKey]
    local column=entry.column
    glitchSettingsPopup:AddSection(entry.label,{Column=column})
    glitchSettingsPopup:AddSlider("glitch_"..profileKey.."_speed",{
        Text="Speed", Min=50, Max=1000, Step=50, Default=profile.speed,
        Color=entry.color, Integer=true, Column=column,
        Callback=function(v) profile.speed=v end
    })
    glitchSettingsPopup:AddSlider("glitch_"..profileKey.."_delay",{
        Text="Start Delay", Min=0.01, Max=1, Step=0.01, Default=profile.delay,
        Color=entry.color, Decimals=2, Integer=false, Column=column,
        Callback=function(v) profile.delay=v end
    })
    glitchSettingsPopup:AddSlider("glitch_"..profileKey.."_duration",{
        Text="Duration", Min=0.01, Max=1, Step=0.01, Default=profile.duration,
        Color=entry.color, Decimals=2, Integer=false, Column=column,
        Callback=function(v) profile.duration=v end
    })
end

glitchSettingsPopup:AddButton("close_glitch_settings",{
    Text="Close", Column=2,
    Callback=function() glitchSettingsPopup:Hide() end
})

