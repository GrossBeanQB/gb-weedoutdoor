local QBCore = exports['qb-core']:GetCoreObject()

local tableCoords = vector3(-36.9, -2689.80, 6.0)
local propHash = `bkr_prop_weed_table_01a`
local spawnedTable = nil
local attachedProp = nil
local handProp = nil

function RemoveAttachedProp()
    if attachedProp and DoesEntityExist(attachedProp) then
        DeleteObject(attachedProp)
        attachedProp = nil
    end
end

function AttachPropToHand(propModel)
    local playerPed = PlayerPedId()
    local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.12, 0.02, -0.02, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    handProp = prop
end

function RemoveHandProp()
    if handProp and DoesEntityExist(handProp) then
        DeleteObject(handProp)
        handProp = nil
    end
end

function SpawnWeedTable()
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do
        Wait(100)
    end

    if DoesEntityExist(spawnedTable) then
        DeleteEntity(spawnedTable)
    end

    spawnedTable = CreateObject(propHash, tableCoords.x, tableCoords.y, tableCoords.z - 1.0, true, false, false)
    FreezeEntityPosition(spawnedTable, true)
    SetEntityInvincible(spawnedTable, true)

    exports['qb-target']:AddTargetEntity(spawnedTable, {
        options = {
            {
                label = "💨 Process Weed Leafs",
                icon = "fas fa-cannabis",
                action = function()
                    OpenProcessingMenu()
                end
            },
            {
                label = "📦 Pack Weed",
                icon = "fas fa-box",
                action = function()
                    OpenPackingMenu()
                end
            },
        },
        distance = 2.0
    })
end

CreateThread(function()
    Wait(500)
    SpawnWeedTable()
end)

function StartProcessing(time, label, animation, event, data, propModel)
    local playerPed = PlayerPedId()

    RemoveAttachedProp()

    if propModel then
        AttachPropToHand(propModel)
    end

    FreezeEntityPosition(playerPed, true)
    TaskStartScenarioInPlace(playerPed, animation, 0, true)

    QBCore.Functions.Progressbar("processing_weed", label, time, false, true, {
        disableMovement    = true,
        disableCarMovement = true,
        disableMouse       = false,
        disableCombat      = true,
    }, {}, {}, {}, function()
        ClearPedTasks(playerPed)
        FreezeEntityPosition(playerPed, false)
        RemoveHandProp()
        TriggerServerEvent(event, data)
    end, function()
        ClearPedTasks(playerPed)
        FreezeEntityPosition(playerPed, false)
        RemoveHandProp()
    end)
end

local leafToBud = {
    ["weed_ak47_leaf"]         = "ak47",
    ["weed_amnesia_leaf"]      = "amnesia",
    ["weed_purple_haze_leaf"]  = "purplehaze",
    ["weed_og_kush_leaf"]      = "ogkush",
    ["weed_skunk_leaf"]        = "skunk",
    ["weed_white_widow_leaf"]  = "white_widow"
}

function OpenProcessingMenu()
    local processingMenu = {
        { header = "🌱 Process Weed Leafs", isMenuHeader = true }
    }

    for leaf, identifier in pairs(leafToBud) do
        local displayName = identifier:upper()
        table.insert(processingMenu, {
            header = "🌿 Process " .. displayName,
            txt = "🛠️ Requires: 1 " .. displayName .. " Leaf → Produces: 1 " .. displayName .. " Bud",
            params = {
                event = "weedprocessing:processLeaf",
                args = { leaf = leaf, bud = "weed_" .. identifier .. "_bud" }
            }
        })
    end

    exports['qb-menu']:openMenu(processingMenu)
end

function OpenPackingMenu()
    local packingMenu = {
        { header = "📦 Pack Weed", isMenuHeader = true }
    }

    local budToWeed = {
        ["weed_ak47_bud"]         = "ak47",
        ["weed_amnesia_bud"]      = "amnesia",
        ["weed_purple_haze_bud"]  = "purplehaze",
        ["weed_og_kush_bud"]      = "ogkush",
        ["weed_skunk_bud"]        = "skunk",
        ["weed_white_widow_bud"]  = "white_widow"
    }

    for bud, identifier in pairs(budToWeed) do
        local displayName = identifier:upper()
        table.insert(packingMenu, {
            header = "📦 Pack " .. displayName,
            txt = "🛠️ Requires: 1 " .. displayName .. " Bud & 1 Empty Bag",
            params = {
                event = "weedprocessing:packWeed",
                args = { bud = bud, packed = "weed_" .. identifier }
            }
        })
    end

    exports['qb-menu']:openMenu(packingMenu)
end

RegisterNetEvent("weedprocessing:processLeaf", function(data)
    QBCore.Functions.TriggerCallback('weedprocessing:server:checkLeaf', function(hasItem)
        if hasItem then
            StartProcessing(12000, "Processing Weed...", "PROP_HUMAN_PARKING_METER", "weedprocessing:server:processLeaf", data, "bkr_prop_weed_bud_01a")
        end
    end, data.leaf)
end)

RegisterNetEvent("weedprocessing:packWeed", function(data)
    QBCore.Functions.TriggerCallback('weedprocessing:server:checkPack', function(hasItems)
        if hasItems then
            StartProcessing(8000, "Packing Weed...", "PROP_HUMAN_PARKING_METER", "weedprocessing:server:packWeed", data, "sf_prop_sf_bag_weed_01b")
        end
    end, data.bud)
end)
