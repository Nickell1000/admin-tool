local QBCore = exports['qb-core']:GetCoreObject()
local OverrideFile = 'data/shop_overrides.json'
local oxInventoryRestarting = false
local getShopList
local setShopLocationByIndex
local removeShopLocationByIndex

local function queueOxInventoryReload(delayMs)
    if oxInventoryRestarting then
        return false
    end

    local currentState = GetResourceState('ox_inventory')
    if currentState ~= 'started' and currentState ~= 'starting' and currentState ~= 'stopped' then
        return false
    end

    oxInventoryRestarting = true

    CreateThread(function()
        Wait(delayMs or 0)

        local stateBeforeStop = GetResourceState('ox_inventory')
        if stateBeforeStop == 'started' or stateBeforeStop == 'starting' then
            StopResource('ox_inventory')
            Wait(1500)
        end

        StartResource('ox_inventory')
        Wait(8000)
        oxInventoryRestarting = false
    end)

    return true
end

local function ensureOxInventoryForShopNpcUpdate()
    return queueOxInventoryReload(4500)
end

local function hasAccess(src)
    if src == 0 then
        return true
    end

    if QBCore.Functions.HasPermission(src, Config.RequiredPermission) then
        return true
    end

    if Config.AllowAceCommand and IsPlayerAceAllowed(src, 'command') then
        return true
    end

    return false
end

local function getInventoryMode()
    if Config.Inventory ~= 'auto' then
        return Config.Inventory
    end

    if GetResourceState('ox_inventory') == 'started' then
        return 'ox'
    end

    return 'qb'
end

local function getImageBase()
    local mode = getInventoryMode()

    if mode == 'ox' then
        return 'https://cfx-nui-ox_inventory/web/images/'
    end

    return 'https://cfx-nui-qb-inventory/html/images/'
end

local function loadOverrides()
    local raw = LoadResourceFile(GetCurrentResourceName(), OverrideFile)
    if not raw or raw == '' then
        return { locations = {}, items = {} }
    end

    local decoded = json.decode(raw)
    if type(decoded) ~= 'table' then
        return { locations = {}, items = {} }
    end

    decoded.locations = decoded.locations or {}
    if type(decoded.items) ~= 'table' then
        decoded.items = {}
    end
    return decoded
end

local function saveOverrides(data)
    SaveResourceFile(GetCurrentResourceName(), OverrideFile, json.encode(data, { indent = true }), -1)
end

local function deepCopy(data)
    return json.decode(json.encode(data))
end

local function loadOxShopDefinitions()
    local raw = LoadResourceFile('ox_inventory', 'data/shops.lua')
    if not raw or raw == '' then
        return {}
    end

    local env = {
        shared = rawget(_G, 'shared') or {
            target = false,
            police = { police = 0 }
        },
        vec3 = function(x, y, z)
            return { x = x, y = y, z = z }
        end,
        vector3 = function(x, y, z)
            return { x = x, y = y, z = z }
        end,
        vec4 = function(x, y, z, w)
            return { x = x, y = y, z = z, w = w }
        end,
        vector4 = function(x, y, z, w)
            return { x = x, y = y, z = z, w = w }
        end,
    }

    setmetatable(env, { __index = _G })

    local chunk, err = load(raw, '@ox_inventory/data/shops.lua', 't', env)
    if not chunk then
        print(('[codex_adminitemoverlay] Failed to load ox shops: %s'):format(err))
        return {}
    end

    local ok, result = pcall(chunk)
    if not ok or type(result) ~= 'table' then
        print('[codex_adminitemoverlay] ox shops data did not return a table')
        return {}
    end

    return result
end

local function mergeShopOverrides(baseShops)
    local merged = deepCopy(baseShops)
    local overrides = loadOverrides()

    for shopKey, override in pairs(overrides.locations or {}) do
        if override.__isNew then
            merged[shopKey] = {
                name = override.label or shopKey,
                inventory = override.products or {},
                locations = override.locations or {},
                targets = override.targets or {},
                blip = override.blip
            }
        else
            merged[shopKey] = merged[shopKey] or {}

            if override.label then
                merged[shopKey].name = override.label
            end

            if override.products then
                merged[shopKey].inventory = override.products
            end

            if override.locations then
                merged[shopKey].locations = override.locations
            end
        end
    end

    return merged
end

local function loadOxItemDefinitions()
    local raw = LoadResourceFile('ox_inventory', 'data/items.lua')
    if not raw or raw == '' then
        return {}
    end

    local chunk, err = load(raw, '@ox_inventory/data/items.lua', 't', setmetatable({}, { __index = _G }))
    if not chunk then
        print(('[codex_adminitemoverlay] Failed to load ox items: %s'):format(err))
        return {}
    end

    local ok, result = pcall(chunk)
    if not ok or type(result) ~= 'table' then
        print('[codex_adminitemoverlay] ox items data did not return a table')
        return {}
    end

    return result
end

local function addItemToTarget(targetId, itemName, amount)
    local mode = getInventoryMode()

    if mode == 'ox' then
        local knownItem = nil

        if exports.ox_inventory.Items then
            local ok, result = pcall(function()
                return exports.ox_inventory:Items(itemName)
            end)

            if ok then
                knownItem = result
            end
        end

        -- Try best-effort even if ox_inventory doesn't yet report the runtime item.
        local success, err = nil, nil
        local ok, result = pcall(function()
            return exports.ox_inventory:AddItem(targetId, itemName, amount, {})
        end)

        if ok then
            success = result
        else
            err = result
        end

        local added = success == true or success == 1

        if added then
            return true, nil
        end

        if not knownItem then
            return false, 'missing_runtime_item'
        end

        return false, 'inventory_add_failed'
    end

    local success = exports['qb-inventory']:AddItem(targetId, itemName, amount, false, {}, 'codex_adminitemoverlay') == true
    return success, success and nil or 'inventory_add_failed'
end

local function normalizeAdminItemType(itemName, itemData)
    local loweredName = tostring(itemName or ''):lower()
    local rawType = tostring(itemData and itemData.type or 'item'):lower()

    if rawType == 'weapon' or (itemData and itemData.weapon) then
        return 'weapon'
    end

    if rawType == 'ammo'
        or (itemData and itemData.ammo)
        or loweredName:find('_ammo', 1, true)
        or loweredName:find('ammo', 1, true) then
        return 'muni'
    end

    return 'item'
end

