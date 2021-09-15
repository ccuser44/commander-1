--[[
    Log.lua
    =======

    Write logs and have them accessible in server.

    TODO
]]

local Log = {}

local strict = require(script.Parent.Parent.strict)

local DEFAULT_LOG_INTERVAL = 30

local function reverseTable(table)
    local result = {}
    for index = 1, math.floor(#table / 2) do
        result[index] = table[#table - index + 1]
        result[#table - index + 1] = table[index]
    end

    return result
end

function Log.new(name)
    local object = setmetatable({
        ["_data"] = {},
        ["Name"] = name,
    }, Log)

    return object
end

function Log:getLogs(interval, page)
    page = math.min(1, page or 1)
    interval = interval or DEFAULT_LOG_INTERVAL

    local reversedTable = reverseTable(self._data)
    local thatPage = {}

    if reversedTable[interval * (page - 1) + 1] then
        for index = interval * (page - 1) + 1, interval * (page + 1) do
            table.insert(thatPage, reversedTable[index])
        end

        return thatPage
    else
        return nil
    end
end

function Log:write(user, action, target, attachment)
    table.insert(self._data, {
        ["Timestamp"] = os.time(),
        ["Administrator"] = user,
        ["Action"] = action,
        ["Target"] = target,
        ["Attachment"] = attachment
    })
end

return strict {
    ["new"] = Log.new
}