-- Services
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local runService = game:GetService("RunService")

-- Modules
local Promise = require(script.Promise)
local Signal = require(script.Signal)
local Types = require(script.Types)

-- Variables
local network = {}
local _activeRequests: { [string]: any } = {}
local _listener = Signal.new()

-- Functions
function network:SendAsync(serverId: string, content: any): Promise<Packet>
    local packet: Packet = {
        serverId = game.JobId,
        content = content,
        isResponse = false,
        id = HttpService:GenerateGUID(false),
        epochTime = tick()
    }
    _activeRequests[packet.id] = false

    return self:_sendAsync(serverId, packet)
end

function network:_sendAsync(serverId: string, packet: Packet): Promise<Packet>
    return Promise.new(function(resolve, reject, onCancel) : (boolean, any) -> ()
        if not packet.content then
            return reject("Content is required")
        end
        local success: boolean, result: string = pcall(function()
            MessagingService:PublishAsync(`net {serverId}`, HttpService:JSONEncode(packet))
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

        while _activeRequests[packet.id] == false and timeElapsed < timeLimit do
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
        local responsePacket: Packet = {
            serverId = game.JobId,
            id = packet.id,
            epochTime = tick(),
            isResponse = true,
            content = callback(packet)
        }
        return pcall(function()
            MessagingService:PublishAsync(`net {packet.serverId}`, HttpService:JSONEncode(responsePacket))
        end)
    end)
end

-- Events
MessagingService:SubscribeAsync(`net {game.JobId}`, function(message: any)
    local success: boolean, packet: Packet | string = pcall(function()
        return HttpService:JSONDecode(message.Data)
    end)
    if not success then return warn(packet) end

    -- Response from another server
    if _activeRequests[packet.id] == false and packet.isResponse then
        _activeRequests[packet.id] = packet
        return
    end
    
    -- Request from another server
    _listener:Fire(packet)
end)

-- Types
export type JSON = Types.JSON
export type PacketId = Types.PacketId
export type Packet = Types.Packet

return network