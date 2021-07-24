local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = script.Assets
local core = script.Core
local packages
local preloaded = core.Preloaded

local DEBUG_MODE = true
local LOG_CONTEXTS = {
    ["Wait"] = "Commander; ⏳ %s",
    ["Warn"] = "Commander; ⚠️ %s",
    ["Success"] = "Commander; ✅ %s",
    ["Error"] = "Commander; 🚫 %s",
    ["Confusion"] = "Commander; 🤷🏻‍♂️ %s",
    ["Info"] = "Commander; ℹ️ %s"
}
local utilities = {}
local loadedPackages = {
    ["Command"] = {
        ["Server"] = {},
        ["Player"] = {}
    },
    ["Stylesheet"] = {},
    ["Plugin"] = {}
}

local function dLog(context, ...)
    if DEBUG_MODE then
        if LOG_CONTEXTS[context] then
            if context == "Error" then
                error(string.format(LOG_CONTEXTS[context], ...))
            elseif context == "Warn" then
                warn(string.format(LOG_CONTEXTS[context], ...))
            else
                print(string.format(LOG_CONTEXTS[context], ...))
            end
        end
    end
end

local function assert(condition, ...)
    if not condition then
        error(string.format(LOG_CONTEXTS.Error, ...))
    end
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
dLog("Wait", "Loading all preloaded components...")
for _, component in ipairs(preloaded:GetChildren()) do
    if component:IsA("ModuleScript") then
        utilities[component.Name] = require(component)
        dLog("Success", "Loaded component " .. component.Name)
    end
end
dLog("Success", "Complete, listening for requests...")

return function(settings, userPackages)
    assert(settings, "User configuration found missing, aborted!")
    assert(settings, "User packages found missing, aborted!")
    dLog("Wait", "Starting system...")

    Instance.new("Folder", ReplicatedStorage).Name = "Commander"
    Instance.new("RemoteEvent", ReplicatedStorage.Commander)
    Instance.new("RemoteFunction", ReplicatedStorage.Commander)
    dLog("Success", "Initialized remotes...")

    packages = Instance.new("Folder", script)
    packages.Name = "Packages"
    Instance.new("Folder", packages).Name = "Commands"
    Instance.new("Folder", packages.Commands).Name = "Server"
    Instance.new("Folder", packages.Commands).Name = "Player"
    Instance.new("Folder", packages).Name = "Stylesheets"
    Instance.new("Folder", packages).Name = "Plugins"
    dLog("Success", "Initialized package system...")

    settings.Name = "Settings"
    settings.Parent = core
    dLog("Success", "Loaded user configuration...")

    if #userPackages:GetDescendants() == 0 then
        dLog("Warn", "There was no package to load with...")
    end

    for _, package in ipairs(userPackages:GetDescendants()) do
        if package:IsA("ModuleScript") then
            dLog("Wait", "Initializing package " .. package.Name)
            local requiredPackage = require(package)

            if utilities.Validify.validatePkg(requiredPackage) then
                dLog("Success", package.Name .. " is a valid package...")
                if requiredPackage.Class ~= "Command" then
                    package.Parent = packages[requiredPackage.Class]
                else
                    package.Parent = packages.Commands[requiredPackage.Category]
                end
                dLog("Success", "Complete initializing package " .. package.Name ..", moving on...")
            else
                dLog("Warn", "Package " .. package.Name .. " is not a valid package and has been ignored")
            end
        end
    end

    dLog("Wait", "Setting up packages...")
    for _, package in ipairs(packages:GetDescendants()) do
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
            package.API = utilities.API
            package.Util = utilities

            if package.Class == "Command" then
                loadedPackages.Command[package.Category][package.Name] = packageInfo
            else
                loadedPackages[package.Class][package.Name] = packageInfo
            end
        end
    end

    for _, package in ipairs(loadedPackages.Plugin) do
        if typeof(package.Target) == "table" and package.Target.Init then
            dLog("Wait", "Initializing plugin " .. package.Name .. "...")
            package.Target:Init()
            dLog("Success", "Initialized plugin " .. package.Name)
        end
    end

    dLog("Success", "Finished initializing all packages...")
    dLog("Wait", "Connecting to remotes...")

end