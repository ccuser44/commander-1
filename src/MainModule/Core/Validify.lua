-- 7kayoh
-- Validify.lua
-- August 25, 2021

-- Singletons
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Private declarations
local Shared = ReplicatedStorage.Shared

local t = require(Shared.t)
local strictify = require(Shared.Strictify)

local AcceptedValues = {
    PkgClass = {"Command", "Stylesheet", "Plugin"},
    CommandCategory = {"Player", "Server"},
    PluginCategory = {"Client", "Server"}
}
local Types = {
    ValidatePkg = t.strict(t.interface({
        Name = t.string,
        Description = t.string,
        Class = t.string,
        Author = t.string,
        Category = t.optional(t.string),
        Target = t.optional(t.union(t.table, t.callback))
    }))
}

local Validify = {}

function Validify.ValidatePkg(pkgTable)
    Types.ValidatePkg(pkgTable)
    
    if table.find(AcceptedValues.PkgClass, pkgTable.Class) then
        if table.find(AcceptedValues, pkgTable.Class .. "Category") then
            if Target ~= nil then
                return true
            end
            
            return false
        end
        
        return true
    end
    
    return false
end

return strictify(Validify)
