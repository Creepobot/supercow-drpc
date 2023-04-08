local memory = require("memory")
local stageLevelPattern = memory.at("A3 ? ? ? ? E8 ? ? ? ? A3 ? ? ? ? 83 3D")
local gameScenePattern = memory.at("81 3D ? ? ? ? ? ? ? ? 0F 95 C0")

local Addresses = {
    currentScene = gameScenePattern:add(2):readOffset(),
    gameScene = gameScenePattern:add(6):readInt(),
    editorScene = memory.at("68 ? ? ? ? 8B 4D ? E8 ? ? ? ? 8B 4D ? 8B 55"):add(1):readInt(),

    stage = stageLevelPattern:add(1):readOffset(),
    level = stageLevelPattern:add(11):readOffset(),
    pause = memory.at("0F B6 05 ? ? ? ? 85 C0 74 ? 81 3D"):add(3):readOffset(),
    editor = memory.at("0F B6 15 ? ? ? ? 85 D2 75 ? C7 05"):add(3):readOffset(),
    loaded = memory.at("0F B6 15 ? ? ? ? 85 D2 74 ? C7 45 ? ? ? ? ? A1"):add(3):readOffset(),
    currentName = memory.at("8B 15 ? ? ? ? 83 7A ? ? 7D"):add(2),

    coinsTotal = memory.at("3B 15 ? ? ? ? 7C ? 6A"):add(2):readOffset(),
    coinsCollected = memory.at("83 3D ? ? ? ? ? 7C ? 8B 15 ? ? ? ? 3B 15"):add(2):readOffset(),
    gemsTotal = memory.at("3B 05 ? ? ? ? 7C ? 6A"):add(2):readOffset(),
    gemsCollected = memory.at("83 3D ? ? ? ? ? 7C ? A1 ? ? ? ? 3B 05"):add(2):readOffset(),
    monstersTotal = memory.at("3B 0D ? ? ? ? 7C ? 6A"):add(2):readOffset(),
    monstersKilled = memory.at("83 3D ? ? ? ? ? 7C ? 8B 0D"):add(2):readOffset(),
    secretsTotal = memory.at("3B 0D ? ? ? ? 7E ? 8B 15 ? ? ? ? 89 15 ? ? ? ? A1 ? ? ? ? 03 05"):add(2):readOffset(),
    secretsFound = memory.at("83 3D ? ? ? ? ? 7C ? 6A"):add(2):readOffset()
}

local langbool
langbool, Addresses.language = pcall(function() return memory.at("68 ? ? ? ? 68 ? ? ? ? 8D 8D ? ? ? ? 51 E8 ? ? ? ? 83 C4 ? 8D 95"):add(1) end)
if not langbool then
    Addresses.language = nil
    log.warn("Ошибка выше возникла в модуле DRPC. Не обращайте внимания, на работу супермода, самого DRPC или других модулей это не влияет.")
end

Addresses.calculateStats = function()
    local coinsTotal, coinsCollected, gemsTotal,
    gemsCollected, monstersTotal, monstersKilled,
    secretsTotal, secretsFound, points =
    Addresses.coinsTotal:readInt(),
    Addresses.coinsCollected:readInt(),
    Addresses.gemsTotal:readInt(),
    Addresses.gemsCollected:readInt(),
    Addresses.monstersTotal:readInt(),
    Addresses.monstersKilled:readInt(),
    Addresses.secretsTotal:readInt(),
    Addresses.secretsFound:readInt(), 0

    if coinsCollected > coinsTotal then
        coinsTotal = coinsCollected end
    if gemsCollected > gemsTotal then
        gemsTotal = gemsCollected end
    if monstersKilled > monstersTotal then
        monstersTotal = monstersKilled end
    if secretsFound > secretsTotal then
        secretsTotal = secretsFound end

    points = secretsTotal + monstersTotal + gemsTotal + coinsTotal
    if points <= 0 then return 0
    else return math.floor((secretsFound + monstersKilled
        + gemsCollected + coinsCollected) * 100 / points)
    end
end

return Addresses