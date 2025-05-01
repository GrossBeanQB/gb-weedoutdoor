local QBCore = exports['qb-core']:GetCoreObject()

local seedTypes = {
    "ogkush",
    "amnesia",
    "ak47",
    "purplehaze",
    "skunk",
    "whitewidow"
}

for _, seed in ipairs(seedTypes) do
    QBCore.Functions.CreateUseableItem("weed_" .. seed .. "_seed", function(source, item)
        TriggerClientEvent('weed:client:useSeed', source, seed)
    end)
end

local function getPlantById(plantId)
    local result = MySQL.query.await('SELECT * FROM weed_plants WHERE id = ?', { plantId })
    return (result and result[1]) or nil
end

RegisterNetEvent('weed:server:plantSeed', function(coords, weedType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not QBWeed.Plants[weedType] then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid seed type: ' .. tostring(weedType), 'error')
        return
    end

    if Player.Functions.RemoveItem('weed_' .. weedType .. '_seed', 1) then
        local plantCfg = QBWeed.Plants[weedType]
        local newPlant = {
            coords   = coords,
            model    = plantCfg.stages[1],
            label    = plantCfg.label,
            stage    = 1,
            health   = 100,
            food     = 100,
            water    = 100,
            progress = 0,
            sort     = weedType,
        }

        MySQL.insert(
            'INSERT INTO weed_plants (coords, model, label, stage, health, food, water, progress, sort) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            {
                json.encode(newPlant.coords),
                newPlant.model,
                newPlant.label,
                newPlant.stage,
                newPlant.health,
                newPlant.food,
                newPlant.water,
                newPlant.progress,
                newPlant.sort
            },
            function(insertId)
                print("✅ Inserted weed plant with ID:", insertId)
                TriggerClientEvent('weed:client:addNewPlant', -1, {
                    id       = insertId,
                    coords   = newPlant.coords,
                    model    = newPlant.model,
                    label    = newPlant.label,
                    stage    = newPlant.stage,
                    health   = newPlant.health,
                    food     = newPlant.food,
                    water    = newPlant.water,
                    progress = newPlant.progress,
                    sort     = newPlant.sort,
                })
                TriggerClientEvent('QBCore:Notify', src, 'Seed planted successfully!', 'success')
            end
        )
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have the required seeds.', 'error')
    end
end)

local function updatePlantResource(src, plantId, resource, requiredItem, amount, verb)
    local Player = QBCore.Functions.GetPlayer(src)
    local plant  = getPlantById(plantId)
    if not plant then
        TriggerClientEvent('QBCore:Notify', src, 'This plant no longer exists.', 'error')
        return
    end

    if plant[resource] >= 100 then
        TriggerClientEvent('QBCore:Notify', src, 'The plant does not need ' .. verb .. '.', 'error')
        return
    end

    if Player.Functions.GetItemByName(requiredItem) then
        if Player.Functions.RemoveItem(requiredItem, 1) then
            local newValue = math.min(100, plant[resource] + amount)
            MySQL.update('UPDATE weed_plants SET ' .. resource .. ' = ? WHERE id = ?', { newValue, plantId })
            TriggerClientEvent('QBCore:Notify', src, ('You %s the plant. %s: %d%%'):format(verb, resource:sub(1,1):upper() .. resource:sub(2), newValue), 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to remove item.', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You need ' .. requiredItem:gsub("_", " ") .. '!', 'error')
    end
end

RegisterNetEvent('weed:server:feedPlant', function(plantId)
    updatePlantResource(source, plantId, "food",  "weed_nutrition", 20, "fed")
end)

RegisterNetEvent('weed:server:waterPlant', function(plantId)
    updatePlantResource(source, plantId, "water", "water_bottle", 20, "watered")
end)

RegisterNetEvent('weed:server:harvestPlant', function(plantId)
    local src    = source
    local Player = QBCore.Functions.GetPlayer(src)
    local plant  = getPlantById(plantId)
    if not plant then
        TriggerClientEvent('QBCore:Notify', src, 'This plant no longer exists.', 'error')
        return
    end

    local plantCfg = QBWeed.Plants[plant.sort]
    if not plantCfg then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid plant data.', 'error')
        return
    end

    if plant.stage < plantCfg.highestStage then
        TriggerClientEvent('QBCore:Notify', src, 'This plant is not ready for harvest yet.', 'error')
        return
    end

    local leafMap = {
        ogkush     = 'weed_ogkush_leaf',
        amnesia    = 'weed_amnesia_leaf',
        ak47       = 'weed_ak47_leaf',
        purplehaze = 'weed_purple_haze_leaf',
        skunk      = 'weed_skunk_leaf',
        whitewidow = 'weed_white_widow_leaf'
    }
    local leafItem = leafMap[plant.sort] or 'weed_leaf'
    local amount = math.random(2, 5)
    Player.Functions.AddItem(leafItem, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[leafItem], 'add')

    MySQL.execute('DELETE FROM weed_plants WHERE id = ?', { plantId })
    local allPlants = MySQL.query.await('SELECT * FROM weed_plants')
    TriggerClientEvent('weed:client:syncPlants', -1, allPlants)

    local label = QBCore.Shared.Items[leafItem] and QBCore.Shared.Items[leafItem].label or leafItem
    TriggerClientEvent('QBCore:Notify', src, 'You harvested the plant and received ' .. amount .. 'x ' .. label .. '!', 'success')
end)

