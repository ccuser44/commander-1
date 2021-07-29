local symbol = newproxy(true)

getmetatable(symbol).__tostring = function()
    return "void"
end

return symbol