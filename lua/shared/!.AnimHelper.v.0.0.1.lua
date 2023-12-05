--[[
    module for v.41.78 to transition animations and synchronise changes in multiplayer
    Author: Poltergeist

    https://github.com/Poltergeist-PZ-Modding/PZContentVault/blob/main/lua
]]

local AnimHelper = {
    Type = "AnimHelper",
    version = "0.0.1",
}

-----------------------------------------------------------------------------------------------------------------------
--Version check (major,minor,patch numeric values)

if _G["AnimHelper"] ~= nil then
    local split1 = AnimHelper.version:split("\\.")
    local split2 = _G.AnimHelper.version:split("\\.")
    if tonumber(split1[1]) < tonumber(split2[1]) or tonumber(split1[2]) < tonumber(split2[2]) or tonumber(split1[3]) < tonumber(split2[3]) then
        AnimHelper = nil
        return
    end
end

-----------------------------------------------------------------------------------------------------------------------

local wantNoise = getDebug()

---@deprecated
---@param player IsoPlayer
---@param timer integer
function AnimHelper.fakeTransitionToGround(player,timer)
    player:postupdate() --idle
    player:setHitReaction("HitReaction")
    player:setVariable("FromBehind",true)
    player:setVariable("hitpvp",false)
    player:postupdate() --hitreaction
    player:setVariable("bKnockedDown",true)
    player:setVariable("bOnFloor",false)
    player:setVariable("sitonground",false)
    player:postupdate() --falldown
    player:reportEvent("ActiveAnimFinishing")
    player:setVariable("fallOnFront",true)
    player:postupdate() --onground
    player:setReanimateTimer(timer)
end

---@deprecated
---@param player IsoPlayer
function AnimHelper.fakeTransitionToGetUp(player)
    player:postupdate() --idle
    player:setHitReaction("HitReaction")
    player:setVariable("FromBehind",true)
    player:setVariable("hitpvp",false)
    player:postupdate() --hitreaction
    player:setVariable("bKnockedDown",true)
    player:setVariable("bOnFloor",false)
    player:setVariable("sitonground",false)
    player:postupdate() --falldown
    player:reportEvent("ActiveAnimFinishing")
    player:setVariable("fallOnFront",true)
    player:postupdate() --onground
    -- player:setReanimateTimer(0)
    player:setVariable("BumpDone",true)
    player:setVariable("getUpWalk",false)
    player:postupdate() --getup
end

---@deprecated
---@param player IsoPlayer
---@param doFall boolean
function AnimHelper.bumpPlayer(player,doFall)
    player:setBumpType("stagger")
    player:setVariable("BumpDone", false)
    player:setVariable("BumpFall", doFall)
    player:setVariable("BumpFallType", "pushedFront")
end

---@deprecated
---@param player IsoPlayer
function AnimHelper.fakeTransitionSprintToBumpFall(player)
    player:setVariable("BumpType", "slip")
    player:postupdate() --bumped
    player:setVariable("BumpDone", true)
    player:setVariable("BumpFall", true)
end

AnimHelper.player = {}

AnimHelper.player.bumped = {
    default = function(player,args)
        -- player:setBumpType("stagger")
        -- player:setVariable("BumpDone", false)
        -- player:setVariable("BumpFall", doFall)
        -- player:setVariable("BumpFallType", "pushedFront")    
        player:setVariable("BumpType",args.bumpType or "y")
        if args.fall ~= nil then
            player:setVariable("BumpFall", args.fall)
        end
        if args.fallType ~= nil then
            player:setVariable("BumpFallType", args.fallType)
        end
        if args.done~=nil then
            player:setVariable("BumpDone",args.done)
        end
    end,
    bumpfall = function(player,args)
        player:setVariable("BumpType", "slip")
        player:postupdate() --bumped
        player:setVariable("BumpDone", true)
        player:setVariable("BumpFall", true)
    end,
    transitionOut = function(player,args) end,
}
-- AnimHelper.player.bumped.default = AnimHelper.player.bumped.bumpfall

AnimHelper.player.climbfence = {
    default = function(player,args)
        if player:getActionStateName() ~= "climbFence" then
            if args.dir == nil then return end
            ClimbOverFenceState.instance():setParams(player,IsoDirections[args.dir])
            player:reportEvent("EventClimbFence")
            player:postupdate()
        end
        if args.run ~= nil then player:setVariable("VaultOverRun",args.run) end
        if args.sprint ~= nil then player:setVariable("VaultOverSprint",args.sprint) end
        if args.outcome ~= nil and not player:isVariable("ClimbFenceOutcome",args.outcome) then
            -- if args.outcome ~= "fall" then
            if player:isVariable("ClimbFenceOutcome","fall") then
                player:setBumpDone(false)
                player:setFallOnFront(false)
            end
            player:setVariable("ClimbFenceOutcome",args.outcome)
        end
    end,
    transitionOut = function(player,args) end
}

AnimHelper.player.climbwall = {
    default = function(player,args)
        if player:getActionStateName() ~= "climbwall" then
            if args.dir == nil then return end
            ClimbOverWallState.instance():setParams(player,IsoDirections[args.dir])
            player:reportEvent("EventClimbWall")
            player:postupdate()
        end
        if args.speed ~= nil then
            player:setVariable("ClimbFenceSpeed",args.speed)
        end
        if args.struggle ~= nil then
            player:setVariable("ClimbFenceStruggle",args.struggle)
        end
        if args.outcome ~= nil then
            player:setVariable("ClimbFenceOutcome",args.outcome)
        end
    end,
    fail = function(player)
        if player:getActionStateName() ~= "climbwall" then return end
        player:setVariable("ClimbFenceStarted",true)
        player:setVariable("ClimbFenceStruggle",false)
        player:setVariable("ClimbFenceOutcome","fail")
    end,
    transitionOut = function(player,args)
        player:setVariable("ClimbFenceFinished",true)
        player:postupdate()
    end,
}

