local API = {}
API.Checkers = {}
API.Extenders = {
    PlayerWrapper = {}
}

local CollectionService = game:GetService("CollectionService")

local core = script.Parent.Parent
local settings = require(core.Settings)
local dLog = require(core.dLog)

local function safePcall(functionToCall, ...)
    local retries = 0
    local success, result = pcall(functionToCall, ...)
    
    while not success and retries < 3 do
        success, result = pcall(functionToCall, ...)
        retries += 1
        wait(5)
    end

    return success, result
end

function API.getAdminStatusWithUserId(userId)
    local currentIndex
    dLog("Info", "Received request")
    for name, checker in pairs(API.Checkers) do
        dLog("Info", "At checker " .. name)
        local index = checker(userId)
        dLog("Info", "Got index " .. index)
        if index and (currentIndex or 0) < index then
            currentIndex = index
        else
            continue
        end

        if index == #settings.Groups then
            break
        end
    end

    if currentIndex then
        return currentIndex, settings.Groups[currentIndex].Name
    end
end

function API.getAdminLevel(player)
    return player:GetAttribute("Commander_AdminIndex"), player:GetAttribute("Commander_AdminGroup")
end

function API.checkUserAdmin(player)
    return CollectionService:HasTag(player, "Commander_Admin")
end

function API.initializePlayer(player)
    if CollectionService:HasTag(player, "Commander_Loaded") then return end
    local groupIndex, groupName = API.getAdminStatusWithUserId(player.UserId)

    if groupIndex then
        dLog("Info", player.UserId .. " is an administrator with permission " .. groupIndex)
        player:SetAttribute("Commander_AdminIndex", groupIndex)
        player:SetAttribute("Commander_AdminGroup", groupName)
        CollectionService:AddTag(player, "Commander_Admin")
        CollectionService:AddTag(player, "Commander_Loaded")
    end
end

function API.wrapPlayer(player)
    local wrapper = {
        ["Name"] = player.Name,
        ["DisplayName"] = player.DisplayName,
        ["UserId"] = player.UserId,
        ["Character"] = player.Character or player.CharacterAdded:Wait(),
        ["IsAdmin"] = API.checkUserAdmin(player),
        ["_instance"] = player
    }

    wrapper.AdminIndex, wrapper.AdminGroup = API.getAdminLevel(player)

    for _, extender in ipairs(API.Extenders.PlayerWrapper) do
        extender(player, wrapper)
    end

    return wrapper
end

function API.addChecker(name, checkerFunction)
    dLog("Success", "Added checker " .. name .. ", got " .. #API.Checkers .. " checkers so far")
    API.Checkers[name] = checkerFunction
end

function API.extendPlayerWrapper(extender)
    table.insert(API.Extenders.PlayerWrapper, extender)
end

return API