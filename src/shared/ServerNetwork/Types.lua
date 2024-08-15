local types = {}

export type JSON = string
export type PacketId = string
export type Packet = {
    serverId: string,
    method: string,
    content: any,
    id: PacketId,
}

return types