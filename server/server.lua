QBCore =  exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug
function dump(o)
   if type(o) == 'table' then
   local s = '{ '
   for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
   end
   return s .. '} '
   else
   return tostring(o)
   end
end

RegisterNetEvent('cw-crafting:server:craftItem', function(player, item, craftingAmount)
    print(craftingAmount)
    local src = source
    if Config.Inventory == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        for material, amount in pairs(item.materials) do
            Player.Functions.RemoveItem(material, amount*craftingAmount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.material], "remove")
        end
        Player.Functions.AddItem(item.name, item.amount*craftingAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "add")
    elseif Config.Inventory == 'ox' then
        local pped = GetPlayerPed(src)
        local coords = GetEntityCoords(pped)
        for material, amount in pairs(item.materials) do
            exports.ox_inventory:RemoveItem(src, material, amount*craftingAmount)
        end
        if exports.ox_inventory:CanCarryItem(src, item.name, item.amount*craftingAmount or 1) then
            exports.ox_inventory:AddItem(src, item.name, item.amount*craftingAmount or 1 )
        else
            exports.ox_inventory:CustomDrop("craft", {{item.name, item.amount*craftingAmount or 1, durability = 100}}, coords)
        end
    end
end)

local function updateBlueprints(citizenId, blueprints)
    return MySQL.Sync.execute('UPDATE players SET crafting_blueprints = ? WHERE citizenid = ?', {json.encode(blueprints), citizenId} )
end

local function fetchBlueprints(citizenId)
    local fetched = MySQL.Sync.fetchAll('SELECT crafting_blueprints FROM players WHERE citizenid = ?', {citizenId})[1].crafting_blueprints
    local decoded = json.decode(fetched)
    return decoded
end

local function removeBlueprint(citizenId, blueprint)
    local blueprints = fetchBlueprints(citizenId)
    if blueprints then
        for i, bp in pairs(blueprints) do
            if bp == blueprint then
                table.remove(blueprints, i)
                MySQL.Sync.execute('UPDATE players SET crafting_blueprints = ? WHERE citizenid = ?', {json.encode(blueprints), citizenId} )
                return true
            end
        end
    else
        return false
    end
end

local function addBlueprint(citizenId, blueprint)
    local blueprints = fetchBlueprints(citizenId)
    if blueprints ~= nil then
        if #blueprints > 0 then
            for i, bp in pairs(blueprints) do
                if bp == blueprint then
                    print('Character already has this blueprint')
                    return false
                end
            end
        end
        if Config.Debugcraft then
            print('add Blueprint success:', blueprint)
        end
        blueprints[#blueprints+1] = blueprint
        updateBlueprints(citizenId, blueprints)
        return true
    else
        return false
    end
end

local function handleAddBlueprintFromItem(source, item)
    local blueprint = nil
    print('item', dump(item))
    if Config.Inventory == 'qb' then
        blueprint = item.info.value
    else
        blueprint = item.metadata.value
    end
    print('adding', blueprint)
    local Player = QBCore.Functions.GetPlayer(source)
    local citizenId = Player.PlayerData.citizenid
    local success = addBlueprint(citizenId, blueprint)
    if success then
        local blueprints = Player.Functions.GetItemsByName('blueprint')
        if Config.Inventory == 'qb' then
            local slot = nil
            for _, bpItem in ipairs(blueprints) do
                if Config.Debugcraft then
                   print(bpItem.info.value)
                end
                if bpItem.info.value == blueprint then
                    slot = bpItem.slot
                end
            end
            if slot then
                Player.Functions.RemoveItem('blueprint', 1, slot)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['blueprint'], "remove")
                addBlueprint(citizenId, blueprint)
            end
        else
            local slot = nil
            for _, bpItem in ipairs(blueprints) do

                   print(bpItem.metadata.value)

                if bpItem.metadata.value == blueprint then
                    slot = bpItem.slot
                end
            end
            if slot then
                Player.Functions.RemoveItem('blueprint', 1, slot)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['blueprint'], "remove")
                addBlueprint(citizenId, blueprint)
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "You already know this recipe", "error")
    end
end

local function getQBItem(item)
    local qbItem = QBCore.Shared.Items[item]
    if qbItem then
        return qbItem
    else
        print('Someone forgot to add the item')
    end
end

