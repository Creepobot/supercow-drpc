local discordRPC = require("discordRPC")
local appId = "836990034048843776"

discordRPC.presence = {
    state = "Test2",
    details = "Test1",
    largeImageKey = "cow",
    largeImageText = "Supercow by Nevosoft",
    smallImageKey = "online",
    smallImageText = "Test3",
    startTimestamp = os.time(os.date("*t") --[[@as osdate]]),
}

function AreEqual(table1, table2)
	for k, v in pairs(table1) do
		if table2[k] ~= v then
			return false end
	end
	return true
end

function discordRPC.Update(presence)
    for k, v in pairs(discordRPC.presence) do
        if presence[k] == nil then presence[k] = v end
    end
    if not AreEqual(discordRPC.presence, presence) then
        discordRPC.presence = presence
        discordRPC.updatePresence(discordRPC.presence)
    end
    discordRPC.runCallbacks()
end

function discordRPC.ready(userId, username, discriminator, avatar)
    print(string.format("Discord: ready (%s, %s, %s, %s)", userId, username, discriminator, avatar))
end

function discordRPC.disconnected(errorCode, message)
    print(string.format("Discord: disconnected (%d: %s)", errorCode, message))
end

function discordRPC.errored(errorCode, message)
    print(string.format("Discord: error (%d: %s)", errorCode, message))
end

function discordRPC.joinGame(joinSecret)
    print(string.format("Discord: join (%s)", joinSecret))
end

function discordRPC.spectateGame(spectateSecret)
    print(string.format("Discord: spectate (%s)", spectateSecret))
end

function discordRPC.joinRequest(userId, username, discriminator, avatar)
    print(string.format("Discord: join request (%s, %s, %s, %s)", userId, username, discriminator, avatar))
    discordRPC.respond(userId, "yes")
end

discordRPC.initialize(appId, true)

return discordRPC