AnimHelper.player.falling = {
    default = function(player,args) end,
    transitionOut = function(player,args)
        -- player:setbFalling(false)
        player:setFallTime(0)
        player:setVariable("bLandAnimFinished",true)
        player:postupdate()
    end,
}

AnimHelper.player.getup = {
    -- default = function(player,args)
    --     player:postupdate() --idle
    --     player:setHitReaction("HitReaction")
    --     player:setVariable("FromBehind",true)
    --     player:setVariable("hitpvp",false)
    --     player:postupdate() --hitreaction
    --     player:setVariable("bKnockedDown",true)
    --     player:setVariable("bOnFloor",false)
    --     player:setVariable("sitonground",false)
    --     player:postupdate() --falldown
    --     player:reportEvent("ActiveAnimFinishing")
    --     player:setVariable("fallOnFront",true)
    --     player:postupdate() --onground
    --     -- player:setReanimateTimer(0)
    --     player:setVariable("BumpDone",true)
    --     player:setVariable("getUpWalk",false)
    --     player:postupdate() --getup
    -- end,
    fromScramble = function(player,args)
        -- player:postupdate() --idle
        player:setHitReaction("HitReaction")
        player:setVariable("FromBehind",true)
        player:setVariable("hitpvp",false)
        player:postupdate() --hitreaction
        player:setVariable("bKnockedDown",true)
        player:setVariable("bOnFloor",false)
        player:setVariable("sitonground",false)
        player:postupdate() --falldown
        player:reportEvent("ActiveAnimFinishing")
        player:setVariable("fallOnFront",true)
        player:postupdate() --onground
        -- player:setReanimateTimer(0)
        player:setVariable("BumpDone",true)
        player:setVariable("getUpWalk",false)
        player:postupdate() --getup
    end,
    transitionOut = function(player,args) end,
}
AnimHelper.player.getup.default = AnimHelper.player.getup.fromScramble

AnimHelper.player.onground = {
    default = function(player,args)
        -- player:postupdate() --idle
        player:setHitReaction("HitReaction")
        player:setVariable("FromBehind",true)
        player:setVariable("hitpvp",false)
        player:postupdate() --hitreaction
        player:setVariable("bKnockedDown",true)
        player:setVariable("bOnFloor",false)
        player:setVariable("sitonground",false)
        player:postupdate() --falldown
        player:reportEvent("ActiveAnimFinishing")
        player:setVariable("fallOnFront",true)
        player:postupdate() --onground
        if args.timer ~= nil then
            player:setReanimateTimer(args.timer)
        end
    end,
    transitionOut = function(player,args) end,
}

---@param player IsoPlayer
function AnimHelper.transitionPlayer(player,args)
    if wantNoise then
        local _p = {}; for k,v in pairs(args) do table.insert(_p,k.." = "..tostring(v)) end
        print(AnimHelper.Type .. " transition player args: " .. table.concat(_p,", ") .. ", prev state = "..player:getActionStateName())
    end

    local prev = player:getActionStateName()
    if prev ~= args.state and AnimHelper.player[prev] ~= nil then
        AnimHelper.player[prev].transitionOut(player,args)
    end
    AnimHelper.player[args.state][args.name or "default"](player,args)
    if isClient() and player:isLocalPlayer() then
        sendClientCommand(player,AnimHelper.Type,"player",args)
    end
end

---Synchronized update of variables for player
---@param player IsoPlayer
---@param set? table key = value
---@param clear? table ordered list
function AnimHelper.setPlayerVariables(player,set,clear)
    if clear ~= nil then
        for i = 1, #clear do
            player:clearVariable(clear[i])
        end
    end
    if set ~= nil then
        for k,v in pairs(set) do
            player:setVariable(k,v)
        end
    end
    if isClient() and player:isLocalPlayer() then
        sendClientCommand(player,AnimHelper.Type,"syncPlayer",{set=set,clear=clear})
    end
end

Events.OnClientCommand.Add(function (module, command, player, args)
    if module == AnimHelper.Type then
        -- if wantNoise then print(module,"received command",command) end
        local all = getOnlinePlayers()
        args.plId = player:getOnlineID()
        local conId = math.floor(args.plId/4)
        for i = 0, all:size() - 1 do
            local _player = all:get(i)
            if math.floor(_player:getOnlineID()/4) ~= conId
                and math.abs(player:getX() - player:getX()) < 50
                and math.abs(player:getY() - player:getY()) < 50
            then
                sendServerCommand(_player,AnimHelper.Type,command,args)
            end
        end
        -- if command == "player" then
        -- end
    end
end)

Events.OnServerCommand.Add(function (module, command, args)
    if module == AnimHelper.Type then
        -- if wantNoise then print(module,"received command",command) end
        local player = getPlayerByOnlineID(args.plId)
        if player == nil then return end
        if      command == "player"     then AnimHelper.transitionPlayer(player,args)
        elseif  command == "syncPlayer" then AnimHelper.setPlayerVariables(player,args.set,args.clear)
        else
            error(string.format("%s: Unregistered client command '%s'",module,command))
        end
    end
end)

_G["AnimHelper"] = AnimHelper
