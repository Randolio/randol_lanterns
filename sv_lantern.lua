local Server = lib.load('sv_config')
local chosenLanterns = {}
local LantenCount = Server.NumberOfLanterns

local function genLanterns()
    local stored = {}
    local total = #Server.Lanterns
    local count = math.min(Server.NumberOfLanterns, total)

    for i = 1, count do
        local rnd
        repeat rnd = math.random(total) until not stored[rnd]
        stored[rnd] = true
        chosenLanterns[rnd] = Server.Lanterns[rnd]
    end

    if Server.Debug then
        print(json.encode(chosenLanterns, {indent = true}))
    end
end

function PlayerHasLoaded(src)
    SetTimeout(3000, function()
        if next(chosenLanterns) then
            TriggerClientEvent('randol_lantern:client:sendLanterns', src, chosenLanterns)
        end
    end)
end

lib.callback.register('randol_lantern:server:grabLantern', function(source, index)
    if LantenCount == 0 then return false end

    local player = GetPlayer(source)
    if not player or not index or not chosenLanterns[index] then return false end

    local pos = GetEntityCoords(GetPlayerPed(source))
    local coords = chosenLanterns[index].coords

    if #(pos - coords) > 3 then return false end

    chosenLanterns[index] = nil
    LantenCount -= 1

    local amt = math.random(Server.Reward.min, Server.Reward.max)
    AddMoney(player, 'cash', amt)

    TriggerClientEvent('randol_lantern:client:lanternFound', -1, index)
    return true, LantenCount
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    genLanterns()
    SetTimeout(3000, function()
        if next(chosenLanterns) then
            TriggerClientEvent('randol_lantern:client:sendLanterns', -1, chosenLanterns)
        end
    end)
end)