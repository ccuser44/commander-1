-- 7kayoh
-- MainModule
-- August 24, 2020

-- Singletons
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Private declarations
local Assets = script.Assets
local Core = script.Core
local Shared = script.Assets.Shared:Clone()
Shared.Parent = ReplicatedStorage
local Packages, Remotes = nil, nil

local Constants = require(Core.Constants)
local dLog = require(Core.dLog)
local Validify = require(Core.Validify)
local void = require(Core.Void)
local t = require(Shared.t)
local Settings = nil

local Injectables = {}
local Invokers = {}
local LoadedPkg = {
    Command = {
        Server = {},
        Player = {}
    },
    Stylesheet = {},
    Plugin = {
        Server = {},
        Client = {}
    }
}

local Types = {
    assert = t.strict(boolean),
    CopyTable = t.strict(t.table),
    CommandInvoker = t.strict(t.instanceIsA("Player"), t.string),
    InitPkg = t.strict(t.instanceIsA("ModuleScript")),
    LoadPkg = t.strict(t.instanceIsA("ModuleScript")),
    InitPlugin = t.strict(t.table),
    Return = t.strict(t.instanceIsA("ModuleScript"), t.instanceIsA("Folder"))
}

-- Functions
local function assert(condition, ...)
    Types.assert(condition)
    if not condition then
        dLog("Error", ...)
    end
end

local function CopyTable(table)
    Types.CopyTable(table)
	local Copy = {}
	for Key, Value in next, table do
		if type(value) == "table" then
			Copy[Key] = CopyTable(Value)
		else
			Copy[Key] = Value
		end
	end
	
	return Copy
end

function Invokers.OnCommand(player, requestType, ...)
    Types.CommandInvoker(player, requestType)

    local Arguments = {...}
    local Name = table.remove(Arguments, 1)
    local Category = table.remove(Arguments, 2)
    assert(table.find({"Server", "Player"}, Category), Category .. " is not a valid member of CommandCategory")

    local ErrorMessage = "No error message defined"
    local Index = table.find(LoadedPkg.Command[Category], commandName)
    
    if Index then
        local UserGroup = Settings.Groups[player.AdminIndex]
        if table.find(UserGroup.Commands, Name) or table.find(UserGroup.Commands, "*") then
            local Pkg = LoadedPkg.Commands[Category][CommandIndex]
            return Pkg.Target(player, requestType, Arguments)
        else
            ErrorMessage = "Insufficient permission"
        end
    else
        ErrorMessage = "Command does not exist"
    end
    
    return false, ErrorMessage
end

local function InitPkg(pkg)
    Types.InitPkg(pkg)
    
    local RequiredPkg = require(pkg)
    if Validify.ValidatePkg(RequiredPkg) then
        if table.find({"Command", "Plugin"}, RequiredPkg.Class) then
            pkg.Parent = Packages[RequiredPkg.Class][RequiredPkg.Category]
        else
            pkg.Parent = Packages[RequiredPkg.Class]
        end
    end
end

local function LoadPkg(pkg)
    Types.InitPkg(pkg)
    
    local RequiredPkg = require(pkg)
    local PkgInfo = {}
    
    for Name, Value in next, RequiredPkg do
        PkgInfo[Name] = Value or void
    end
    
    RequiredPkg.Settings = CopyTable(Settings)
    RequiredPkg.Core = Core
    RequiredPkg.Util = Injectables
    RequiredPkg.API = RequiredPkg.Util.API
    RequiredPkg.Shared = Shared
    RequiredPkg.Plugins = PkgInfo.Class == "Command" and LoadedPkg.Plugin or nil
    
    if table.find({"Command", "Plugin"}, PkgInfo.Class) then
        LoadedPkg[PkgInfo.Class][PkgInfo.Category][PkgInfo.Name] = PkgInfo
    else
        LoadedPkg[PkgInfo.Class][PkgInfo.Name] = PkgInfo
    end
end

local function InitPlugin(pkg)
    Types.InitPlugin(pkg)
    
    if pkg.Category == "Server" and pkg.Target.Init then
        pkg.Target:Init()
    end
end

-- Returns
return function(userSettings, userPkgs)
    Types.Return(userSettings, userPkgs)
    dLog("Info", "Welcome to V2")
    
    Remotes = Instance.new("Folder")
    Remotes.Name = "Remotes"
    Remotes.Parent = ReplicatedStorage
    Instance.new("RemoteEvent").Parent = Remotes
    Instance.new("RemoteFunction").Parent = Remote
    
    Packages = Instance.new("Folder")
    Packages.Name = "Packages"
    Packages.Parent = script
    
    local Temp = nil -- temporary holder, will be gc'd eventually
    Temp = Instance.new("Folder")
    Temp.Name, Temp.Parent = "Command", Packages
    Temp = Instance.new("Folder")
    Temp.Name, Temp.Parent = "Server", Packages.Command
    Temp = Instance.new("Folder")
    Temp.Name, Temp.Parent = "Player", Packages.Command
    Temp = Instance.new("Folder")
    Temp.Name, Temp.Parent = "Stylesheet", Packages
    Temp = Instance.new("Folder")
    Temp.Name, Temp.Parent = "Plugin", Packages
    Temp = Instance.new("Folder")
    Temp.Name, Temp.Parent = "Server", Packages.Plugin
    Temp = Instance.new("Folder")
    Temp.Name, Temp.Parent = "Player", Packages.Plugin
    Temp = nil
    
    userSettings.Name = "Settings"
    userSettings.Parent = Core
    Settings = require(userSettings)
    
    for _, Component in next, Core.Injectables:GetChildren() do
        if Component:IsA("ModuleScript") then
            Injectables[Component.Name] = require(Component)
        end
    end
    
    for _, Pkg in next, userPkgs:GetDescendants() do
        if Pkg:IsA("ModuleScript") then
            InitPkg(Pkg)
        end
    end
    for _, Pkg in next, Packages:GetDescendants() do
        if Pkg:IsA("ModuleScript") then
            LoadPkg(Pkg)
        end
    end
    for _, Plugin in next, LoadedPkg.Plugin do
        InitPlugin(Plugin)
    end
    
    Injectables.API.initialize(Remotes)
    
    for Name, Invoker in next, Invokers do
        Injectables.API.AddRemoteTask("Function", Name, Invoker)
    end
    
    Players.PlayerAdded:Connect(function(player)
        Injectables.API.InitializePlayer(player)
    end)
    for _, Player in next, Players:GetPlayers() do
        Injectables.API.InitializePlayer(Player)
    end
    
    dLog("Success", "Loaded")
    return true
end