local function getItemList()
    local overrides = loadOverrides()
    local mergedItems = {}
    local items = {}
    local customItems = {}

    for _, itemData in ipairs(overrides.items or {}) do
        if type(itemData) == 'table' then
            local itemName = tostring(itemData.name or ''):lower()
            if itemName ~= '' then
                customItems[itemName] = true
            end
        end
    end

    for itemName, itemData in pairs(QBCore.Shared.Items) do
        mergedItems[itemName] = itemData
    end

    for itemName, itemData in pairs(loadOxItemDefinitions()) do
        mergedItems[itemName] = {
            label = itemData.label or itemName,
            type = normalizeAdminItemType(itemName, itemData),
            description = itemData.description or '',
            weight = itemData.weight or 0,
            unique = itemData.stack == false,
            image = (itemData.client and itemData.client.image) or (itemData.image) or (itemName .. '.png')
        }
    end

    for _, itemData in ipairs(overrides.items or {}) do
        if type(itemData) == 'table' then
            local itemName = tostring(itemData.name or ''):lower()
            if itemName ~= '' then
                mergedItems[itemName] = itemData
            end
        end
    end

    for itemName, itemData in pairs(mergedItems) do
        items[#items + 1] = {
            name = itemName,
            label = itemData.label or itemName,
            type = normalizeAdminItemType(itemName, itemData),
            description = itemData.description or '',
            weight = itemData.weight or 0,
            unique = itemData.unique == true,
            image = itemData.image or (itemName .. '.png'),
            isCustom = customItems[itemName] == true
        }
    end

    table.sort(items, function(a, b)
        return a.label < b.label
    end)

    return items
end

local function getKnownItemData(itemName)
    itemName = tostring(itemName or ''):lower()
    if itemName == '' then
        return nil
    end

    local qbItem = QBCore.Shared.Items[itemName]
    if qbItem then
        return {
            name = itemName,
            label = qbItem.label or itemName,
            type = normalizeAdminItemType(itemName, qbItem),
            description = qbItem.description or '',
            weight = qbItem.weight or 0,
            unique = qbItem.unique == true,
            image = qbItem.image or (itemName .. '.png')
        }
    end

    local oxItem = loadOxItemDefinitions()[itemName]
    if oxItem then
        return {
            name = itemName,
            label = oxItem.label or itemName,
            type = normalizeAdminItemType(itemName, oxItem),
            description = oxItem.description or '',
            weight = oxItem.weight or 0,
            unique = oxItem.stack == false,
            image = (oxItem.client and oxItem.client.image) or oxItem.image or (itemName .. '.png')
        }
    end

    for _, overrideItem in ipairs(loadOverrides().items or {}) do
        if type(overrideItem) == 'table' and tostring(overrideItem.name or ''):lower() == itemName then
            return {
                name = itemName,
                label = overrideItem.label or itemName,
                type = normalizeAdminItemType(itemName, overrideItem),
                description = overrideItem.description or '',
                weight = overrideItem.weight or 0,
                unique = overrideItem.unique == true,
                image = overrideItem.image or (itemName .. '.png'),
                isCustom = true
            }
        end
    end

    return nil
end

