-- 7kayoh
-- UIKit.lua
-- August 24, 2021

-- Singletons
local RunService = game:GetService("RunService")

-- Private declarations
local Components = script.Components
local Shared = script.Parent

local strictify = require(Shared.strictify)

-- Runtime code
assert(RunService:IsClient(), "Can be only required when RunService:IsClient() is true")

-- Returns
return strictify {
  ["Window"] = require(Components.Window)
}
