local Package
local PackageTarget = {}

local GroupService = game:GetService("GroupService")

local function safePcall(functionToCall, ...)
    local retries = 0
    local success, result = pcall(functionToCall, ...)
    
    while not success and retries < 3 do
        success, result = pcall(functionToCall, ...)
        retries += 1
        wait(5)
    end

    return success, result
end

local function checkGroupRank(groupsInfo, groupId, ranks, allowEqual)
    local correctGroupInfo
    for _, group in ipairs(groupsInfo) do
        if group.Id == tonumber(groupId) then
            correctGroupInfo = group
            break
        end
    end

    if correctGroupInfo then
        local userRank = correctGroupInfo.Rank
        if allowEqual and userRank >= ranks[1] and userRank <= ranks[2] then
            return true
        elseif userRank > ranks[1] and userRank < ranks[2] then
            return true
        end
        return false
    end
end

function PackageTarget.OnInvoke(userId)
    local currentIndex = 0
    for _, permission in ipairs(PackageTarget.Settings.Permissions) do
        if permission.Type == "Group" then
            local allowed
            local groupIndex = PackageTarget.GroupsIndex[permission.Group]
            local success, groupsInfo = safePcall(GroupService.GetGroupsAsync, GroupService, userId)

            if not success then return nil end

            if typeof(permission.Authorize) == "table" then
                for _, authorize in ipairs(permission.Authorize) do
                   local authorizeAllowed = checkGroupRank(groupsInfo, authorize, permission.Range, permission.AcceptEqual)
                   if authorizeAllowed then
                        allowed = true
                        break
                   end
                end
            else
                local authorizeAllowed = checkGroupRank(groupsInfo, permission.Authorize, permission.Range, permission.AcceptEqual)
                if authorizeAllowed then
                     allowed = true
                end
            end

            if allowed and currentIndex < groupIndex then
                currentIndex = groupIndex
            end

            if currentIndex == #PackageTarget.Settings.Groups then
                break
            end
        end
    end

    return currentIndex
end

function PackageTarget:Init()
    PackageTarget.Settings = require(Package.Core.Settings)
    PackageTarget.GroupsIndex = {}

    for index, group in ipairs(PackageTarget.Settings.Groups) do
        PackageTarget.GroupsIndex[group.Name] = index
    end


    Package.API.addChecker("Group", PackageTarget.OnInvoke)
end

Package = {
    Name = "GroupsChecker",
    Description = "Adds group support to the API's admin checking function",
    Author = "7kayoh",
    Class = "Plugin",
    Target = PackageTarget
}

return Package