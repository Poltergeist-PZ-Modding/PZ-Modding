--[[
    Module for adjusting burst firing.

    https://github.com/Poltergeist-PZ-Modding/PZContentVault/blob/main/lua
--]]

local Burst = { version = "1.0.1" }

-----------------------------------------------------------------------------------------------------------------------
--Version check (major,minor,patch numeric values)

if __ModularBurstFireMode ~= nil then
    local splitSelf = Burst.version:split("\\.")
    local splitGlobal = __ModularBurstFireMode.version:split("\\.")
    if tonumber(splitSelf[1]) < tonumber(splitGlobal[1]) or tonumber(splitSelf[2]) < tonumber(splitGlobal[2]) or tonumber(splitSelf[3]) <= tonumber(splitGlobal[3]) then
        return
    end
end

__ModularBurstFireMode = Burst

-----------------------------------------------------------------------------------------------------------------------

function Burst.OnWeaponSwing(character,weapon)
    if weapon:getFireMode() ~= "modBurst" then return end

    character:setVariable("FireMode", weapon:getModData().modBurst_AnimFireMode or "Auto")
    character:setVariable("autoShootSpeed", (tonumber(weapon:getModData().modBurst_Speed) or 4) * GameTime.getAnimSpeedFix())
    character:setVariable("autoShootVarX", -9000)
end

function Burst.OnWeaponSwingHitPoint(character,weapon)
    if weapon:getFireMode() ~= "modBurst" then return end

    local data = weapon:getModData()
    data.modBurst_ShotsFired = (data.modBurst_ShotsFired or 0) + 1
end

function Burst.OnPlayerAttackFinished(character,weapon)
    if weapon == nil or weapon:getFireMode() ~= "modBurst" then return end

    local data = weapon:getModData()
    if data.modBurst_ShotsFired > (data.modBurst_Shots or 3) then
        data.modBurst_ShotsFired = 0
        character:setRecoilDelay(data.modBurst_Delay or 10)
    end
end

Events.OnGameBoot.Add(function ()
    if __ModularBurstFireMode ~= Burst then return end
    Events.OnWeaponSwing.Add(Burst.OnWeaponSwing)
    Events.OnWeaponSwingHitPoint.Add(Burst.OnWeaponSwingHitPoint)
    Events.OnPlayerAttackFinished.Add(Burst.OnPlayerAttackFinished)
end)
