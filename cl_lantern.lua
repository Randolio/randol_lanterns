local lanterns = {}
local storedPoints = {}

local function spawnLantern(index, data)
    lib.requestModel(data.model, 15000)
    lanterns[index] = CreateObject(data.model, data.coords.x, data.coords.y, data.coords.z, false, false, false)
    SetEntityRotation(lanterns[index], data.rot.x, data.rot.y, data.rot.z, 2, true)
    SetEntityAsMissionEntity(lanterns[index], true, true)
    FreezeEntityPosition(lanterns[index], true)
    SetModelAsNoLongerNeeded(data.model)
    exports.ox_target:addLocalEntity(lanterns[index], {
        {
            icon = 'fa-solid fa-circle',
            label = 'Grab',
            onSelect = function()
                local success, count = lib.callback.await('randol_lantern:server:grabLantern', false, index)
                if not success then return end
                while not RequestScriptAudioBank('DLC_TUNER/DLC_Tuner_Collectibles', false, -1) do Wait(0) end
                lib.playAnim(cache.ped, 'anim@scripted@player@freemode@tun_prep_ig1_grab_low@male@', 'grab_low', 8.0, -8.0, 1500, 01, 0.0, false, false, false)
                PlaySoundFrontend(-1, 'Audio_Player_Shard_Final', 'Tuner_Collectables_General_Sounds', false)
                ReleaseNamedScriptAudioBank('DLC_TUNER/DLC_Tuner_Collectibles')
                lib.notify({
                    title = "Collected Jack O'Lantern",
                    description = ("You collected a Jack O'Lantern, %s remaining!"):format(count),
                    showDuration = true, duration = 5000, position = 'top', 
                    style = { width = 'fit-content', height = 'fit-content' }, 
                    icon = 'ghost', iconColor = '#ffffff' 
                })
            end,
            distance = 1.5,
        },
    })
end

local function removeLantern(index)
    if DoesEntityExist(lanterns[index]) then
        exports.ox_target:removeLocalEntity(lanterns[index], 'Grab')
        DeleteEntity(lanterns[index])
    end
    lanterns[index] = nil
end

local function deleteAllLanterns()
    if next(lanterns) then
        for _, lantern in pairs(lanterns) do
            if DoesEntityExist(lantern) then 
                DeleteEntity(lantern) 
            end
        end
        table.wipe(lanterns)
    end
    if next(storedPoints) then
        for _, point in pairs(storedPoints) do
            if point then point:remove() end
        end
        table.wipe(storedPoints)
    end
end

function OnPlayerUnload()
    deleteAllLanterns()
end

RegisterNetEvent('randol_lantern:client:sendLanterns', function(data)
    if GetInvokingResource() or not next(data) or not hasPlyLoaded() then return end
    for index, lantern in pairs(data) do
        storedPoints[index] = lib.points.new({
            coords = lantern.coords,
            distance = 75,
            onEnter = function()
                spawnLantern(index, lantern)
            end,
            onExit = function()
                removeLantern(index)
            end,
        })
    end
end)

RegisterNetEvent('randol_lantern:client:lanternFound', function(index)
    if GetInvokingResource() or not index or not hasPlyLoaded() then return end
    removeLantern(index)
    if storedPoints[index] then storedPoints[index]:remove() storedPoints[index] = nil end
end)

AddEventHandler('onResourceStop', function(resourceName) 
    if GetCurrentResourceName() == resourceName then
        deleteAllLanterns()
    end 
end)
