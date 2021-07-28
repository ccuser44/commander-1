local API = {}
API.Remotes = {}
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

function API.addRemoteTask(remoteType, qualifier, handler)
    assert(remoteType == "Function" or remoteType == "Event", "Invalid remote type, expects either Function or Event")
    local task = {}
    task._remoteType = remoteType
    task._handler = handler
    task._qualifier = qualifier or function() return true end

    function task.leave()
        table.remove(API.Remotes[remoteType], table.find(API.Remotes[remoteType], handler))
    end

    table.insert(API.Remotes[remoteType], task)
    return task
end

function API.addChecker(name, checkerFunction)
    dLog("Success", "Added checker " .. name .. ", got " .. #API.Checkers .. " checkers so far")
    API.Checkers[name] = checkerFunction
end

function API.extendPlayerWrapper(extender)
    table.insert(API.Extenders.PlayerWrapper, extender)
end

function API.initialize(remotes)
    API.Remotes.Function = {}
    API.Remotes.Event = {}

    remotes.RemoteFunction.OnServerInvoke = function(player, requestType, ...)
        for _, task in ipairs(API.Remotes.Function) do
            if task.qualifier(player, requestType) then
                return task._handler(player, requestType, ...)
            end
        end
    end

    remotes.RemoteEvent.OnServerEvent:Connect(function(player, requestType, ...)
        for _, task in ipairs(API.Remotes.Event) do
            if task.qualifier(player, requestType) then
                task._handler(player, requestType, ...)
            end
        end
    end)
end

return API