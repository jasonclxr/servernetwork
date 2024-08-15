local serverNetwork = require(game.ReplicatedStorage.Shared.ServerNetwork)

serverNetwork:ListenAsync(function(packet: serverNetwork.Packet)
    if packet.content == "ping" then
       return "pong"
    end
    return false
end)

while task.wait(1) do
    print("Sent")

    local tim: number = tick()
    local success: boolean, packet: serverNetwork.Packet = serverNetwork:SendAsync(game.JobId, "ping"):await()
    if success then
        print("Received", packet.content, packet.epochTime - tim)
    end
end