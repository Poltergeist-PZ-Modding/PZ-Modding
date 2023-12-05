--[[
    Author Poltergeist
    module for using special items that only exist in the player hands

    https://github.com/Poltergeist-PZ-Modding/PZContentVault/blob/main/lua
--]]
--[[        \<.<\        ┏(-Д-┏)～        ]]

local self = { version = "1.0.1" }

-----------------------------------------------------------------------------------------------------------------------
--Version check (major,minor,patch numeric values)

if __HandsExclusiveItem ~= nil then
    local split1 = self.version:split("\\.")
    local split2 = __HandsExclusiveItem.version:split("\\.")
    if tonumber(split1[1]) < tonumber(split2[1]) or tonumber(split1[2]) < tonumber(split2[2]) or tonumber(split1[3]) < tonumber(split2[3]) then
        self = nil
        return
    end
end

-----------------------------------------------------------------------------------------------------------------------

function self.initialize()
    Events.OnTick.Remove(self.initialize)

    if __HandsExclusiveItem ~= self then return end

    function self.onItemFall(item)
        if item:getModData().isHandsExclusiveItem then
            local wItem = item:getWorldItem()
            if wItem ~= nil then
                wItem:getSquare():transmitRemoveItemFromSquare(wItem)
                wItem:removeFromWorld()
                wItem:removeFromSquare()
                wItem:setSquare(nil)
                triggerEvent("OnContainerUpdate")
            end
        end
    end
    Events.onItemFall.Add(self.onItemFall)

    ---patch createMenu to remove drop options and errors
    local createMenu = ISInventoryPaneContextMenu.createMenu
    ISInventoryPaneContextMenu.createMenu = function(player, isInPlayerInventory, items, ...)
        if isInPlayerInventory and type(items[1]) == "userdata" and items[1]:getModData().isHandsExclusiveItem then
            items[1] = nil
        end
        return createMenu(player, isInPlayerInventory, items, ...)
    end

end

Events.OnTick.Add(self.initialize)

__HandsExclusiveItem = self