local function giveBlueprintItem(source, blueprintValue)
    if Config.Inventory == 'qb' then
        local info = {}
    	local Player = QBCore.Functions.GetPlayer(source)
        info.value = blueprintValue
        Player.Functions.AddItem('blueprint', 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', source, getQBItem('blueprint'), "add")
    elseif Config.Inventory == 'ox' then
        print("called")
        local carry = exports.ox_inventory:CanCarryItem(source, 'blueprint', 1)
        if carry then
            exports.ox_inventory:AddItem(source, 'blueprint', 1, {value = blueprintValue})
        else
            print("FAILED")
            local pped = GetPlayerPed(source)
            local coords = GetEntityCoords(pped)
            exports.ox_inventory:CustomDrop("drop-"..math.random(1,9999), {{'blueprint', 1, {value = blueprintValue}}}, coords)
        end
    end
end
exports("giveBlueprintItem", giveBlueprintItem)


local function GenerateRandomIndex()
    local Array = {}
 
    for index, bp in pairs(Config.Blueprints) do
        local chance = math.random(0,100)
        local chanceToGetItem = bp.chance
        if chanceToGetItem == nil then
            chanceToGetItem = 100
        end
        print('chance to get', chance, chanceToGetItem)
        if chance <= chanceToGetItem then
            print('adding ', index)
            table.insert(Array, index)
        end
    end
 
    local RandomNumber = math.random(1, #Array)
 
    return Array[RandomNumber], Config.Blueprints[Array[RandomNumber]].rarity or 1
end

local function giveRandomBlueprint(source ,maxRarity, failChance)
    local foundItem = nil
    local chance = math.random(0,100)
    if failChance == nil then
        failChance = Config.DefaultFailChance
    end

    if maxRarity == nil then
        maxRarity = 5
    end
    print('fail chance:', failChance, 'roll', chance)
    if failChance <= chance then
        while foundItem == nil do
            local blueprint, rarity = GenerateRandomIndex()
            print('res', blueprint,rarity)
            if rarity <= maxRarity then
                foundItem = blueprint
            end
        end
        if foundItem ~= nil then
            print('giving '.. foundItem.. ' to ', source)
            giveBlueprintItem(source, foundItem)
        end
    else
        print('Roll Failed', failChance, chance)
    end
end
exports("giveRandomBlueprint", giveRandomBlueprint)
-- Use this to give blueprints from random loot
RegisterNetEvent('cw-crafting:server:giveBlueprint', function(value)
    giveBlueprintItem(source, value)
end)

RegisterNetEvent('cw-crafting:server:giveRandomBlueprint', function(source, maxRarity, failChance)
    print('srs', source)
    giveRandomBlueprint(source, maxRarity, failChance)
end)

RegisterNetEvent('cw-crafting:server:removeBlueprint', function(citizenId,blueprint)
    removeBlueprint(citizenId, blueprint)
end)

RegisterNetEvent('cw-crafting:server:addBlueprint', function(citizenId,blueprint)
    addBlueprint(citizenId, blueprint)
end)

QBCore.Functions.CreateCallback('cw-crafting:server:getBlueprints', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local citizenId = Player.PlayerData.citizenid
    cb(fetchBlueprints(citizenId))
 end)


QBCore.Functions.CreateUseableItem("blueprint", function(source, item)
    print('used blueprint')
    handleAddBlueprintFromItem(source, item)
end)

QBCore.Commands.Add('addblueprint', 'Give blueprint knowledge to player. (Admin Only)',{ { name = 'player id', help = 'the id of the player' }, { name = 'blueprint', help = 'name of blueprint' } }, true, function(source, args)
    print(args[1])
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local citizenId = Player.PlayerData.citizenid
    print('adding '..args[2].. ' to '..citizenId)
    addBlueprint(citizenId, args[2])
end, 'admin')

QBCore.Commands.Add('removeblueprint', 'Remove blueprint to player. (Admin Only)',{ { name = 'player id', help = 'the id of the player' }, { name = 'blueprint', help = 'name of blueprint' } }, true, function(source, args)
    print(args[1])
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local citizenId = Player.PlayerData.citizenid
    print('removing '..args[2].. ' to '..citizenId)
    removeBlueprint(citizenId, args[2])
end, 'admin')

QBCore.Commands.Add('giveblueprint', 'Give blueprint item to player. (Admin Only)',{ { name = 'player id', help = 'the id of the player' }, { name = 'blueprint', help = 'name of blueprint' } }, true, function(source, args)
    giveBlueprintItem(tonumber(args[1]), args[2])
end, 'admin')

QBCore.Commands.Add('cwdebugcrafting', 'toggle debug for crafting', {}, true, function(source, args)
    useDebug = not useDebug
    print('debug is now:', useDebug)
    TriggerClientEvent('cw-crafting:client:toggleDebug',source, useDebug)
end, 'admin')

QBCore.Commands.Add('testbp', 'test bps. (Admin Only)',{}, true, function(source)
    TriggerEvent('cw-crafting:server:giveRandomBlueprint',source)
    --TriggerEvent('cw-crafting:server:giveRandomBlueprint',source, 3, 50)
end, 'admin')