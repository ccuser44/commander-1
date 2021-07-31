return function(table, name)
    name = name or tostring(table)

    return setmetatable(table, {
        __index = function(_, key)
            error(("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), name), 2)
        end,

        __newindex = function(_, key)
            error(("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), name), 2)
        end
    })
end