local types = {}

export type EpochTime = number

export type UnmatchedPlayer = {
    UserId: number,
    PlayerName: string,
    Rank: number
}

export type MatchedPlayer = {
    UserId: number,
    PlayerName: string,
    Rank: number,
    ReserveServerId: string,
}

export type QueueObject = {
    Players: {[number]: UnmatchedPlayer},
    ServerJobId: string,
    Added: EpochTime
}

return types