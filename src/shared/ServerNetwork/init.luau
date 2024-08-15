-- Services
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local runService = game:GetService("RunService")

-- Modules
local Promise = require(script.Parent.Promise)
local Signal = require(script.Parent.Signal)
local Types = require(script.Parent.Types)

-- Variables
local network = {}
local _activeRequests: { [string]: boolean } = {}
local _listener = Signal.new()

-- Functions
function network:SendAsync(serverId: string, content: any, method: string): Promise<Packet>
    local packet: Packet = {
        serverId = game.JobId,
        content = content,
        method = method or "GET",
        id = HttpService:GenerateGUID(false)
    }
    _activeRequests[packet.id] = false

    return Promise.new(function(resolve, reject, onCancel) : (boolean, any) -> ()
        local success: boolean, result: string = pcall(function()
            MessagingService:PublishAsync(serverId, HttpService:JSONEncode(packet))
        end)
        if not success then
            return reject(result)
        end
        local timeLimit: number = 5
        local timeElapsed: number = 0

        onCancel(function()
            _activeRequests[packet.id] = nil
            timeElapsed = timeLimit + 1
            reject("Request cancelled")
        end)

        while not _activeRequests[packet.id] and timeElapsed < timeLimit do
            timeElapsed += runService.Heartbeat:Wait()
        end
        local responsePacket: Packet = _activeRequests[packet.id]

        if responsePacket then
            _activeRequests[packet.id] = nil
            return resolve(responsePacket)
        end
        _activeRequests[packet.id] = nil
        return reject("Request timed out")
    end)
end

function network:ListenAsync(callback: (packet: Packet) -> ())
    return _listener:Connect(function(packet: Packet)
        return callback(packet.content)
    end)
end

-- Events
MessagingService:SubscribeAsync(game.JobId, function(message: JSON)
    local success: boolean, packet: Packet | string = pcall(function()
        return HttpService:JSONDecode(message)
    end)
    if success and _activeRequests[message.id] == false then
        _activeRequests[message.id] = packet
        _listener:Fire(packet)
    end
end)

-- Types
export type JSON = Types.JSON
export type PacketId = Types.PacketId
export type Packet = Types.Packet

return network