local function getPlayerList()
    local players = {}

    for sourceId, player in pairs(QBCore.Functions.GetQBPlayers()) do
        local fullName = ((player.PlayerData.charinfo.firstname or '') .. ' ' .. (player.PlayerData.charinfo.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')

        players[#players + 1] = {
            id = sourceId,
            name = fullName ~= '' and fullName or (player.PlayerData.name or GetPlayerName(sourceId)),
            citizenid = player.PlayerData.citizenid,
            license = player.PlayerData.license,
            ping = GetPlayerPing(sourceId)
        }
    end

    table.sort(players, function(a, b)
        return a.id < b.id
    end)

    return players
end

local function getPropList()
    if GetResourceState('codex_craftingprops') == 'started' and exports.codex_craftingprops.GetAdminProps then
        local ok, props = pcall(function()
            return exports.codex_craftingprops:GetAdminProps()
        end)

        if ok and type(props) == 'table' then
            return props
        end
    end

    return {}
end

local function getRecipeList()
    if GetResourceState('codex_craftingprops') == 'started' and exports.codex_craftingprops.GetAdminRecipes then
        local ok, recipeList = pcall(function()
            return exports.codex_craftingprops:GetAdminRecipes()
        end)

        if ok and type(recipeList) == 'table' then
            return recipeList
        end
    end

    return {}
end

local function notifyPlayer(target, message, msgType, refresh)
    TriggerClientEvent('codex_adminitemoverlay:client:notify', target, {
        message = message,
        type = msgType,
        refresh = refresh
    })
end

local function appendLuaTableEntry(resourceName, filePath, entryText)
    local raw = LoadResourceFile(resourceName, filePath)
    if not raw or raw == '' then
        return false, 'Datei konnte nicht geladen werden.'
    end

    local normalized = raw:gsub('\r\n', '\n'):gsub('%s+$', '')
    if not normalized:match('}%s*$') then
        return false, 'Dateiformat wurde nicht erkannt.'
    end

    local updated = normalized:gsub('}%s*$', entryText .. '\n}', 1)
    local saved = SaveResourceFile(resourceName, filePath, updated, -1)

    if saved == false then
        return false, 'Datei konnte nicht gespeichert werden.'
    end

    return true
end

local function createOxItemEntry(item)
    return ([[

    ['%s'] = {
        label = %q,
        weight = %s,
        stack = %s,
        close = %s,
        description = %q,
        client = {
            image = %q
        }
    },]]):format(
        item.name,
        item.label,
        item.weight,
        tostring(not item.unique),
        tostring(item.shouldClose),
        item.description,
        item.image
    )
end

local function appendOxItemEntry(item)
    local entryText = createOxItemEntry(item)
    local ok, err = appendLuaTableEntry('ox_inventory', 'data/items.lua', entryText)

    if not ok then
        return false, err
    end

    local verify = LoadResourceFile('ox_inventory', 'data/items.lua')
    if not verify or not verify:find(("['%s']"):format(item.name), 1, true) then
        return false, 'Eintrag wurde nach dem Schreiben nicht in ox_inventory/data/items.lua gefunden.'
    end

    return true
end

local function removeOxItemEntry(itemName)
    local raw = LoadResourceFile('ox_inventory', 'data/items.lua')
    if not raw or raw == '' then
        return false, 'ox_inventory/data/items.lua konnte nicht geladen werden.'
    end

    local normalized = raw:gsub('\r\n', '\n')
    local escapedName = itemName:gsub('([^%w])', '%%%1')
    local pattern = "\n%s*%['" .. escapedName .. "'%]%s*=%s*%b{}%s*,?"
    local updated, count = normalized:gsub(pattern, '', 1)

    if count == 0 then
        return false, 'Item wurde in ox_inventory/data/items.lua nicht gefunden.'
    end

    local saved = SaveResourceFile('ox_inventory', 'data/items.lua', updated, -1)
    if saved == false then
        return false, 'ox_inventory/data/items.lua konnte nicht gespeichert werden.'
    end

    local verify = LoadResourceFile('ox_inventory', 'data/items.lua')
    if verify and verify:find(("['%s']"):format(itemName), 1, true) then
        return false, 'Item ist nach dem Loeschen noch in ox_inventory/data/items.lua vorhanden.'
    end

    return true
end

local function registerRuntimeItem(item)
    QBCore.Shared.Items[item.name] = {
        name = item.name,
        label = item.label,
        weight = item.weight,
        type = item.type,
        image = item.image,
        unique = item.unique,
        useable = item.useable,
        shouldClose = item.shouldClose,
        description = item.description
    }
end

local function restartOxInventory()
    return queueOxInventoryReload(0)
end

local function buildCreateItemResponse(itemData, messageWhenRestarted, messageWhenNotRestarted)
    local restarted = restartOxInventory()

    return {
        ok = true,
        message = restarted and messageWhenRestarted or messageWhenNotRestarted,
        type = 'success',
        refresh = true,
        item = itemData
    }
end

local function buildDeleteItemResponse(itemData, messageWhenRestarted, messageWhenNotRestarted)
    local restarted = restartOxInventory()

    return {
        ok = true,
        message = restarted and messageWhenRestarted or messageWhenNotRestarted,
        type = 'success',
        refresh = true,
        item = itemData
    }
end

local handleCreateItem

local function ensureBlueprintItem(src, payload)
    local blueprintItem = tostring(payload.blueprintItem or ''):lower():gsub('%s+', '_')
    if blueprintItem == '' or payload.autoCreateBlueprint ~= true then
        return true, nil
    end

    for _, item in ipairs(getItemList()) do
        if tostring(item.name or ''):lower() == blueprintItem then
            return true, nil
        end
    end

    local response = handleCreateItem(src, {
        name = blueprintItem,
        label = tostring(payload.blueprintLabel or payload.label or blueprintItem),
        type = 'item',
        weight = 0,
        image = tostring(payload.blueprintImage or ''):gsub('^%s+', ''):gsub('%s+$', ''),
        unique = false,
        useable = false,
        shouldClose = true,
        description = tostring(payload.blueprintDescription or ('Bauplan fuer ' .. tostring(payload.label or payload.item or blueprintItem)))
    })

    if response and response.ok then
        return true, response
    end

    return false, response
end

local function handleSaveRecipe(src, payload)
    if not hasAccess(src) then
        return { ok = false, message = 'Keine Berechtigung.', type = 'error', refresh = false }
    end

    if type(payload) ~= 'table' then
        return { ok = false, message = 'Ungueltige Rezept-Anfrage.', type = 'error', refresh = false }
    end

    local blueprintOk, blueprintResult = ensureBlueprintItem(src, payload)
    if not blueprintOk then
        return blueprintResult or { ok = false, message = 'Bauplan-Item konnte nicht erstellt werden.', type = 'error', refresh = false }
    end

    if GetResourceState('codex_craftingprops') ~= 'started' or not exports.codex_craftingprops.SaveAdminRecipe then
        return { ok = false, message = 'Crafting-Resource ist nicht gestartet.', type = 'error', refresh = false }
    end

    local ok, success, message, recipe = pcall(function()
        return exports.codex_craftingprops:SaveAdminRecipe(payload)
    end)

    if not ok or not success then
        return { ok = false, message = message or 'Rezept konnte nicht gespeichert werden.', type = 'error', refresh = false }
    end

    local finalMessage = message or 'Rezept gespeichert.'
    if blueprintResult and blueprintResult.ok and blueprintResult.item then
        finalMessage = finalMessage .. ' Bauplan-Item wurde erstellt.'
    end

    return {
        ok = true,
        message = finalMessage,
        type = 'success',
        refresh = true,
        recipe = recipe
    }
end

local function handleDeleteRecipe(src, payload)
    if not hasAccess(src) then
        return { ok = false, message = 'Keine Berechtigung.', type = 'error', refresh = false }
    end

    if type(payload) ~= 'table' then
        return { ok = false, message = 'Ungueltige Rezept-Loeschanfrage.', type = 'error', refresh = false }
    end

    local recipeKey = tostring(payload.key or '')
    if recipeKey == '' then
        return { ok = false, message = 'Rezept-Key fehlt.', type = 'error', refresh = false }
    end

    if GetResourceState('codex_craftingprops') ~= 'started' or not exports.codex_craftingprops.DeleteAdminRecipe then
        return { ok = false, message = 'Crafting-Resource ist nicht gestartet.', type = 'error', refresh = false }
    end

    local ok, success, message, recipe = pcall(function()
        return exports.codex_craftingprops:DeleteAdminRecipe(recipeKey)
    end)

    if not ok or not success then
        return { ok = false, message = message or 'Rezept konnte nicht geloescht werden.', type = 'error', refresh = false }
    end

    return {
        ok = true,
        message = message or 'Rezept geloescht.',
        type = 'success',
        refresh = true,
        recipe = recipe
    }
end

local function handlePlayerAction(src, payload)
    if not hasAccess(src) then
        return { ok = false, message = 'Keine Berechtigung.', type = 'error', refresh = false }
    end

    if type(payload) ~= 'table' then
        return { ok = false, message = 'Ungueltige Spieler-Anfrage.', type = 'error', refresh = false }
    end

    local action = tostring(payload.action or '')
    local targetId = tonumber(payload.targetId)

    if not targetId or not QBCore.Functions.GetPlayer(targetId) then
        return { ok = false, message = 'Spieler wurde nicht gefunden.', type = 'error', refresh = true }
    end

    local targetPed = GetPlayerPed(targetId)
    if targetPed == 0 then
        return { ok = false, message = 'Spieler-Ped konnte nicht geladen werden.', type = 'error', refresh = true }
    end

    if action == 'heal' then
        SetEntityHealth(targetPed, GetEntityMaxHealth(targetPed))
        ClearPedBloodDamage(targetPed)
        SetPedArmour(targetPed, 100)
        return { ok = true, message = ('Spieler %s wurde geheilt.'):format(targetId), type = 'success', refresh = true }
    end

    local adminPed = GetPlayerPed(src)
    if adminPed == 0 then
        return { ok = false, message = 'Dein Ped konnte nicht geladen werden.', type = 'error', refresh = false }
    end

    if action == 'goto' then
        local targetCoords = GetEntityCoords(targetPed)
        SetEntityCoords(adminPed, targetCoords.x, targetCoords.y, targetCoords.z + 1.0, false, false, false, false)
        return { ok = true, message = ('Du wurdest zu Spieler %s teleportiert.'):format(targetId), type = 'success', refresh = false }
    end

    if action == 'bring' then
        local adminCoords = GetEntityCoords(adminPed)
        SetEntityCoords(targetPed, adminCoords.x, adminCoords.y, adminCoords.z + 1.0, false, false, false, false)
        return { ok = true, message = ('Spieler %s wurde zu dir teleportiert.'):format(targetId), type = 'success', refresh = true }
    end

    if action == 'set_armor' then
        local armor = math.floor(tonumber(payload.armor) or 0)
        armor = math.max(0, math.min(armor, 100))
        SetPedArmour(targetPed, armor)
        return { ok = true, message = ('Ruestung von Spieler %s auf %s gesetzt.'):format(targetId, armor), type = 'success', refresh = true }
    end

    if action == 'set_health' then
        local hp = math.floor(tonumber(payload.health) or 0)
        local maxHp = GetEntityMaxHealth(targetPed)
        hp = math.max(1, math.min(hp, maxHp or 200))
        SetEntityHealth(targetPed, hp)
        return { ok = true, message = ('Leben von Spieler %s auf %s gesetzt.'):format(targetId, hp), type = 'success', refresh = true }
    end

    return { ok = false, message = 'Unbekannte Spieler-Aktion.', type = 'error', refresh = false }
end

local function handlePropAction(src, payload)
    if not hasAccess(src) then
        return { ok = false, message = 'Keine Berechtigung.', type = 'error', refresh = false }
    end

    if type(payload) ~= 'table' then
        return { ok = false, message = 'Ungueltige Prop-Anfrage.', type = 'error', refresh = false }
    end

    local action = tostring(payload.action or '')
    local propId = tonumber(payload.propId)

    if not propId then
        return { ok = false, message = 'Prop fehlt.', type = 'error', refresh = false }
    end

    local selectedProp = nil
    for _, prop in ipairs(getPropList()) do
        if tonumber(prop.id) == propId then
            selectedProp = prop
            break
        end
    end

    if not selectedProp then
        return { ok = false, message = 'Prop wurde nicht gefunden.', type = 'error', refresh = false }
    end

    if action == 'delete' then
        if GetResourceState('codex_craftingprops') ~= 'started' or not exports.codex_craftingprops.RemovePlacedProp then
            return { ok = false, message = 'Crafting-Resource ist nicht gestartet.', type = 'error', refresh = false }
        end

        local ok, removed = pcall(function()
            return exports.codex_craftingprops:RemovePlacedProp(propId)
        end)

        if not ok or not removed then
            return { ok = false, message = 'Prop konnte nicht geloescht werden.', type = 'error', refresh = false }
        end

        return { ok = true, message = ('Prop %s wurde geloescht.'):format(selectedProp.label or propId), type = 'success', refresh = true }
    end

    return { ok = false, message = 'Unbekannte Prop-Aktion.', type = 'error', refresh = false }
end

local function handleShopAction(src, payload)
    if not hasAccess(src) then
        return { ok = false, message = 'Keine Berechtigung.', type = 'error', refresh = false }
    end

    if type(payload) ~= 'table' then
        return { ok = false, message = 'Ungueltige Shop-Anfrage.', type = 'error', refresh = false }
    end

    local action = tostring(payload.action or '')
    local shopKey = tostring(payload.shopKey or '')
    local locationIndex = math.max(1, math.floor(tonumber(payload.locationIndex) or 1))

    if shopKey == '' then
        return { ok = false, message = 'Shop fehlt.', type = 'error', refresh = false }
    end

    local selectedShop = nil
    for _, shop in ipairs(getShopList()) do
        if shop.key == shopKey then
            selectedShop = shop
            break
        end
    end

    if not selectedShop then
        return { ok = false, message = 'Shop wurde nicht gefunden.', type = 'error', refresh = false }
    end

    local adminPed = GetPlayerPed(src)
    if adminPed == 0 then
        return { ok = false, message = 'Dein Ped konnte nicht geladen werden.', type = 'error', refresh = false }
    end

    if action == 'goto_npc' then
        local coords = selectedShop.locations and selectedShop.locations[locationIndex] or selectedShop.coords
        if not coords then
            return { ok = false, message = 'Dieser Shop hat keine NPC-Position.', type = 'error', refresh = false }
        end

        return {
            ok = true,
            message = ('Zu NPC %s von %s teleportiert.'):format(locationIndex, selectedShop.label),
            type = 'success',
            refresh = false,
            teleported = true,
            teleport = {
                x = coords.x,
                y = coords.y,
                z = coords.z,
                w = coords.w
            }
        }
    end

    if action == 'goto_shop' then
        local coords = selectedShop.coords or (selectedShop.locations and selectedShop.locations[1]) or nil
        if not coords then
            return { ok = false, message = 'Dieser Shop hat keine Shop-Position.', type = 'error', refresh = false }
        end

        return {
            ok = true,
            message = ('Zu %s teleportiert.'):format(selectedShop.label),
            type = 'success',
            refresh = false,
            teleported = true,
            teleport = {
                x = coords.x,
                y = coords.y,
                z = coords.z,
                w = coords.w
            }
        }
    end

    if action == 'face_npc_to_me' then
        local coords = GetEntityCoords(adminPed)
        local currentLocation = selectedShop.locations and selectedShop.locations[locationIndex] or selectedShop.coords

        if not currentLocation then
            return { ok = false, message = 'Dieser Shop hat keine NPC-Position.', type = 'error', refresh = false }
        end

        local heading = GetHeadingFromVector_2d(coords.x - currentLocation.x, coords.y - currentLocation.y)

        setShopLocationByIndex(shopKey, locationIndex, {
            x = currentLocation.x,
            y = currentLocation.y,
            z = currentLocation.z,
            w = heading
        })
        TriggerClientEvent('ox_inventory:refreshShops', -1)
        ensureOxInventoryForShopNpcUpdate()

        return { ok = true, message = ('NPC %s von %s schaut jetzt zu dir. ox_inventory wird in ein paar Sekunden neu ensured.'):format(locationIndex, selectedShop.label), type = 'success', refresh = true }
    end

    if action == 'move_npc_here' then
        local coords = GetEntityCoords(adminPed)
        local heading = GetEntityHeading(adminPed)

        setShopLocationByIndex(shopKey, locationIndex, {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            w = heading
        })
        TriggerClientEvent('ox_inventory:refreshShops', -1)
        ensureOxInventoryForShopNpcUpdate()

        return { ok = true, message = ('NPC von %s wurde an deine Position gesetzt. ox_inventory wird in ein paar Sekunden neu ensured.'):format(selectedShop.label), type = 'success', refresh = true }
    end

    if action == 'delete_npc' then
        local ok, err = removeShopLocationByIndex(shopKey, locationIndex)
        if not ok then
            return { ok = false, message = err or 'NPC konnte nicht geloescht werden.', type = 'error', refresh = false }
        end

        TriggerClientEvent('ox_inventory:refreshShops', -1)
        ensureOxInventoryForShopNpcUpdate()

        return { ok = true, message = ('NPC %s von %s wurde geloescht. ox_inventory wird in ein paar Sekunden neu ensured.'):format(locationIndex, selectedShop.label), type = 'success', refresh = true }
    end

    return { ok = false, message = 'Unbekannte Shop-Aktion.', type = 'error', refresh = false }
end

function getShopList()
    if GetResourceState('ox_inventory') == 'started' and exports.ox_inventory.GetAdminShopData then
        local ok, shops = pcall(function()
            return exports.ox_inventory:GetAdminShopData()
        end)

        if ok and type(shops) == 'table' then
            return shops
        end
    end

    local data = mergeShopOverrides(loadOxShopDefinitions())
    local shops = {}

    for shopKey, shop in pairs(data) do
        local products = {}
        for index, product in ipairs(shop.inventory or {}) do
            local itemInfo = QBCore.Shared.Items[tostring(product.name or ''):lower()]
            products[#products + 1] = {
                index = index,
                name = product.name,
                label = itemInfo and itemInfo.label or product.name,
                image = itemInfo and itemInfo.image or (product.name .. '.png'),
                type = itemInfo and itemInfo.type or 'item',
                description = itemInfo and itemInfo.description or '',
                price = product.price or 0,
                amount = product.count or product.amount or 0,
                metadata = product.metadata,
                currency = product.currency,
                license = product.license,
                grade = product.grade
            }
        end

        local coords = nil
        if shop.locations and shop.locations[1] then
            coords = shop.locations[1]
        elseif shop.targets and shop.targets[1] and shop.targets[1].loc then
            coords = shop.targets[1].loc
        end

        shops[#shops + 1] = {
            key = shopKey,
            label = shop.name or shopKey,
            coords = coords and {
                x = coords.x,
                y = coords.y,
                z = coords.z,
                w = coords.w
            } or nil,
            locations = (function()
                local list = {}

                if shop.locations then
                    for _, location in ipairs(shop.locations) do
                        list[#list + 1] = {
                            x = location.x,
                            y = location.y,
                            z = location.z,
                            w = location.w
                        }
                    end
                elseif shop.targets then
                    for _, target in ipairs(shop.targets) do
                        if target.loc then
                            list[#list + 1] = {
                                x = target.loc.x,
                                y = target.loc.y,
                                z = target.loc.z,
                                w = target.heading
                            }
                        end
                    end
                end

                return list
            end)(),
            products = products
        }
    end

    table.sort(shops, function(a, b)
        return a.label < b.label
    end)

    return shops
end

local function getBaseShopProducts(shopKey)
    for _, shop in ipairs(getShopList()) do
        if shop.key == shopKey then
            local products = {}

            for _, product in ipairs(shop.products or {}) do
                products[#products + 1] = {
                    name = product.name,
                    price = product.price or 0,
                    count = product.amount or 0,
                    metadata = product.metadata,
                    currency = product.currency,
                    license = product.license,
                    grade = product.grade
                }
            end

            return products
        end
    end

    return {}
end

local function getBaseShopDefinition(shopKey)
    local definitions = loadOxShopDefinitions()
    return definitions[shopKey]
end

local applyLiveShop

local function setShopPrimaryLocation(shopKey, coords)
    local overrides = loadOverrides()
    local override = overrides.locations[shopKey] or {}
    local base = getBaseShopDefinition(shopKey)

    override.locations = override.locations or (base and deepCopy(base.locations)) or {}
    override.locations[1] = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = coords.w
    }

    overrides.locations[shopKey] = override
    saveOverrides(overrides)
    applyLiveShop(shopKey)
end

function setShopLocationByIndex(shopKey, index, coords)
    local overrides = loadOverrides()
    local override = overrides.locations[shopKey] or {}
    local base = getBaseShopDefinition(shopKey)

    override.locations = override.locations or (base and deepCopy(base.locations)) or {}

    while #override.locations < index do
        override.locations[#override.locations + 1] = {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            w = coords.w
        }
    end

    override.locations[index] = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = coords.w
    }

    overrides.locations[shopKey] = override
    saveOverrides(overrides)
    applyLiveShop(shopKey)
