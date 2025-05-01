local QBCore = exports['qb-core']:GetCoreObject()

local spawnedPlantObjects = {}

local function OpenPlantStatusUI(plant)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "showPlantStatus",
        data = {
            label    = plant.label,
            health   = plant.health,
            food     = plant.food,
            water    = plant.water,
            progress = plant.progress,
            stage    = plant.stage,
        }
    })
end

RegisterNUICallback("closePlantStatus", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

local function CreateWeedPlant(plant)
    if not plant or not plant.coords or not plant.id then 
        return nil 
    end

    local plantCoords = (type(plant.coords) == "string") and json.decode(plant.coords) or plant.coords
    local plantModel = GetHashKey(plant.model)

    RequestModel(plantModel)
    while not HasModelLoaded(plantModel) do
        Wait(10)
    end

    local plantObject = CreateObject(plantModel, plantCoords.x, plantCoords.y, plantCoords.z, false, false, false)
    PlaceObjectOnGroundProperly(plantObject)
    FreezeEntityPosition(plantObject, true)

    exports['qb-target']:AddTargetEntity(plantObject, {
        options = {
            {
                label = "Check Plant Status",
                action = function()
                    if plant and plant.id then
                        TriggerServerEvent('weed:server:getPlantStatus', plant.id)
                    else
                        QBCore.Functions.Notify('Unable to retrieve plant data. Invalid plant.', 'error')
                    end
                end,
            },
            {
                label = "Harvest Plant",
                action = function()
                    if plant and plant.id then
                        TriggerServerEvent('weed:server:harvestPlant', plant.id)
                    else
                        QBCore.Functions.Notify('Unable to retrieve plant data. Invalid plant.', 'error')
                    end
                end,
            },
            {
                label = "Feed Plant",
                action = function()
                    if plant and plant.id then
                        if plant.food and plant.food >= 100 then
                            QBCore.Functions.Notify('The plant does not need fertilizer.', 'error')
                        else
                            QBCore.Functions.Progressbar("feed_plant", "Feeding Plant...", 5000, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                                animDict = "amb@world_human_gardener@male@idle_a",
                                anim = "idle_a",
                                flags = 49,
                            }, {}, {}, {}, function()
                                TriggerServerEvent('weed:server:feedPlant', plant.id)
                            end, function()
                                QBCore.Functions.Notify("Cancelled feeding.", "error")
                            end)
                        end
                    else
                        QBCore.Functions.Notify('Unable to retrieve plant data. Invalid plant.', 'error')
                    end
                end,
            },
            {
                label = "Water Plant",
                action = function()
                    if plant and plant.id then
                        if plant.water and plant.water >= 100 then
                            QBCore.Functions.Notify('The plant does not need more water.', 'error')
                        else
                            QBCore.Functions.Progressbar("water_plant", "Watering Plant...", 5000, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                                animDict = "amb@world_human_drinking@coffee@male@idle_a",
                                anim = "idle_b",
                                flags = 49,
                            }, {}, {}, {}, function()
                                TriggerServerEvent('weed:server:waterPlant', plant.id)
                            end, function()
                                QBCore.Functions.Notify("Cancelled watering.", "error")
                            end)
                        end
                    else
                        QBCore.Functions.Notify('Unable to retrieve plant data. Invalid plant.', 'error')
                    end
                end,
            },
        },
        distance = 2.5,
    })

    return plantObject
end

local function spawnOutdoorPlants(plants)
    for _, obj in pairs(spawnedPlantObjects) do
        if DoesEntityExist(obj) then
            DeleteObject(obj)
        end
    end
    spawnedPlantObjects = {}

    for _, plant in pairs(plants) do
        local plantObject = CreateWeedPlant(plant)
        if plantObject then
            spawnedPlantObjects[plant.id] = plantObject
        end
    end
end

RegisterNetEvent('weed:client:syncPlants', function(plants)
    spawnOutdoorPlants(plants)
end)

RegisterNetEvent('weed:client:updatePlantStage', function(updatedPlant)
    local oldObj = spawnedPlantObjects[updatedPlant.id]
    if oldObj and DoesEntityExist(oldObj) then
        SetEntityAsMissionEntity(oldObj, true, true)
        DeleteObject(oldObj)
        spawnedPlantObjects[updatedPlant.id] = nil
    end

    local newObj = CreateWeedPlant(updatedPlant)
    if newObj then
        spawnedPlantObjects[updatedPlant.id] = newObj
    end
end)

RegisterNetEvent('weed:client:updatePlantStatus', function(updatedPlant)
    if updatedPlant then
        OpenPlantStatusUI(updatedPlant)
    else
        QBCore.Functions.Notify('Unable to retrieve plant data.', 'error')
    end
end)

RegisterNetEvent('weed:client:useSeed', function(seedType)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return
    end

    local coords = GetEntityCoords(ped)
    TaskStartScenarioInPlace(ped, "world_human_gardener_plant", 0, true)

    QBCore.Functions.Progressbar('plant_weed', 'Planting Seed...', 5000, false, true, {}, {}, {}, {}, function()
        ClearPedTasksImmediately(ped)
        TriggerServerEvent('weed:server:plantSeed', coords, seedType)
    end, function()
        ClearPedTasksImmediately(ped)
    end)
end)

CreateThread(function()
    print("[DEBUG] Resource started. Syncing weed plants.")
    TriggerServerEvent('weed:server:syncPlants')
end)

local weedProp = nil
CreateThread(function()
    while true do
        Wait(2000)
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.items then
            local hasWeedLeaf = false
            local weedLeafItems = {
                "weed_ak47_leaf",
                "weed_amnesia_leaf",
                "weed_purple_haze_leaf",
                "weed_og_kush_leaf",
                "weed_white_widow_leaf",
                "weed_skunk_leaf"
            }
            for _, item in ipairs(playerData.items) do
                for _, leaf in ipairs(weedLeafItems) do
                    if item.name == leaf and item.amount > 0 then
                        hasWeedLeaf = true
                        break
                    end
                end
                if hasWeedLeaf then break end
            end

            local ped = PlayerPedId()
            if hasWeedLeaf and weedProp == nil then
                local model = GetHashKey("bkr_prop_weed_drying_02a")
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(10)
                end
                local propCoords = GetEntityCoords(ped)
                weedProp = CreateObject(model, propCoords.x, propCoords.y, propCoords.z, true, true, false)
                SetModelAsNoLongerNeeded(model)

                local boneIndex = GetPedBoneIndex(ped, 24816)
                AttachEntityToEntity(
                    weedProp,
                    ped,
                    boneIndex,
                    0.0,
                    -0.20,
                    0.0,
                    0.0,
                    100.0,
                    2.0,
                    false,
                    false,
                    false,
                    false,
                    2,
                    true
                )
            elseif not hasWeedLeaf and weedProp ~= nil then
                DeleteObject(weedProp)
                weedProp = nil
            end
        end
    end
end)

RegisterNetEvent('weed:client:addNewPlant', function(plant)
    if not plant or not plant.coords or not plant.id then return end
    local createdObj = CreateWeedPlant(plant)
    if createdObj then
        spawnedPlantObjects[plant.id] = createdObj
    end
end)

RegisterNetEvent('weed:client:removePlant', function(plantId)
    local oldObj = spawnedPlantObjects[plantId]
    if oldObj and DoesEntityExist(oldObj) then
        DeleteObject(oldObj)
    end
    spawnedPlantObjects[plantId] = nil
end)
