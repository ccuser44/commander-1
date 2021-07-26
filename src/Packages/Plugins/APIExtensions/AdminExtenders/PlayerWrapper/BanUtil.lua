-- TODO: finish datastore

local package = {
    Name = "BanUtil",
    Description = "A plugin that adds a ban system to Commander, meant to be used with the command",
    Author = "7kayoh",
    Class = "Plugin",
    Target = {}
}

function package.Target.extenderFunction(player, wrapper)
    
end

function package.Target:Init()
    package.Target.Settings = require(package.Core.Settings)
    package.API.extendPlayerWrapper(package.Target.extenderFunction)
end

return package