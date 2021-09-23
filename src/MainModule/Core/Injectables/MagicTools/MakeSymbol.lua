return function(symbolName: string): any
    local symbol = newproxy(true)

    getmetatable(symbol).__tostring = function()
        return symbolName
    end

    return symbol
end