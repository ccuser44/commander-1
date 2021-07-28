local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local assetsFolder = script.Assets
local coreFolder = script.Core
local injectablesFolder = coreFolder.Injectables
local packagesFolder = nil
local remotesFolder = nil

local dLog = require(coreFolder.dLog)
local constants = require(coreFolder.Constants)
local validify = require(coreFolder.Validify)

local injectables = {}
local loadedPackages = {
    ["Command"] = {
        ["Server"] = {},
        ["Player"] = {}
    },
    ["Stylesheet"] = {},
    ["Plugin"] = {}
}

local function assert(condition, ...)
    if not condition then
        error(string.format("Commander; 🚫 %s", ...), 2)
    end
end

local function onCommandInvoke(Player, requestType, ...)
    local arguments = {...}
    local commandName = arguments[1]
    -- TODO

    return nil
end

function copyTable(table)
    if typeof(table) ~= "table" then return table end
    local result = setmetatable({}, getmetatable(table))
    for index, value in ipairs(table) do
        result[copyTable(index)] = copyTable(value)
    end

    return result
end

dLog("Info", "Welcome to V2")

return function(settings, userPackages)
    assert(settings, "User configuration found missing, aborted!")
    assert(settings, "User packages found missing, aborted!")
    dLog("Wait", "Starting system...")

    remotesFolder = Instance.new("Folder", ReplicatedStorage)
    remotesFolder.Name = "Commander"
    Instance.new("RemoteEvent", ReplicatedStorage.Commander)
    Instance.new("RemoteFunction", ReplicatedStorage.Commander)
    dLog("Success", "Initialized remotes...")

    packagesFolder = Instance.new("Folder", script)
    packagesFolder.Name = "Packages"
    Instance.new("Folder", packagesFolder).Name = "Command"
    Instance.new("Folder", packagesFolder.Command).Name = "Server"
    Instance.new("Folder", packagesFolder.Command).Name = "Player"
    Instance.new("Folder", packagesFolder).Name = "Stylesheet"
    Instance.new("Folder", packagesFolder).Name = "Plugin"
    dLog("Success", "Initialized package system...")

    settings.Name = "Settings"
    settings.Parent = coreFolder
    dLog("Success", "Loaded user configuration...")
    dLog("Wait", "Loading all preloaded components...")
    for _, component in ipairs(injectablesFolder:GetChildren()) do
        if component:IsA("ModuleScript") then
            injectables[component.Name] = require(component)
            dLog("Success", "Loaded component " .. component.Name)
        end
    end
    dLog("Success", "Complete loading all preloaded components, moving on...")

    if #userPackages:GetDescendants() == 0 then
        dLog("Warn", "There was no package to load with...")
    end

    for _, package in ipairs(userPackages:GetDescendants()) do
        if package:IsA("ModuleScript") then
            dLog("Wait", "Initializing package " .. package.Name)
            local requiredPackage = require(package)

            if validify.validatePkg(requiredPackage) then
                dLog("Success", package.Name .. " is a valid package...")
                if requiredPackage.Class ~= "Command" then
                    package.Parent = packagesFolder[requiredPackage.Class]
                else
                    package.Parent = packagesFolder.Command[requiredPackage.Category]
                end
                dLog("Success", "Complete initializing package " .. package.Name ..", moving on...")
            else
                dLog("Warn", "Package " .. package.Name .. " is not a valid package and has been ignored")
            end
        end
    end

    dLog("Wait", "Setting up packages...")
    for _, package in ipairs(packagesFolder:GetDescendants()) do
        if package:IsA("ModuleScript") then
            package = require(package)
            local packageInfo = {
                ["Name"] = package.Name,
                ["Description"] = package.Description,
                ["Class"] = package.Class,
                ["Category"] = package.Category or "N/A",
                ["Author"] = package.Author,
                ["Target"] = package.Target
            }

            package.Settings = copyTable(settings)
            package.API = injectables.API
            package.Core = coreFolder
            package.Util = injectables

            if package.Class == "Command" then
                loadedPackages.Command[package.Category][package.Name] = packageInfo
            else
                loadedPackages[package.Class][package.Name] = packageInfo
            end
        end
    end

    for _, package in pairs(loadedPackages.Plugin) do
        if typeof(package.Target) == "table" and package.Target.Init then
            dLog("Wait", "Initializing plugin " .. package.Name .. "...")
            package.Target:Init()
            dLog("Success", "Initialized plugin " .. package.Name)
        end
    end

    dLog("Success", "Finished initializing all packages...")
    injectables.API.initialize(remotesFolder)
    dLog("Wait", "Connecting to remotes...")
    injectables.API.addRemoteTask("Function", 
        function(player, requestType) 
            if requestType == "useCommand" and 
            injectables.API.checkUserAdmin(player) then
                return true
            end
        end, 
        onCommandInvoke
    )
    
    dLog("Success", "Connected")
    dLog("Wait", "Connecting player events and initializing for players...")
    Players.PlayerAdded:Connect(function(player)
        injectables.API.initializePlayer(player)
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        injectables.API.initializePlayer(player)
    end
    dLog("Success", "Done")
end