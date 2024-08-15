local serverNetwork = require(game.ReplicatedStorage.Shared.ServerNetwork)

serverNetwork:ListenAsync(function(packet: serverNetwork.Packet)
    if packet.content == "ping" then
       return "pong"
    end
    return true
end)

while task.wait(5) do
    print("Sent")

    local tim: number = tick()
    local success: boolean, packet: serverNetwork.Packet = serverNetwork:SendAsync(game.JobId, "ping"):await()
    if success then
        print("Received", packet.content, packet.epochTime - tim)
    end
end