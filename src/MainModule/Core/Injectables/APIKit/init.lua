-- 7kayoh
-- API.lua
-- August 25, 2021

-- Singletons
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Private declarations
local Core = script.Parent.Parent
local Shared = ReplicatedStorage.Shared

local MagicTools = require(script.Parent.MagicTools)
local dLog = require(Core.dLog)
local Settings = require(Core.Settings)
local t = require(Shared.t)
local strictify = require(Shared.Strictify)
local profileService = require(Core.ProfileService)

local Types = {
    GetAdminStatusWithUserId = t.strict(t.integer),
    GetAdminLevel = t.strict(t.instanceIsA("Player")),
    CheckUserAdmin = t.strict(t.instanceIsA("Player")),
    InitializePlayer = t.strict(t.instanceIsA("Player")),
    WrapPlayer = t.strict(t.instanceIsA("Player")),
    AddRemoteTask = t.strict(t.string, t.union(t.string, t.callback), t.callback),
    AddChecker = t.strict(t.string, t.callback),
    ExtendPlayerWrapper = t.strict(t.callback),
    Initialize = t.strict(t.instanceIsA("Folder"))
}

-- Functions
local function SafePcall(functionToCall, ...)
    local retries = 0
    local success, result = pcall(functionToCall, ...)
    
    while not success and retries < 3 do
        success, result = pcall(functionToCall, ...)
        retries += 1
        wait(5)
    end

    return success, result
end

-- Return table
local API = {
    Remotes = {},
    Checkers = {},
    Extenders = {
        PlayerWrapper = {}
    }
}

function API.GetAdminStatusWithUserId(userId)
    Types.GetAdminStatusWithUserId(userId)
    local CurrentIndex = nil
    for Name, Checker in next, API.Checkers do
        local Index = Checker(userId)
        if Index and (CurrentIndex or 0) < Index then
            CurrentIndex = Index
        else
            continue
        end
        
        if Index == #Settings.Groups then
            break
        end
    end
    
    if CurrentIndex then
        return CurrentIndex, Settings.Groups[CurrentIndex].Name
    end
end

function API.GetAdminLevel(player)
    Types.GetAdminLevel(player)
    return player:GetAttribute("Commander_AdminIndex"), player:GetAttribute("Commander_AdminGroup")
end

function API.CheckUserAdmin(player)
    Types.CheckUserAdmin(player)
    return CollectionService:HasTag(player, "Commander_Admin")
end

function API.InitializePlayer(player)
    Types.InitializePlayer(player)
    if CollectionService:HasTag(player, "Commander_Loaded") then return end
    local GroupIndex, GroupName = API.GetAdminStatusWithUserId(player.UserId)

    if GroupIndex then
        player:SetAttribute("Commander_AdminIndex", GroupIndex)
        player:SetAttribute("Commander_AdminGroup", GroupName)
        CollectionService:AddTag(player, "Commander_Admin")
        CollectionService:AddTag(player, "Commander_Loaded")
    end
end

function API.WrapPlayer(player)
    Types.WrapPlayer(player)
    local Wrapper = {
        ["Name"] = player.Name,
        ["DisplayName"] = player.DisplayName,
        ["UserId"] = player.UserId,
        ["Character"] = player.Character or player.CharacterAdded:Wait(),
        ["IsAdmin"] = API.checkUserAdmin(player),
        ["_instance"] = player
    }

    Wrapper.AdminIndex, Wrapper.AdminGroup = API.getAdminLevel(player)

    for _, Extender in next, API.Extenders.PlayerWrapper do
        Extender(player, Wrapper)
    end

    return Wrapper
end

function API.getProfile(user)
    local userProfile = API.ProfileStore:LoadProfileAsync(user)
    if userProfile then
        userProfile:Reconcile()
        return userProfile
    end

    dLog("Warn", "Something seemed to be not working while trying to load the profile for " .. user)
    return nil
end

function API.AddRemoteTask(remoteType, qualifier, handler)
    Types.AddRemoteTask(remoteType, qualifier, handler)
    assert(remoteType == "Function" or remoteType == "Event", "Invalid remote type, expects either Function or Event")
    local Task = {}
    Task._remoteType = remoteType
    Task._handler = handler
    
    if typeof(qualifier) == "string" then
        Task._qualifier = function(_, requestType)
            return requestType == qualifier
        end
    else
        Task._qualifier = qualifier
    end

    function Task.leave()
        table.remove(API.Remotes[remoteType], table.find(API.Remotes[remoteType], handler))
    end

    table.insert(API.Remotes[remoteType], Task)
    return Task
end

function API.AddChecker(name, checkerFunction)
    Types.AddChecker(name, checkerFunction)
    API.Checkers[name] = checkerFunction
end

function API.extendPlayerWrapper(extender)
    Types.ExtendPlayerWrapper(extender)
    table.insert(API.Extenders.PlayerWrapper, extender)
end

function API.initialize(remotes)
    Types.Initialize(remotes)
    API.ProfileStore = profileService.GetProfileStore(
        Settings.Profiles.PlayerProfileStoreIndex,
        {}
    )
    API.Remotes.Function = {}
    API.Remotes.Event = {}

    remotes.RemoteFunction.OnServerInvoke = function(player, requestType, ...)
        player = API.WrapPlayer(player)
        for _, Task in next, API.Remotes.Function do
            if Task.qualifier(player, requestType) then
                return Task._handler(player, requestType, ...)
            end
        end
    end

    remotes.RemoteEvent.OnServerEvent:Connect(function(player, requestType, ...)
        player = API.WrapPlayer(player)
        for _, Task in next, API.Remotes.Event do
            if Task.qualifier(player, requestType) then
                return Task._handler(player, requestType, ...)
            end
        end
    end)
end

return API
