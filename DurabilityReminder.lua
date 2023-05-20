SLASH_DURABILITYREMINDER1 = "/dr"
local _zoneChangedEvent = "ZONE_CHANGED_NEW_AREA";
local _resurectEvent = "PLAYER_ALIVE"

local function ToggleSoundOnLaunch()
    if (DurabilityReminderSoundToggle == nil) then
        DurabilityReminderSoundToggle = true
    end
end

local function ToggleSound()
    DurabilityReminderSoundToggle = not DurabilityReminderSoundToggle
end

-- Checks if an item is broken and sends an appropriate message.
local function PrintSingleItem(durability, index)
    if (durability == 0) then
        DEFAULT_CHAT_FRAME:AddMessage(GetInventoryItemLink("player", index) .. "is broken.", 1, 1, 0)
    else
        DEFAULT_CHAT_FRAME:AddMessage(GetInventoryItemLink("player", index) .. " is at " .. durability .. "% durability.",
            1, 1, 0)
    end
end

-- Checks all equipment slots and gets a total percentage of durability
-- If an item is under 20% durability it will be sent to the printSingleItem so it can have its own message
local function getDurabilityAverage()
    local totalMaxDurability = 0;
    local totalDurability = 0;
    for i = 1, 17, 1 do
        local durability, maxDurability = GetInventoryItemDurability(i);
        if (durability ~= nil) then
            totalMaxDurability = totalMaxDurability + maxDurability;
            totalDurability = totalDurability + durability;
            local itemPercent = durability / maxDurability * 100;
            if (itemPercent <= 20) then
                PrintSingleItem(itemPercent, i)
            end
        end
    end
    if (totalMaxDurability == 0) then
        return 0
    end
    return totalDurability / totalMaxDurability
end
-- function prints a green message to the chat
local function printGreenMessage(message)
    DEFAULT_CHAT_FRAME:AddMessage(message, 0, 1, 0)
end
-- function prints a yellow message to the chat
local function printYellowMessage(message)
    DEFAULT_CHAT_FRAME:AddMessage(message, 1, .68, .26)
end
--Function prints a red message to the chat
local function printRedMessage(message)
    DEFAULT_CHAT_FRAME:AddMessage(message, 1, 0, 0)
    if (DurabilityReminderSoundToggle) then
        PlaySound(7994)
    end
end

local function printPlayerDurability()
    local avg = getDurabilityAverage()
    avg = avg * 100
    local avgstring = tonumber(string.format("%.1f", avg))
    if (avg >= 70) then
        printGreenMessage("Your durability is currently at " .. avgstring .. "% :)")
    elseif (avg >= 30) then
        printYellowMessage("Your durability is currently at " .. avgstring .. "% :/")
    else
        printRedMessage("Your durability is currently at " .. avgstring .. "% :(")
    end
end

--Function will get trigged by the '/dr' command
local function HandleSlashCommands(str)
    if (str == "sound") then
        ToggleSound()
        if (DurabilityReminderSoundToggle) then
            print("Durability Reminder sound is now on")
        else
            print("Durability Reminder sound is now off")
        end
    elseif (str == "check") then
        printPlayerDurability()
    else
        print("type '/dr sound' to toggle sound on or off on low durability")
        print("type '/dr check' to get your durability %")
    end
end

-- Setup this code runs on start
local frame = CreateFrame("Frame")
frame:RegisterEvent(_zoneChangedEvent)
frame:SetScript("OnEvent", function(self, event, ...)
    if event == _zoneChangedEvent then
        local inInstance, instanceType = IsInInstance()
        if (instanceType == "raid" or instanceType == "party" or instanceType == "arena") then
            printPlayerDurability();
        end
    elseif event == _resurectEvent then
        printPlayerDurability()
    end
end)
frame:RegisterEvent(_zoneChangedEvent)
frame:RegisterEvent(_resurectEvent)
SlashCmdList["DURABILITYREMINDER"] = HandleSlashCommands
ToggleSoundOnLaunch()
