local package = {
    Name = "API",
    Description = "Reveals specific API methods to remote",
    Author = "7kayoh",
    Class = "Plugin",
    Category = "Server",
    Target = {}
}
local allowedRequests = {
    "getAdminLevel",
    "getAdminStatusWithUserId",
    "checkUserAdmin",
}

local dLog = nil

function package.Target.remoteTask(player, requestType, ...)
    dLog("Info", player.Name .. " is currently calling API method " .. requestType)
    return package.API[requestType](...)
end

function package.Target:Init()
    dLog = require(package.Core.dLog)
    package.API.addRemoteTask("Function", function(player, requestType)
        return package.API.checkUserAdmin(player) and table.find(allowedRequests, requestType) ~= nil
    end, package.Target.remoteTask)
end

return package