end

function removeShopLocationByIndex(shopKey, index)
    local overrides = loadOverrides()
    local override = overrides.locations[shopKey] or {}
    local base = getBaseShopDefinition(shopKey)

    override.locations = override.locations or (base and deepCopy(base.locations)) or {}

    if not override.locations[index] then
        return false, 'NPC wurde nicht gefunden.'
    end

    if #override.locations <= 1 then
        return false, 'Der letzte NPC kann nicht geloescht werden.'
    end

    table.remove(override.locations, index)
    overrides.locations[shopKey] = override
    saveOverrides(overrides)
    applyLiveShop(shopKey)

    return true
end

function applyLiveShop(shopKey)
    if GetResourceState('ox_inventory') == 'started' and exports.ox_inventory.ApplyAdminShopOverride then
        local overrides = loadOverrides()
        local override = overrides.locations[shopKey]
        pcall(function()
            exports.ox_inventory:ApplyAdminShopOverride(shopKey, override)
        end)
    end
end

local function resetLiveShop(shopKey)
    if GetResourceState('ox_inventory') == 'started' and exports.ox_inventory.ResetAdminShopOverride then
        pcall(function()
            exports.ox_inventory:ResetAdminShopOverride(shopKey)
        end)
    end
end

QBCore.Functions.CreateCallback('codex_adminitemoverlay:server:getOpenData', function(source, cb)
    if not hasAccess(source) then
        cb({ allowed = false })
        return
    end

    local okItems, items = pcall(getItemList)
    local okPlayers, players = pcall(getPlayerList)
    local okShops, shops = pcall(getShopList)
    local okProps, props = pcall(getPropList)
    local okRecipes, recipeList = pcall(getRecipeList)

    cb({
        allowed = true,
        items = okItems and items or {},
        shops = okShops and shops or {},
        players = okPlayers and players or {},
        props = okProps and props or {},
        recipes = okRecipes and recipeList or {},
        limits = {
            maxAmount = Config.MaxAmount,
            defaultNearbyDistance = Config.DefaultNearbyDistance,
            maxNearbyDistance = Config.MaxNearbyDistance
        },
        meta = {
            title = Config.Ui.title,
            subtitle = Config.Ui.subtitle,
            imageBase = getImageBase()
        }
    })
end)