RegisterNetEvent('weed:server:getPlantStatus', function(plantId)
    local src = source
    local plant = getPlantById(plantId)
    if plant then
        TriggerClientEvent('weed:client:updatePlantStatus', src, plant)
    else
        TriggerClientEvent('weed:client:updatePlantStatus', src, nil)
    end
end)

CreateThread(function()
    while true do
        local plants = MySQL.query.await('SELECT * FROM weed_plants')
        for _, plant in pairs(plants) do
            local plantCfg = QBWeed.Plants[plant.sort]
            if plantCfg then
                local health = plant.health or 0
                if health > 50 then
                    local progressGain = math.random(QBWeed.Progress.min, QBWeed.Progress.max)
                    plant.progress = plant.progress + progressGain

                    if plant.progress >= 100 and plant.stage < plantCfg.highestStage then
                        plant.stage = plant.stage + 1
                        plant.progress = 0
                        plant.model = plantCfg.stages[plant.stage]
                    end
                end

                local newFood  = math.max(0, plant.food  - QBWeed.FoodUsage)
                local newWater = math.max(0, plant.water - QBWeed.WaterUsage)

                if newFood <= 0 and newWater <= 0 then
                    health = math.max(0, health - math.random(5, 10))
                elseif newFood > 0 and newWater > 0 and health < 100 then
                    health = math.min(100, health + math.random(3, 7))
                end

                if health <= 0 then
                    MySQL.execute('DELETE FROM weed_plants WHERE id = ?', { plant.id })
                    TriggerClientEvent('weed:client:removePlant', -1, plant.id)
                else
                    MySQL.update(
                        'UPDATE weed_plants SET stage=?, progress=?, model=?, food=?, water=?, health=? WHERE id=?',
                        { plant.stage, plant.progress, plant.model, newFood, newWater, health, plant.id }
                    )
                end
            end
        end

        local updatedPlants = MySQL.query.await('SELECT * FROM weed_plants')
        TriggerClientEvent('weed:client:syncPlants', -1, updatedPlants)
        Wait(QBWeed.GrowthTick * 60 * 1000)
    end
end)

function FormatItemName(item)
    local formatted = item:gsub("weed_", ""):gsub("_", " ")
    formatted = formatted:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    return formatted
end

QBCore.Functions.CreateCallback('weedprocessing:server:checkLeaf', function(source, cb, leaf)
    local Player = QBCore.Functions.GetPlayer(source)
    local hasLeaf = Player.Functions.GetItemByName(leaf) ~= nil
    local formattedLeaf = FormatItemName(leaf):gsub(" Leaf", "")
    if not hasLeaf then
        TriggerClientEvent('QBCore:Notify', source, "You are missing " .. formattedLeaf .. " Leaf!", "error")
    end
    cb(hasLeaf)
end)

RegisterNetEvent("weedprocessing:server:processLeaf", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem(data.leaf, 1) then
        Player.Functions.AddItem(data.bud, 1, false, {})
        local formattedLeaf = FormatItemName(data.leaf):gsub(" Leaf", "")
        TriggerClientEvent('QBCore:Notify', src, "Processed 1x " .. formattedLeaf .. " Leaf into 1x " .. FormatItemName(data.bud) .. " Bud!", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "You are missing " .. FormatItemName(data.leaf) .. " Leaf!", "error")
    end
end)

QBCore.Functions.CreateCallback('weedprocessing:server:checkPack', function(source, cb, bud)
    local Player = QBCore.Functions.GetPlayer(source)
    local hasBud = Player.Functions.GetItemByName(bud) ~= nil
    local hasBag = Player.Functions.GetItemByName("empty_weed_bag") ~= nil
    local formattedBud = FormatItemName(bud):gsub(" Bud", "")
    if not hasBud and not hasBag then
        TriggerClientEvent('QBCore:Notify', source, "You are missing " .. formattedBud .. " Bud & an Empty Bag!", "error")
    elseif not hasBud then
        TriggerClientEvent('QBCore:Notify', source, "You are missing " .. formattedBud .. " Bud!", "error")
    elseif not hasBag then
        TriggerClientEvent('QBCore:Notify', source, "You are missing Empty Bags!", "error")
    end
    cb(hasBud and hasBag)
end)

local BudToWeed = {
    ["weed_ak47_bud"]       = "weed_ak47",
    ["weed_amnesia_bud"]    = "weed_amnesia",
    ["weed_purple_haze_bud"] = "weed_purplehaze",
    ["weed_og_kush_bud"]     = "weed_ogkush",
    ["weed_skunk_bud"]       = "weed_skunk",
    ["weed_white_widow_bud"]  = "weed_whitewidow"
}

RegisterNetEvent("weedprocessing:server:packWeed", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local packedWeed = BudToWeed[data.bud]
    if not packedWeed then
        TriggerClientEvent('QBCore:Notify', src, "Invalid weed strain!", "error")
        return
    end
    if Player.Functions.GetItemByName(data.bud) and Player.Functions.GetItemByName("empty_weed_bag") then
        Player.Functions.RemoveItem(data.bud, 1)
        Player.Functions.RemoveItem("empty_weed_bag", 1)
        Player.Functions.AddItem(packedWeed, 1, false, {})
        local formattedBud = FormatItemName(data.bud):gsub(" Bud", "")
        TriggerClientEvent('QBCore:Notify', src, "Packed 1x " .. formattedBud .. " Bud into 1x " .. FormatItemName(packedWeed) .. "!", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "You don't have the required items!", "error")
    end
end)
