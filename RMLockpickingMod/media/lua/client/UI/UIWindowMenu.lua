require('luautils');

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Checks if the window is valid for opening.
-- @param window - The window to check.
--
local function isValidWindow(window)
    if not window then
        return false;
    elseif window:IsOpen() then
        return false;
    elseif window:isSmashed() or window:isDestroyed() then
        return false;
    elseif not window:isLocked() then
        return false;
    elseif window:IsOpen() and window:isPermaLocked() then
        return false;
    elseif window:isBarricaded() then
        return false;
    else
        return true;
    end
end

-- ------------------------------------------------
-- Create Timed Actions
-- ------------------------------------------------

---
-- Walks to the window, equips the item and then performs the
-- timed action to break open the window's lock.
-- @param worldobjects - List of all clicked objects.
-- @param window - The window to break open.
-- @param player - The burglar.
--
local function forceWindow(worldobjects, window, player)
    local time = 100;
    if luautils.walkToObject(player, window) then
        local storePrim = luautils.equipItems(player, "Base.Crowbar");
        ISTimedActionQueue.add(TABreakWindowLock:new(player, window, time, storePrim));
    end
end

---
-- Creates a new context menu entry for windows.
-- @param player - The player that clicks on the window.
-- @param context - The context menu to work with.
-- @param worldobjects - A table containing all clicked objects.
--
local function createMenuEntries(player, context, worldobjects)
    local window;

    -- Checks if the player has clicked on a window
    for _, object in ipairs(worldobjects) do
        if instanceof(object, "IsoWindow") then
            window = object;
            break;
        end
    end

    -- Checks if the window is valid
    if not isValidWindow(window) then
        return;
    end

    -- Create the context menus.
    local player = getSpecificPlayer(player);
    local inventory = player:getInventory();

    -- Breaking the lock
    if inventory:contains("Crowbar") then
        local prim = player:getInventory():FindAndReturn("Base.Crowbar");

        if not prim or prim:getCondition() <= 0 then
            print("No valid crowbar");
        else
            context:addOption(Lockpicking_Text.contextBreakWindowLock, worldobjects, forceWindow, window, player);
        end
    end
end

-- ------------------------------------------------
-- Game hooks
-- ------------------------------------------------
Events.OnFillWorldObjectContextMenu.Add(createMenuEntries);
