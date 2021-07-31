--[[
    Log.lua
    =======

    Write logs and have them accessible in server.

    TODO
]]

local Log = {}

function Log.getLogs()

end

function Log.write()

end

return setmetatable(Log, {
    __call = Log.write,
})