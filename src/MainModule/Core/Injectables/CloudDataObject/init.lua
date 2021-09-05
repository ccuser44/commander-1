-- TODO

local MessagingService = game:GetService("MessagingService")

local settings = require(script.Parent.Parent.Settings)
local strict = require(script.Parent.Parent.strict)
local void = require(script.Parent.Parent.Void)
local activeInstances = {}
local onNewMessage = Instance.new("BindableEvent")
local tick = os.time

-- Private functions
local function deepCopyTable(table: {any})
	local copy = {}
	for key, value in pairs(table) do
		if type(value) == "table" then
			copy[key] = deepCopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function reconcileTable(target: {any}, template: {any})
    for k, v in pairs(template) do
        if type(k) == "string" then
            if target[k] == nil then
                if type(v) == "table" then
                    target[k] = deepCopyTable(v)
                else
                    target[k] = v
                end
            elseif type(target[k]) == "table" and type(v) == "table" then
                reconcileTable(target[k], v)
            end
        end
    end
end

local function safePcall(retryForever: boolean, functionToCall: () -> any, ...: any)
    local retries = 0
    local response = {pcall(functionToCall, ...)}
    
    while not response[1] and retries < (retryForever and math.huge or 3) do
        response = {pcall(functionToCall, ...)}
        retries += 1
        task.wait(5)
    end

    return table.remove(response, 1), unpack(response)
end

local function waitForResponse(validifyFunction: ({any}) -> boolean): {any}
    local data = {}

    while validifyFunction(data) ~= true do
        data = onNewMessage.Event:Wait()
    end

    return data
end

-- Components
local instance = {}

function instance:AddQueue(queueFunction: () -> any)
    if self._QueueLocked then return end
    table.insert(self._Queue, queueFunction)
end

function instance:ClearDataAsync()
    self:_AddToQueue(function()
        self._Data = {}
        self:SetWaypoint("BeforeClearDataAsync")
        self:Reconcile()
        self:SaveAsync()
    end)
end

function instance:GetData()
    self:_AddToQueue(function()
        if self._Data then
            return self._Data
        else
            local _, data, keyInfo = safePcall(true,
                                               self.Parent.GetAsync,
                                               self.Parent,
                                               self.Name
                                              )
            self._Data = data or {}
            self._Meta = keyInfo:GetMetadata()
            self.KeyInfo = keyInfo
            self.UserId = keyInfo:GetUserIds()

            self:Reconcile()
        end
    end)
end

function instance:Reconcile(): {any}
    assert(self._Template, "Reconcile was called, but there is no template available to be reconciled")
    self:_AddToQueue(function()
        reconcileTable(self._Data, self._Template)
        
        return self._Data
    end)
end

function instance:Release()
    self._AddToQueue(function()
        local name = self.Name
        self._Data = nil
        self._Template = nil
        self._Meta = nil
        self.Parent = nil
        self.KeyInfo = nil
        safePcall(true,
                  MessagingService.PublishAsync,
                  MessagingService,
                  "CloudDataObject",
                  "ReleaseInstance",
                  self.Parent.Name,
                  name
                 )
    end)

    self:_LockQueue(true)
end

function instance:SaveAsync()
    self:_AddToQueue(function()
        local setOptions = Instance.new("DataStoreSetOptions")
        setOptions:SetMetadata(self._Meta)
        local success, result = safePcall(false,
                                          self.Parent.SetAsync,
                                          self.Parent,
                                          self.Name,
                                          self._Data,
                                          self.UserId,
                                          setOptions
                                         )

        -- todo: proper error-handling
    end)
end

function instance:SetWaypoint(waypointName: string)
    self._addToQueue(function()
        table.insert(self._Meta.Waypoints, {
            ["Name"] = waypointName,
            ["Time"] = os.time()
        })
    end)
end

function instance:_LockQueue(toggle: boolean)
    self._QueueLocked = toggle
end

function instance:_StartQueueDaemon()
    while self._Status ~= "Released" do
        safePcall(true, table.remove(self._Queue[1]))
        task.wait()
    end
end

-- Something else
MessagingService:SubscribeAsync("CloudDataObject", function(data: {any}, sent: number)
    if activeInstances[data[2]] and activeInstances[data[2]][3] then
        safePcall(true,
                  MessagingService.PublishAsync,
                  MessagingService,
                  "CloudDataObject",
                  "IsInstanceBusy",
                  data[2],
                  data[3],
                  true
                 )
    end

    onNewMessage:Fire(data, sent)
end)

-- Exports
return strict {
    ["new"] = function(globalDataStore: GlobalDataStore, key: string, template: {[any]: any})
        local data = waitForResponse(function(data)
            return data[1] == "IsInstanceBusy" and data[2] == globalDataStore.Name and data[3] == key and data[4] == false
        end)

        safePcall(true,
                  MessagingService.PublishAsync,
                  MessagingService,
                  "CloudDataObject",
                  "OccupyInstance",
                  globalDataStore.Name,
                  key
                )
        
        local self = {}
        setmetatable(self, instance)

        self.Name = key
        self.Parent = globalDataStore
        self._Template = template
        self._Status = "Alive"
        self._Queue = {}

        self:_StartQueueDaemon()
        self:GetData()

        return self
    end
}