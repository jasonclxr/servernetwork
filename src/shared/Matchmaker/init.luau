--!strict

-- Services
local httpService = game:GetService("HttpService")
local memoryStoreService = game:GetService("MemorystoreService")
local runService = game:GetService("RunService")

local types = require(script.Parent.Types)

-- Constants
local MATCHMAKER_KEY = "Matchmaker"
local MATCHMAKER_VERSION = 1
