local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local assetsFolder = script.Assets
local coreFolder = script.Core
local injectablesFolder = coreFolder.Injectables
local packagesFolder, remotesFolder = nil, nil

local dLog = require(coreFolder.dLog)
local constants = require(coreFolder.Constants)
local validify = require(coreFolder.Validify)
local void = require(coreFolder.Void)
local settings = nil

local injectables = {}
local loadedPkg = {
    ["Command"] = {
        ["Server"] = {},
        ["Player"] = {}
    },
    ["Stylesheet"] = {},
    ["Plugin"] = {}
}

local function assert(condition, ...)
    if not condition then
        dLog("Error", ...)
    end
end

function copyTable(table)
    if typeof(table) ~= "table" then
        return table
    end

    local result = setmetatable({}, getmetatable(table))
    for index, value in pairs(table) do
        result[copyTable(index)] = copyTable(value)
    end

    return result
end

local function onCommandInvoke(player, requestType, ...)
    local arguments = {...}
    local commandName = table.remove(arguments, 1)
    local category = table.remove(arguments, 2)
    local commandIndex = table.find(loadedPkg.Command[category], commandName)

    assert(table.find({"Server", "Player"}, category),
    "Expects Server/Player, got " .. category)

    if commandIndex then
        local userGroup = settings.Groups[player.AdminIndex]
        if table.find(userGroup.Commands, commandName) or
        table.find(userGroup.Commands, "*") then
            local pkg = loadedPkg.Commands[category][commandIndex]
            return pkg.Target(player, requestType, arguments)
        end
    end

    return false
end

local function initPkg(pkg)
    if pkg:IsA("ModuleScript") then
        local requiredPkg = require(pkg)

        if validify.validatePkg(requiredPkg) then
            dLog("Success", pkg.Name .. " is a valid package")

            if requiredPkg.Class == "Command" then
                pkg.Parent = packagesFolder.Command[requiredPkg.Category]
            else
                pkg.Parent = packagesFolder[requiredPkg.Class]
            end
            dLog("Success", "Initialized package " .. pkg.Name)
        else
            dLog("Warn", pkg.Name .. " is not a valid package")
        end
    end
end

local function loadPkg(pkg)
    if pkg:IsA("ModuleScript") then
        pkg = require(pkg)
        local pkgInfo = {
            ["Name"] = pkg.Name,
            ["Description"] = pkg.Description,
            ["Author"] = pkg.Author,
            ["Class"] = pkg.Class,
            ["Category"] = pkg.Category or void,
            ["Target"] = pkg.Target
        }

        pkg.Settings = copyTable(settings)
        pkg.Core = coreFolder
        pkg.Util = injectables
        pkg.API = pkg.Util.API

        if pkg.Class == "Command" then
            pkg.Plugins = loadedPkg.Plugin
            loadedPkg.Command[pkg.Category][pkg.Name] = pkgInfo
        else
            loadedPkg[pkg.Class][pkg.Name] = pkgInfo
        end

        dLog("Success", "Loaded package " .. pkg.Name)
    end
end

local function initPlugin(pkg)
    if typeof(pkg.Target) == "table" and pkg.Target.Init then
        dLog("Wait", "Initialize plugin " .. pkg.Name)
        pkg.Target:Init()
        dLog("Success", "Initialized plugin " .. pkg.Name)
    end
end

return function(userSettings, userPkg)
    assert(userSettings, "Expect user configuration, got nil")
    assert(userPkg, "Expect user packages, got nil")
    dLog("Info", "Welcome to V2")

    remotesFolder = Instance.new("Folder", ReplicatedStorage)
    remotesFolder.Name = "Commander"
    Instance.new("RemoteEvent", remotesFolder)
    Instance.new("RemoteFunction", remotesFolder)
    dLog("Success", "Created remotes")

    packagesFolder = Instance.new("Folder", script)
    packagesFolder.Name = "Packages"
    Instance.new("Folder", packagesFolder).Name = "Command"
    Instance.new("Folder", packagesFolder.Command).Name = "Server"
    Instance.new("Folder", packagesFolder.Command).Name = "Player"
    Instance.new("Folder", packagesFolder).Name = "Stylesheet"
    Instance.new("Folder", packagesFolder).Name = "Plugin"
    dLog("Success", "Created packages folder and its descendants")

    userSettings.Name = "Settings"
    userSettings.Parent = coreFolder
    settings = userSettings
    dLog("Success", "Injected user configuration")

    dLog("Wait", "Load injectables")
    for _, component in ipairs(injectablesFolder:GetChildren()) do
        if component:IsA("ModuleScript") then
            injectables[component.Name] = require(component)
            dLog("Success", "Loaded " .. component.Name)
        end
    end
    dLog("Success", "Loaded all injectables")

    dLog("Wait", "Load user packages")
    if #userPkg:GetDescendants() == 0 then
        dLog("Info", "No user packages found")
    end
    for _, pkg in ipairs(userPkg:GetDescendants()) do
        initPkg(pkg)
    end
    dLog("Success", "Loaded user packages")
    for _, pkg in ipairs(packagesFolder:GetDescendants()) do
        loadPkg(pkg)
    end
    dLog("Success", "Initialized user packages")

    dLog("Wait", "Initialize plugins")
    for _, pkg in pairs(loadedPkg.Plugin) do
        initPlugin(pkg)
    end
    dLog("Success", "Initialized plugins")

    dLog("Wait", "Initialize API")
    injectables.API.initialize(remotesFolder)
    dLog("Success", "Initialized API")
    
    dLog("Wait", "Connect remotes")
    injectables.API.addRemoteTask("Function", "onCommand", onCommandInvoke)
    dLog("Success", "Added an onCommandInvoke task for RemoteFunction")
    dLog("Success", "Connected remotes")

    dLog("Wait", "Connect player events and initialize existing players")
    Players.PlayerAdded:Connect(function(player)
        injectables.API.initializePlayer(player)
    end)
    dLog("Success", "Connected player events")
    for _, player in ipairs(Players:GetPlayers()) do
        injectables.API.initializePlayer(player)
    end
    dLog("Success", "Initialized existing players")
    dLog("Success", "Complete setup")
end