RegisterCommand(Config.Command, function(source)
    if source == 0 then
        print(('[%s] This command can only be used in-game.'):format(GetCurrentResourceName()))
        return
    end

    if not hasAccess(source) then
        notifyPlayer(source, 'Du hast keine Rechte fuer dieses Overlay.', 'error', false)
        return
    end

    TriggerClientEvent('codex_adminitemoverlay:client:toggle', source)
end, false)

handleCreateItem = function(src, payload)
    if not hasAccess(src) then
        return { ok = false, message = 'Keine Berechtigung.', type = 'error', refresh = false }
    end

    if type(payload) ~= 'table' then
        return { ok = false, message = 'Ungueltige Item-Anfrage.', type = 'error', refresh = false }
    end

    local itemName = tostring(payload.name or ''):lower():gsub('%s+', '_')
    local label = tostring(payload.label or ''):gsub('^%s+', ''):gsub('%s+$', '')
    local itemType = tostring(payload.type or 'item'):lower()
    local weight = math.max(0, math.floor(tonumber(payload.weight) or 0))
    local image = tostring(payload.image or ''):gsub('^%s+', ''):gsub('%s+$', '')
    local description = tostring(payload.description or ''):gsub('^%s+', ''):gsub('%s+$', '')

    if itemName == '' or label == '' then
        return { ok = false, message = 'Item Name und Label sind Pflicht.', type = 'error', refresh = false }
    end

    if not itemName:match('^[a-z0-9_]+$') then
        return { ok = false, message = 'Item Name darf nur Kleinbuchstaben, Zahlen und _ enthalten.', type = 'error', refresh = false }
    end

    if itemType ~= 'item' and itemType ~= 'weapon' and itemType ~= 'ammo' then
        return { ok = false, message = 'Ungueltiger Item-Typ.', type = 'error', refresh = false }
    end

    local overrides = loadOverrides()

    if QBCore.Shared.Items[itemName] then
        return { ok = false, message = 'Dieses Item existiert bereits.', type = 'error', refresh = false }
    end

    for _, overrideItem in ipairs(overrides.items or {}) do
        if type(overrideItem) == 'table' and tostring(overrideItem.name or ''):lower() == itemName then
            return { ok = false, message = 'Dieses Item existiert bereits in den Overlay-Daten.', type = 'error', refresh = false }
        end
    end

    if loadOxItemDefinitions()[itemName] then
        return { ok = false, message = 'Dieses Item existiert bereits in ox_inventory/data/items.lua.', type = 'error', refresh = false }
    end

    local itemData = {
        name = itemName,
        label = label,
        weight = weight,
        type = itemType,
        image = image ~= '' and image or (itemName .. '.png'),
        unique = payload.unique == true,
        useable = payload.useable == true,
        shouldClose = payload.shouldClose ~= false,
        description = description,
        isCustom = true
    }

    overrides.items[#overrides.items + 1] = {
        name = itemData.name,
        label = itemData.label,
        weight = itemData.weight,
        type = itemData.type,
        image = itemData.image,
        unique = itemData.unique,
        useable = itemData.useable,
        shouldClose = itemData.shouldClose,
        description = itemData.description
    }
    saveOverrides(overrides)
    registerRuntimeItem(itemData)

    local oxOk, oxErr = appendOxItemEntry(itemData)
    if not oxOk then
        for index = #overrides.items, 1, -1 do
            local entry = overrides.items[index]
            if type(entry) == 'table' and tostring(entry.name or ''):lower() == itemName then
                table.remove(overrides.items, index)
                break
            end
        end
        saveOverrides(overrides)
        QBCore.Shared.Items[itemName] = nil
        return { ok = false, message = ('Item konnte nicht in ox_inventory/data/items.lua geschrieben werden: %s'):format(oxErr or 'Unbekannter Fehler'), type = 'error', refresh = false }
    end

    return buildCreateItemResponse(
        itemData,
        'Item erstellt - ox_inventory wird jetzt automatisch neu geladen',
        'Item erstellt - ox_inventory konnte nicht automatisch neu geladen werden'
    )
