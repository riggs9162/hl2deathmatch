--[[ Include Files ]]--

include("shared.lua")

--[[ Net Messages ]]--

net.Receive("dmChooseTeam", function()
    Derma_Query("dmChooseTeam", "Half-Life 2 Deathmatch", "Rebels", function()
        net.Start("dmBecomeTeam")
            net.WriteUInt(FACTION_REBELS, 4)
        net.SendToServer()
    end, "Combine", function()
        net.Start("dmBecomeTeam")
            net.WriteUInt(FACTION_COMBINES, 4)
        net.SendToServer()
    end)
end)

net.Receive("dmChooseClass", function()
    local teamUInt = net.ReadUInt(4)
    
    if ( teamUInt == FACTION_REBELS ) then
        Derma_Query("dmChooseClass", "Half-Life 2 Deathmatch", "Refugees", function()
            net.Start("dmBecomeClass")
                net.WriteUInt(teamUInt, 4)
                net.WriteUInt(1, 4)
            net.SendToServer()
        end, "Resistance", function()
            Derma_Query("dmChooseClass", "Half-Life 2 Deathmatch", "Rebel Fighter", function()
                net.Start("dmBecomeClass")
                    net.WriteUInt(teamUInt, 4)
                    net.WriteUInt(2, 4)
                net.SendToServer()
            end, "Rebel Shotgunner", function()
                net.Start("dmBecomeClass")
                    net.WriteUInt(teamUInt, 4)
                    net.WriteUInt(3, 4)
                net.SendToServer()
            end, "Rebel Medic", function()
                net.Start("dmBecomeClass")
                    net.WriteUInt(teamUInt, 4)
                    net.WriteUInt(4, 4)
                net.SendToServer()
            end, "Rebel Sniper", function()
                net.Start("dmBecomeClass")
                    net.WriteUInt(teamUInt, 4)
                    net.WriteUInt(5, 4)
                net.SendToServer()
            end)
        end)
    elseif ( teamUInt == FACTION_COMBINES ) then
        Derma_Query("dmChooseClass", "Half-Life 2 Deathmatch", "Civil Protection Force", function()
            Derma_Query("dmChooseClass", "Half-Life 2 Deathmatch", "Metrocop", function()
                net.Start("dmBecomeClass")
                    net.WriteUInt(teamUInt, 4)
                    net.WriteUInt(1, 4)
                net.SendToServer()
            end, "Metrocop Medic", function()
                net.Start("dmBecomeClass")
                    net.WriteUInt(teamUInt, 4)
                    net.WriteUInt(4, 4)
                net.SendToServer()
            end)
        end, "Overwatch Transhuman Arm", function()
            Derma_Query("dmChooseClass", "Half-Life 2 Deathmatch", "Overwatch Soldier", function()
                net.Start("dmBecomeClass")
                    net.WriteUInt(teamUInt, 4)
                    net.WriteUInt(2, 4)
                net.SendToServer()
            end, "Overwatch Shotgunner", function()
                net.Start("dmBecomeClass")
                    net.WriteUInt(teamUInt, 4)
                    net.WriteUInt(3, 4)
                net.SendToServer()
            end, "Overwatch Rifleman", function()
                net.Start("dmBecomeClass")
                    net.WriteUInt(teamUInt, 4)
                    net.WriteUInt(5, 4)
                net.SendToServer()
            end)
        end)
    end
end)

--[[ Fonts ]]--

surface.CreateFont("HudFontBig", {
    font = "Verdana",
    size = 60,
    weight = 800,
})

surface.CreateFont("HudFontMedium", {
    font = "Verdana",
    size = 30,
    weight = 800,
})

surface.CreateFont("TargetFontMedium", {
    font = "Verdana",
    size = 18,
    weight = 800,
})

--[[ Hooks ]]--

local color_green = Color(0, 255, 0, 50)
function GM:PreDrawHalos()
    local teamMates = {}

    for _, ply in ipairs( player.GetAll() ) do
        if ( LocalPlayer():Team() == ply:Team() ) then
            teamMates[#teamMates + 1] = ply
        end
    end

    halo.Add(teamMates, color_green, 2, 2, 5, true, true)
end

--[[ Hud ]]--

hook.Add("HUDShouldDraw", "dontDrawIt", function(name)
    for k, v in pairs ({"CHudHealth", "CHudBattery"}) do 
        if ( name == v ) then
            return false
        end
    end
end)

function GM:PlayerStartVoice(ply)
    ply.isTalking = true
end

function GM:PlayerEndVoice(ply)
    ply.isTalking = nil
end

function GM:HUDPaint()
    local ply = LocalPlayer()
    local teamName = team.GetName(ply:Team())
    local teamColor = team.GetColor(ply:Team())

    if ( ply:Alive() ) then
        draw.RoundedBox(20, 25, ScrH() - 90, 150, 60, ColorAlpha(color_black, 100))
        draw.RoundedBox(20, 225, ScrH() - 90, 150, 60, ColorAlpha(color_black, 100))

        draw.DrawText(ply:Health(), "HudFontBig", 100, ScrH() - 90, teamColor, TEXT_ALIGN_CENTER)
        draw.DrawText(ply:Armor(), "HudFontBig", 300, ScrH() - 90, teamColor, TEXT_ALIGN_CENTER)

        draw.DrawText("Rebels: "..#hl2deathmach.GetAllRebels(), "HudFontMedium", 10, 5, team.GetColor(FACTION_REBELS), TEXT_ALIGN_LEFT)
        draw.DrawText("Combine: "..#hl2deathmach.GetAllCombine(), "HudFontMedium", 10, 45, team.GetColor(FACTION_COMBINES), TEXT_ALIGN_LEFT)
    end

    local voiceSpacing = 0
    for k, v in pairs(player.GetAll()) do
        if not ( v:Team() == ply:Team() ) then
            continue
        end

        if ( v.isTalking ) then
            draw.DrawText(v:Nick(), "HudFontMedium", ScrW() - 10, 10 + voiceSpacing, team.GetColor(v:Team()), TEXT_ALIGN_RIGHT)
            voiceSpacing = voiceSpacing + 40
        end

        if ( v:Nick() == ply:Nick() ) then
            continue
        end

        local pos = v:EyePos()
    
        pos.z = pos.z
        pos = pos:ToScreen()
        pos.y = pos.y - 20

        draw.DrawText(v:Nick(), "TargetFontMedium", pos.x, pos.y, team.GetColor(v:Team()), TEXT_ALIGN_CENTER)
    end
end