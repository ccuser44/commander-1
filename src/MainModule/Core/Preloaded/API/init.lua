local API = {}
API.Checkers = {}

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

function API.getAdminStatus(userId)
    local currentPriority = 0

end

function API.checkUserAdmin(player)
    if CollectionService:HasTag(player, "Commander_Admin") then
        return true
    elseif not CollectionService:HasTag(player, "Commander_Loaded") then
        -- User was not previously loaded by Commander, a rank check is necessary

    end

    return false
end

function API.addChecker(name, checkerFunction)
    dLog("Success", "Added checker " .. name .. ", got " .. #API.Checkers .. " checkers so far")
    API.Checkers[name] = checkerFunction
end

function API.initializePlayer(player)
    local currentIndex
    dLog("Info", "Received request")
    for name, checker in pairs(API.Checkers) do
        dLog("Info", "At checker " .. name)
        local index = checker(player.UserId)
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
        dLog("Info", player.UserId .. " is an administrator with permission " .. currentIndex)
        CollectionService:AddTag(player, "Commander_Admin")
        CollectionService:AddTag(player, "Commander_Loaded")
    end
end

return API