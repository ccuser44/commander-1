--!strict

local API = {}
API.Remotes = {}
API.Checkers = {}
API.Extenders = {
    PlayerWrapper = {}
}

local CollectionService = game:GetService("CollectionService")

local core = script.Parent.Parent
local settings = require(core:FindFirstChild("Settings"))
local dLog = require(core.dLog)

local function assert(condition: boolean, ...: any?)
    if not condition then
        dLog("Error", ...)
    end
end

local function safePcall(functionToCall: (any?) -> any?, ...: any?): (boolean, any?)
    local retries: number = 0
    local success: boolean, result: any? = pcall(functionToCall, ...)
    
    while not success and retries < 3 do
        success, result = pcall(functionToCall, ...)
        retries += 1
        wait(5)
    end

    return success, result
end

function API.getAdminStatusWithUserId(userId: number): (number?, string?)
    local currentIndex: number? = nil
    dLog("Info", "Received request of " .. userId)
    for name, checker in pairs(API.Checkers) do
        dLog("Info", "At checker " .. name)
        local index: number? = checker(userId)
        dLog("Info", "Got group index of " .. tostring(index))
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
	else
		return nil, nil
    end
end

function API.getAdminLevel(player: Player): (number?, string?)
    return player:GetAttribute("Commander_AdminIndex"), player:GetAttribute("Commander_AdminGroup")
end

function API.checkUserAdmin(player: Player): (boolean)
    return CollectionService:HasTag(player, "Commander_Admin")
end

function API.initializePlayer(player: Player)
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

function API.wrapPlayer(player: Player): any
    local wrapper: any = { -- have to use any for the moment, figuring out
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

function API.addRemoteTask(remoteType: string, qualifier, handler)
    assert(remoteType == "Function" or remoteType == "Event", "Invalid remote type, expects either Function or Event")
    local task = {}
    task._remoteType = remoteType
    task._handler = handler
    if typeof(qualifier) == "string" then
        task._qualifier = function(player, requestType)
            return requestType == qualifier
        end
    else
        task._qualifier = qualifier
    end

    function task.leave()
        table.remove(API.Remotes[remoteType], table.find(API.Remotes[remoteType], handler))
    end

    table.insert(API.Remotes[remoteType], task)
    return task
end

function API.addChecker(name: string, checkerFunction: (number?) -> boolean)
    dLog("Success", "Added checker " .. name .. ", got " .. #API.Checkers .. " checkers so far")
    API.Checkers[name] = checkerFunction
end

function API.extendPlayerWrapper(extender: (Player) -> any?)
    table.insert(API.Extenders.PlayerWrapper, extender)
end

function API.initialize(remotes: Folder)
    local remoteFunction: RemoteFunction? = remotes:FindFirstChildOfClass("RemoteFunction")
    local remoteEvent: RemoteEvent? = remotes:FindFirstChildOfClass("RemoteEvent")
    API.Remotes.Function = {}
    API.Remotes.Event = {}

    assert(remoteFunction and remoteEvent, "Can't find either RemoteFunction or RemoteEvent, aborting")
    -- ^ Supposed to not warn about incorrect types!

    remoteFunction.OnServerInvoke = function(player: Player, requestType: string, ...: any?): any?
        player = API.wrapPlayer(player)
        for _, task in ipairs(API.Remotes.Function) do
            if task.qualifier(player, requestType) then
                return task._handler(player, requestType, ...)
            end
        end
    end

	remoteEvent.OnServerEvent:Connect(function(player: Player, requestType: string, ...: any?)
        player = API.wrapPlayer(player)
        for _, task in ipairs(API.Remotes.Event) do
            if task.qualifier(player, requestType) then
                return task._handler(player, requestType, ...)
            end
        end
    end)
end

return API