end

local function handleDeleteItem(src, payload)
    if not hasAccess(src) then
        return { ok = false, message = 'Keine Berechtigung.', type = 'error', refresh = false }
    end

    if type(payload) ~= 'table' then
        return { ok = false, message = 'Ungueltige Delete-Anfrage.', type = 'error', refresh = false }
    end

    local itemName = tostring(payload.name or ''):lower():gsub('%s+', '_')
    if itemName == '' then
        return { ok = false, message = 'Item Name fehlt.', type = 'error', refresh = false }
    end

    local overrides = loadOverrides()
    local removedItem = nil

    for index = #overrides.items, 1, -1 do
        local itemData = overrides.items[index]
        if type(itemData) == 'table' and tostring(itemData.name or ''):lower() == itemName then
            removedItem = itemData
            table.remove(overrides.items, index)
            break
        end
    end

    if not removedItem then
        return { ok = false, message = 'Nur eigene erstellte Items koennen geloescht werden.', type = 'error', refresh = false }
    end

    local oxOk, oxErr = removeOxItemEntry(itemName)
    if not oxOk then
        overrides.items[#overrides.items + 1] = removedItem
        saveOverrides(overrides)
        return { ok = false, message = ('Item konnte nicht aus ox_inventory/data/items.lua geloescht werden: %s'):format(oxErr or 'Unbekannter Fehler'), type = 'error', refresh = false }
    end

    saveOverrides(overrides)

    if QBCore.Shared.Items[itemName] and removedItem.isCustom ~= false then
        QBCore.Shared.Items[itemName] = nil
    end

    return buildDeleteItemResponse(
        removedItem,
        'Item geloescht - ox_inventory wird jetzt automatisch neu geladen',
        'Item geloescht - ox_inventory konnte nicht automatisch neu geladen werden'
    )
end

QBCore.Functions.CreateCallback('codex_adminitemoverlay:server:createItem', function(source, cb, payload)
    local result = handleCreateItem(source, payload)
    cb(result)
end)

QBCore.Functions.CreateCallback('codex_adminitemoverlay:server:deleteItem', function(source, cb, payload)
    local result = handleDeleteItem(source, payload)
    cb(result)
end)

QBCore.Functions.CreateCallback('codex_adminitemoverlay:server:saveRecipe', function(source, cb, payload)
    local result = handleSaveRecipe(source, payload)
    cb(result)
end)

QBCore.Functions.CreateCallback('codex_adminitemoverlay:server:deleteRecipe', function(source, cb, payload)
    local result = handleDeleteRecipe(source, payload)
    cb(result)
end)

QBCore.Functions.CreateCallback('codex_adminitemoverlay:server:playerAction', function(source, cb, payload)
    local result = handlePlayerAction(source, payload)
    cb(result)
end)


-- Spawn a vehicle for a player (target) or the source if no target provided
RegisterNetEvent('codex_adminitemoverlay:server:spawnVehicle', function(payload)
    local src = source
    if not hasAccess(src) then
        notifyPlayer(src, 'Keine Berechtigung.', 'error', false)
        return
    end

    if type(payload) ~= 'table' then
        notifyPlayer(src, 'Ungueltige Fahrzeug-Anfrage.', 'error', false)
        return
    end

    local model = tostring(payload.model or '')
    local targetId = tonumber(payload.targetId) or src

    if model == '' then
        notifyPlayer(src, 'Fahrzeugmodell fehlt.', 'error', false)
        return
    end

    TriggerClientEvent('codex_adminitemoverlay:client:spawnVehicle', targetId, { model = model, plate = payload.plate })
    if targetId == src then
        notifyPlayer(src, ('Fahrzeug %s gespawnt.'):format(model), 'success', false)
    else
        notifyPlayer(src, ('Fahrzeug %s fuer Spieler %s gespawnt.'):format(model, targetId), 'success', false)
        notifyPlayer(targetId, ('Ein Fahrzeug wurde fuer dich gespawnt: %s'):format(model), 'primary', false)
    end
end)

RegisterNetEvent('codex_adminitemoverlay:server:spectatePlayer', function(payload)
    local src = source
    if not hasAccess(src) then
        notifyPlayer(src, 'Keine Berechtigung.', 'error', false)
        return
    end

    local targetId = tonumber(payload and payload.targetId) or nil
    if not targetId then
        notifyPlayer(src, 'Zielspieler fehlt.', 'error', false)
        return
    end

    TriggerClientEvent('codex_adminitemoverlay:client:spectate', src, targetId)
    notifyPlayer(src, ('Spectate gestartet fuer Spieler %s'):format(targetId), 'primary', false)
end)

RegisterNetEvent('codex_adminitemoverlay:server:unspectatePlayer', function()
    local src = source
    if not hasAccess(src) then
        notifyPlayer(src, 'Keine Berechtigung.', 'error', false)
        return
    end

    TriggerClientEvent('codex_adminitemoverlay:client:unspectate', src)
    notifyPlayer(src, 'Spectate beendet', 'success', false)
end)


QBCore.Functions.CreateCallback('codex_adminitemoverlay:server:getPlayerInventory', function(source, cb, targetId)
    if not hasAccess(source) then
        cb({ ok = false, message = 'Keine Berechtigung.' })
        return
    end

    local tid = tonumber(targetId)
    if not tid or not QBCore.Functions.GetPlayer(tid) then
        cb({ ok = false, message = 'Spieler nicht gefunden.' })
        return
    end

    local player = QBCore.Functions.GetPlayer(tid)
    local inv = {}
    if player and player.PlayerData and player.PlayerData.items then
        inv = player.PlayerData.items
    elseif player and player.PlayerData and player.PlayerData.inventory then
        inv = player.PlayerData.inventory
    end

    cb({ ok = true, inventory = inv })
end)

QBCore.Functions.CreateCallback('codex_adminitemoverlay:server:propAction', function(source, cb, payload)
    local result = handlePropAction(source, payload)
    cb(result)
end)

QBCore.Functions.CreateCallback('codex_adminitemoverlay:server:shopAction', function(source, cb, payload)
    local result = handleShopAction(source, payload)
    cb(result)
end)

RegisterNetEvent('codex_adminitemoverlay:server:moveShopNpc', function(payload)
    local src = source
    local result = handleShopAction(src, {
        action = 'move_npc_here',
        shopKey = payload and payload.shopKey,
        locationIndex = payload and payload.locationIndex
    })

    if result and result.refresh then
        TriggerClientEvent('ox_inventory:refreshShops', -1)
    end

    if result and result.message then
        notifyPlayer(src, result.message, result.type or 'primary', result.refresh == true)
    end
end)

RegisterNetEvent('codex_adminitemoverlay:server:faceShopNpc', function(payload)
    local src = source
    local result = handleShopAction(src, {
        action = 'face_npc_to_me',
        shopKey = payload and payload.shopKey,
        locationIndex = payload and payload.locationIndex
    })

    if result and result.refresh then
        TriggerClientEvent('ox_inventory:refreshShops', -1)
    end

    if result and result.message then
        notifyPlayer(src, result.message, result.type or 'primary', result.refresh == true)
    end
end)

RegisterNetEvent('codex_adminitemoverlay:server:deleteShopNpc', function(payload)
    local src = source
    local result = handleShopAction(src, {
        action = 'delete_npc',
        shopKey = payload and payload.shopKey,
        locationIndex = payload and payload.locationIndex
    })

    if result and result.refresh then
        TriggerClientEvent('ox_inventory:refreshShops', -1)
    end

    if result and result.message then
        notifyPlayer(src, result.message, result.type or 'primary', result.refresh == true)
    end
end)

RegisterNetEvent('codex_adminitemoverlay:server:createItem', function(payload)
    local src = source
    local result = handleCreateItem(src, payload)
    if result and result.message then
        notifyPlayer(src, result.message, result.type or 'primary', result.refresh == true)
    end
end)

RegisterNetEvent('codex_adminitemoverlay:server:saveShopProduct', function(payload)
    local src = source
    if not hasAccess(src) then
        notifyPlayer(src, 'Keine Berechtigung.', 'error', false)
        return
    end

    if type(payload) ~= 'table' then
        notifyPlayer(src, 'Ungueltige Shop-Anfrage.', 'error', false)
        return
    end

    local shopKey = tostring(payload.shopKey or '')
    local product = payload.product
    local index = tonumber(payload.index)

    if shopKey == '' or type(product) ~= 'table' then
        notifyPlayer(src, 'Shop oder Produkt fehlt.', 'error', false)
        return
    end

    local itemName = tostring(product.name or ''):lower()
    if not getKnownItemData(itemName) then
        notifyPlayer(src, 'Dieses Item existiert nicht.', 'error', false)
        return
    end

    local price = math.floor(tonumber(product.price) or 0)
    local amount = math.floor(tonumber(product.amount) or 0)
    local requiredGrade = product.requiredGrade ~= nil and tonumber(product.requiredGrade) or nil

    local newProduct = {
        name = itemName,
        price = price,
    }

    if amount > 0 then
        newProduct.count = amount
    end

    if product.info and tostring(product.info) ~= '' then
        local ok, decoded = pcall(json.decode, product.info)
        if ok and type(decoded) == 'table' then
            newProduct.metadata = decoded
        end
    end

    if product.requiredLicense and tostring(product.requiredLicense) ~= '' then
        newProduct.license = product.requiredLicense
    end

    if requiredGrade then
        newProduct.grade = requiredGrade
    end

    local overrides = loadOverrides()
    overrides.locations[shopKey] = overrides.locations[shopKey] or {}
    overrides.locations[shopKey].products = overrides.locations[shopKey].products or getBaseShopProducts(shopKey)

    if index and overrides.locations[shopKey].products[index] then
        overrides.locations[shopKey].products[index] = newProduct
    else
        overrides.locations[shopKey].products[#overrides.locations[shopKey].products + 1] = newProduct
    end

    saveOverrides(overrides)
    applyLiveShop(shopKey)
    notifyPlayer(src, 'Produkt gespeichert', 'success', true)
end)

RegisterNetEvent('codex_adminitemoverlay:server:createShop', function(payload)
    local src = source
    if not hasAccess(src) then
        notifyPlayer(src, 'Keine Berechtigung.', 'error', false)
        return
    end

    local shopKey = tostring(payload and payload.shopKey or ''):gsub('%s+', '')
    local label = tostring(payload and payload.label or '')
    if shopKey == '' or label == '' then
        notifyPlayer(src, 'Shop-Key und Label sind Pflicht.', 'error', false)
        return
    end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    local overrides = loadOverrides()
    overrides.locations[shopKey] = {
        __isNew = true,
        label = label,
        locations = {
            {
                x = coords.x,
                y = coords.y,
                z = coords.z
            }
        },
        products = {}
    }

    saveOverrides(overrides)
    applyLiveShop(shopKey)
    TriggerClientEvent('ox_inventory:refreshShops', -1)
    notifyPlayer(src, 'Shop erstellt', 'success', true)
end)

RegisterNetEvent('codex_adminitemoverlay:server:deleteShopProduct', function(payload)
    local src = source
    if not hasAccess(src) then
        notifyPlayer(src, 'Keine Berechtigung.', 'error', false)
        return
    end

    local shopKey = tostring(payload and payload.shopKey or '')
    local index = tonumber(payload and payload.index)
    if shopKey == '' or not index then
        notifyPlayer(src, 'Shop oder Index fehlt.', 'error', false)
        return
    end

    local overrides = loadOverrides()
    overrides.locations[shopKey] = overrides.locations[shopKey] or {}
    overrides.locations[shopKey].products = overrides.locations[shopKey].products or getBaseShopProducts(shopKey)

    table.remove(overrides.locations[shopKey].products, index)
    saveOverrides(overrides)
    applyLiveShop(shopKey)
    notifyPlayer(src, 'Produkt entfernt', 'success', true)
end)

RegisterNetEvent('codex_adminitemoverlay:server:resetShopOverrides', function(payload)
    local src = source
    if not hasAccess(src) then
        notifyPlayer(src, 'Keine Berechtigung.', 'error', false)
        return
    end

    local shopKey = tostring(payload and payload.shopKey or '')
    if shopKey == '' then
        notifyPlayer(src, 'Shop fehlt.', 'error', false)
        return
    end

    local overrides = loadOverrides()
    overrides.locations[shopKey] = nil
    saveOverrides(overrides)
    resetLiveShop(shopKey)
    notifyPlayer(src, 'Shop zurueckgesetzt', 'success', true)
end)

RegisterNetEvent('codex_adminitemoverlay:server:giveItem', function(payload)
    local src = source

    if not hasAccess(src) then
        notifyPlayer(src, 'Keine Berechtigung.', 'error', false)
        return
    end

    if type(payload) ~= 'table' then
        notifyPlayer(src, 'Ungueltige Anfrage.', 'error', false)
        return
    end

    local itemName = tostring(payload.itemName or ''):lower()
    local itemData = getKnownItemData(itemName)
    local giveType = tostring(payload.giveType or '')
    local amount = math.floor(tonumber(payload.amount) or 0)

    if not itemData then
        notifyPlayer(src, 'Dieses Item existiert nicht.', 'error', false)
        return
    end

    if amount < 1 or amount > Config.MaxAmount then
        notifyPlayer(src, ('Die Menge muss zwischen 1 und %s liegen.'):format(Config.MaxAmount), 'error', false)
        return
    end

    local delivered = 0
    local failed = 0
    local missingRuntimeItem = false

    local function deliver(targetId)
        if not QBCore.Functions.GetPlayer(targetId) then
            failed = failed + 1
            return
        end

        local success, reason = addItemToTarget(targetId, itemName, amount)

        if success then
            delivered = delivered + 1
            notifyPlayer(targetId, ('Du hast %sx %s erhalten.'):format(amount, itemData.label or itemName), 'success', false)
        else
            failed = failed + 1
            if reason == 'missing_runtime_item' then
                missingRuntimeItem = true
            end
        end
    end

    if giveType == 'self' then
        deliver(src)
    elseif giveType == 'player' then
        local targetId = tonumber(payload.targetId)
        if not targetId then
            notifyPlayer(src, 'Bitte einen Spieler auswaehlen.', 'error', false)
            return
        end

        deliver(targetId)
    elseif giveType == 'all' then
        for _, playerId in ipairs(GetPlayers()) do
            deliver(tonumber(playerId))
        end
    elseif giveType == 'nearby' then
        local adminPed = GetPlayerPed(src)
        local adminCoords = adminPed ~= 0 and GetEntityCoords(adminPed) or nil
        local radius = tonumber(payload.radius) or Config.DefaultNearbyDistance

        if not adminCoords then
            notifyPlayer(src, 'Deine Position konnte nicht gelesen werden.', 'error', false)
            return
        end

        radius = math.max(1, math.min(radius, Config.MaxNearbyDistance))

        for _, playerId in ipairs(GetPlayers()) do
            local targetId = tonumber(playerId)

            if targetId and (Config.NearbyIncludesSelf or targetId ~= src) then
                local targetPed = GetPlayerPed(targetId)

                if targetPed ~= 0 then
                    local targetCoords = GetEntityCoords(targetPed)
                    if #(targetCoords - adminCoords) <= radius then
                        deliver(targetId)
                    end
                end
            end
        end
    else
        notifyPlayer(src, 'Unbekannter Zieltyp.', 'error', false)
        return
    end

    if delivered == 0 then
        if missingRuntimeItem then
            notifyPlayer(src, 'Dieses neue Item ist erst nach restart ox_inventory und restart codex_nagelband gebbar.', 'error', true)
            return
        end

        notifyPlayer(src, 'Es wurde niemandem ein Item gegeben. Vielleicht war das Inventar voll oder niemand war im Radius.', 'error', true)
        return
    end

    local summary = ('%sx %s an %s Ziel(e) gegeben'):format(amount, itemData.label or itemName, delivered)
    if failed > 0 then
        summary = summary .. (' (%s fehlgeschlagen)'):format(failed)
    end

    notifyPlayer(src, summary, 'success', true)
end)
