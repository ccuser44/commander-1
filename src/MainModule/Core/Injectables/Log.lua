--!strict

--[[
    Log.lua
    =======

    Write logs and have them accessible in server.

    TODO
]]

local Log = {}

local DEFAULT_LOG_LIMIT = 100

function Log.getLogs(limit: number?, page: number?): {any?}
    limit = limit or DEFAULT_LOG_LIMIT
    page = page or 1


end

function Log.write(user: string, action: string, target: string, attachment: {any?})

end

return setmetatable(Log, {
    __call = Log.write,
})