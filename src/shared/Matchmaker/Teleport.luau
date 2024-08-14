local teleports = {}
local types = require(script.Parent.Types)
local services = require(script.Parent.Services)

teleports.RETRY_DELAY = 1
teleports.ATTEMPT_LIMIT = 3

function teleports:SafeTeleport(placeId: number, players: {[number]: Player}, tpOptions: any?) : (boolean, string?)
	local attemptIndex: number = 0
	local success: boolean, result: string?

	local function teleport()
		repeat
			success, result = pcall(function()
				return services.teleportService:TeleportAsync(placeId, players, tpOptions)
			end)
			attemptIndex += 1
			if not success then
				task.wait(teleports.RETRY_DELAY)
			end
		until success or attemptIndex == teleports.ATTEMPT_LIMIT
	end

	teleport()

	if not success then
		warn(result)
	end

	return success, result
end

return teleports