local serverNetwork = require(game.ReplicatedStorage.Shared.ServerNetwork)

serverNetwork:ListenAsync(function(packet)
    print(packet.content)
    if packet.content == "ping" then
        return "pong"
    end
end)

while task.wait(5) do
    local tim = tick()
    print("Sent ping")
    local success: boolean, packet: serverNetwork.Packet = serverNetwork:SendAsync(game.JobId, "ping"):await()
    if success then
        print("Received pong", packet.epochTime - tim)
    end
end