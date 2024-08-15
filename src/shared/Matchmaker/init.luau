local services = require(script.Parent.Services)

-- Types
local types = require(script.Types)

-- Constants
local MATCHMAKER_KEY = "Matchmaker"
local INVISIBILITY_TIMEOUT = 60

-- MemoryStore
local MATCHMAKER_QUEUE = services.memoryStoreService:GetQueue(
    MATCHMAKER_KEY,
    INVISIBILITY_TIMEOUT
)
local MATCHMAKER_STATUS = services.memoryStoreService:GetSortedMap(
    MATCHMAKER_KEY
)

local matchmaker = {}

function matchmaker:Start()

end

function matchmaker:AddPlayersToQueue(players: {[number]: UnmatchedPlayer})
    for _, player: UnmatchedPlayer in players do
        local setStatus, result = pcall(function()
            MATCHMAKER_STATUS:SetAsync(player.UserId, player)
        end)
        if not setStatus then return warn("Failed to add player(s) to queue:", result) end
    end
    
    local setQueue, result = pcall(function()
        MATCHMAKER_QUEUE:AddAsync()
    end)
    
end


export type UnmatchedPlayer = types.UnmatchedPlayer

return matchmaker