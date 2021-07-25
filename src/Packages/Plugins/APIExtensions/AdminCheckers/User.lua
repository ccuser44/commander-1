local Package
local PackageTarget = {}

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
function PackageTarget.OnInvoke(userId)
    -- TODO
end

function PackageTarget:Init()
    PackageTarget.Settings = require(Package.Core.Settings)
    PackageTarget.GroupsIndex = {}

    for index, group in ipairs(PackageTarget.Settings.Groups) do
        PackageTarget.GroupsIndex[group.Name] = index
    end

    -- PackageTarget.API.addChecker("User", PackageTarget.OnInvoke)
end

Package = {
    Name = "UserChecker",
    Description = "Adds Username/UserId support to the API's admin checking function",
    Author = "7kayoh",
    Class = "Plugin",
    Target = PackageTarget
}

return Package