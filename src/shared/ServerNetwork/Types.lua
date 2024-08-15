local types = {}

export type JSON = string
export type PacketId = string
export type Packet = {
    serverId: string,
    content: any,
    id: PacketId,

    isResponse: boolean,
    epochTime: number,
}

return types