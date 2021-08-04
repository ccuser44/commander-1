local Validify = {}

local acceptedPkgClass = {"Command", "Stylesheet", "Plugin"}
local acceptedCommandCategory = {"Player", "Server"}
local acceptedPluginCategory = {"Client", "Server"}

function Validify.validatePkg(pkgTable)
    if typeof(pkgTable) == "table" then
        if pkgTable.Name and pkgTable.Description and pkgTable.Class and pkgTable.Author then
            if table.find(acceptedPkgClass, pkgTable.Class) then
                if pkgTable.Class == "Command" and table.find(acceptedCommandCategory, pkgTable.Category) then
                    return true
                elseif pkgTable.Class == "Plugin" and table.find(acceptedPluginCategory, pkgTable.Category) then
                    return true
                elseif pkgTable.Class ~= "Command" then
                    return true
                end
            end
        end
    end

    return false
end

return Validify