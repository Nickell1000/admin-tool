local QBCore = exports['qb-core']:GetCoreObject()

local overlayOpen = false

local function teleportLocalPlayer(coords)
    if type(coords) ~= 'table' then
        return false
    end

    local ped = PlayerPedId()
    if ped == 0 then
        return false
    end

    DoScreenFadeOut(150)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    SetEntityCoordsNoOffset(ped, coords.x + 0.0, coords.y + 0.0, (coords.z + 1.0) + 0.0, false, false, false)

    if coords.w then
        SetEntityHeading(ped, coords.w + 0.0)
    end

    Wait(100)
    DoScreenFadeIn(150)
    return true
end

local function setOverlayState(isOpen, payload)
    overlayOpen = isOpen
    SetNuiFocus(isOpen, isOpen)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        action = isOpen and 'open' or 'close',
        data = payload
    })
end

CreateThread(function()
    Wait(500)
    setOverlayState(false)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    overlayOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
end)

local function refreshOverlay()
    QBCore.Functions.TriggerCallback('codex_adminitemoverlay:server:getOpenData', function(response)
        if not response or not response.allowed then
            QBCore.Functions.Notify('Du hast keine Rechte fur dieses Overlay.', 'error')
            setOverlayState(false)
            return
        end

        if overlayOpen then
            SendNUIMessage({
                action = 'update',
                data = response
            })
        else
            setOverlayState(true, response)
        end
    end)
end

RegisterNetEvent('codex_adminitemoverlay:client:toggle', function()
    if overlayOpen then
        setOverlayState(false)
        return
    end

    refreshOverlay()
end)

RegisterCommand(Config.Command, function()
    TriggerEvent('codex_adminitemoverlay:client:toggle')
end, false)

RegisterNetEvent('codex_adminitemoverlay:client:notify', function(payload)
    if not payload then
        return
    end

    QBCore.Functions.Notify(payload.message or 'Unbekannte Nachricht', payload.type or 'primary')

    if payload.type == 'success' then
        SendNUIMessage({
            action = 'saved',
            data = {
                message = payload.message or 'Gespeichert'
            }
        })
    end

    if payload.refresh and overlayOpen then
        refreshOverlay()
    end
end)

RegisterNetEvent('codex_adminitemoverlay:client:teleportToCoords', function(coords)
    teleportLocalPlayer(coords)
end)

-- Simple vehicle spawn handler: spawns model at player and warps into it
RegisterNetEvent('codex_adminitemoverlay:client:spawnVehicle', function(payload)
    local model = tostring(payload and payload.model or '')
    if model == '' then return end

    local hash = GetHashKey(model)
    RequestModel(hash)
    local tries = 0
    while not HasModelLoaded(hash) and tries < 100 do
        tries = tries + 1
        Wait(50)
    end

    if not HasModelLoaded(hash) then
        QBCore.Functions.Notify('Fahrzeugmodell konnte nicht geladen werden: ' .. model, 'error')
        return
    end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = CreateVehicle(hash, pos.x + 1.5, pos.y, pos.z, GetEntityHeading(ped), true, false)
    if vehicle and vehicle ~= 0 then
        SetVehicleNumberPlateText(vehicle, tostring(payload and payload.plate or 'ADMIN'))
        SetPedIntoVehicle(ped, vehicle, -1)
        SetEntityAsNoLongerNeeded(vehicle)
        SetModelAsNoLongerNeeded(hash)
        QBCore.Functions.Notify('Fahrzeug gespawnt: ' .. model, 'success')
    else
        QBCore.Functions.Notify('Fahrzeug konnte nicht gespawnt werden.', 'error')
    end
end)

-- Simple spectate: teleport admin to target and store previous position for restore
local spectateState = { active = false, savedCoords = nil }
RegisterNetEvent('codex_adminitemoverlay:client:spectate', function(targetServerId)
    local src = PlayerId()
    if spectateState.active then
        QBCore.Functions.Notify('Bereits im Spectate-Modus.', 'error')
        return
    end
    local targetServer = tonumber(targetServerId)
    if not targetServer then
        QBCore.Functions.Notify('Ungueltiger Spieler zum Spectaten.', 'error')
        return
    end

    local ped = PlayerPedId()
    spectateState.savedCoords = GetEntityCoords(ped)
    local targetIndex = GetPlayerFromServerId(targetServer)
    local targetPed = targetIndex and GetPlayerPed(targetIndex)
    if not targetIndex or targetPed == 0 then
        QBCore.Functions.Notify('Ziel-Ped konnte nicht gefunden werden.', 'error')
        return
    end

    local coords = GetEntityCoords(targetPed)
    teleportLocalPlayer({ x = coords.x, y = coords.y, z = coords.z + 1.0 })
    SetEntityInvincible(ped, true)
    SetEntityVisible(ped, false, false)
    spectateState.active = true
    QBCore.Functions.Notify('Spectate-Modus aktiviert.', 'primary')
end)

RegisterNetEvent('codex_adminitemoverlay:client:unspectate', function()
    local ped = PlayerPedId()
    if not spectateState.active then
        QBCore.Functions.Notify('Nicht im Spectate-Modus.', 'error')
        return
    end

    if spectateState.savedCoords then
        teleportLocalPlayer({ x = spectateState.savedCoords.x, y = spectateState.savedCoords.y, z = spectateState.savedCoords.z })
    end

    SetEntityInvincible(ped, false)
    SetEntityVisible(ped, true, false)
    spectateState.active = false
    spectateState.savedCoords = nil
    QBCore.Functions.Notify('Spectate-Modus beendet.', 'success')
end)

RegisterNUICallback('close', function(_, cb)
    setOverlayState(false)
    cb({ ok = true })
end)

RegisterNUICallback('refresh', function(_, cb)
    refreshOverlay()
    cb({ ok = true })
end)

RegisterNUICallback('giveItem', function(data, cb)
    TriggerServerEvent('codex_adminitemoverlay:server:giveItem', data)
    cb({ ok = true })
end)

RegisterNUICallback('createItem', function(data, cb)
    QBCore.Functions.TriggerCallback('codex_adminitemoverlay:server:createItem', function(response)
        if response and response.message then
            QBCore.Functions.Notify(response.message, response.type or 'primary')

            if response.type == 'success' then
                SendNUIMessage({
                    action = 'saved',
                    data = {
                        message = response.message
                    }
                })
            end

            if response.refresh and overlayOpen then
                refreshOverlay()
            end
        end

        cb(response or { ok = false })
    end, data)
end)

RegisterNUICallback('deleteItem', function(data, cb)
    QBCore.Functions.TriggerCallback('codex_adminitemoverlay:server:deleteItem', function(response)
        if response and response.message then
            QBCore.Functions.Notify(response.message, response.type or 'primary')

            if response.type == 'success' then
                SendNUIMessage({
                    action = 'saved',
                    data = {
                        message = response.message
                    }
                })
            end

            if response.refresh and overlayOpen then
                refreshOverlay()
            end
        end

        cb(response or { ok = false })
    end, data)
end)

RegisterNUICallback('saveRecipe', function(data, cb)
    QBCore.Functions.TriggerCallback('codex_adminitemoverlay:server:saveRecipe', function(response)
        if response and response.message then
            QBCore.Functions.Notify(response.message, response.type or 'primary')

            if response.type == 'success' then
                SendNUIMessage({
                    action = 'saved',
                    data = {
                        message = response.message
                    }
                })
            end

            if response.refresh and overlayOpen then
                refreshOverlay()
            end
        end

        cb(response or { ok = false })
    end, data)
end)

RegisterNUICallback('deleteRecipe', function(data, cb)
    QBCore.Functions.TriggerCallback('codex_adminitemoverlay:server:deleteRecipe', function(response)
        if response and response.message then
            QBCore.Functions.Notify(response.message, response.type or 'primary')

            if response.type == 'success' then
                SendNUIMessage({
                    action = 'saved',
                    data = {
                        message = response.message
                    }
                })
            end

            if response.refresh and overlayOpen then
                refreshOverlay()
            end
        end

        cb(response or { ok = false })
    end, data)
end)

RegisterNUICallback('saveShopProduct', function(data, cb)
    TriggerServerEvent('codex_adminitemoverlay:server:saveShopProduct', data)
    cb({ ok = true })
end)

RegisterNUICallback('deleteShopProduct', function(data, cb)
    TriggerServerEvent('codex_adminitemoverlay:server:deleteShopProduct', data)
    cb({ ok = true })
end)

RegisterNUICallback('resetShopOverrides', function(data, cb)
    TriggerServerEvent('codex_adminitemoverlay:server:resetShopOverrides', data)
    cb({ ok = true })
end)

RegisterNUICallback('createShop', function(data, cb)
    TriggerServerEvent('codex_adminitemoverlay:server:createShop', data)
    cb({ ok = true })
end)

RegisterNUICallback('shopAction', function(data, cb)
    QBCore.Functions.TriggerCallback('codex_adminitemoverlay:server:shopAction', function(response)
        if response and response.teleport and type(response.teleport) == 'table' then
            local teleported = teleportLocalPlayer(response.teleport)
            if teleported then
                QBCore.Functions.Notify(response.message or 'Teleportiert', 'success')
                SendNUIMessage({
                    action = 'saved',
                    data = {
                        message = response.message or 'Teleportiert'
                    }
                })
            else
                QBCore.Functions.Notify('Teleport fehlgeschlagen.', 'error')
            end
        end

        if response and response.message and not response.teleport then
            QBCore.Functions.Notify(response.message, response.type or 'primary')

            if response.type == 'success' then
                SendNUIMessage({
                    action = 'saved',
                    data = {
                        message = response.message
                    }
                })
            end

            if response.refresh and overlayOpen then
                refreshOverlay()
            end
        end

        cb(response or { ok = false })
    end, data)
end)

RegisterNUICallback('teleportShop', function(data, cb)
    local coords = data and data.coords
    local message = data and data.message or 'Teleportiert'
    local teleported = teleportLocalPlayer(coords)

    if teleported then
        QBCore.Functions.Notify(message, 'success')
        SendNUIMessage({
            action = 'saved',
            data = {
                message = message
            }
        })
        cb({ ok = true, teleported = true, message = message })
        return
    end

    QBCore.Functions.Notify('Teleport fehlgeschlagen.', 'error')
    cb({ ok = false, message = 'Teleport fehlgeschlagen.' })
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    TriggerServerEvent('codex_adminitemoverlay:server:spawnVehicle', data)
    cb({ ok = true })
end)

RegisterNUICallback('spectatePlayer', function(data, cb)
    TriggerServerEvent('codex_adminitemoverlay:server:spectatePlayer', { targetId = data and data.targetId })
    cb({ ok = true })
end)

RegisterNUICallback('unspectatePlayer', function(_, cb)
    TriggerServerEvent('codex_adminitemoverlay:server:unspectatePlayer')
    cb({ ok = true })
end)

RegisterNUICallback('getPlayerInventory', function(data, cb)
    QBCore.Functions.TriggerCallback('codex_adminitemoverlay:server:getPlayerInventory', function(response)
        cb(response or { ok = false })
    end, data and data.targetId)
end)

RegisterNUICallback('moveShopNpc', function(data, cb)
    TriggerServerEvent('codex_adminitemoverlay:server:moveShopNpc', data)
    cb({ ok = true })
end)

RegisterNUICallback('deleteShopNpc', function(data, cb)
    TriggerServerEvent('codex_adminitemoverlay:server:deleteShopNpc', data)
    cb({ ok = true })
end)

RegisterNUICallback('playerAction', function(data, cb)
    QBCore.Functions.TriggerCallback('codex_adminitemoverlay:server:playerAction', function(response)
        if response and response.message then
            QBCore.Functions.Notify(response.message, response.type or 'primary')

            if response.type == 'success' then
                SendNUIMessage({
                    action = 'saved',
                    data = {
                        message = response.message
                    }
                })
            end

            if response.refresh and overlayOpen then
                refreshOverlay()
            end
        end

        cb(response or { ok = false })
    end, data)
end)

RegisterNUICallback('propAction', function(data, cb)
    QBCore.Functions.TriggerCallback('codex_adminitemoverlay:server:propAction', function(response)
        if response and response.message then
            QBCore.Functions.Notify(response.message, response.type or 'primary')

            if response.type == 'success' then
                SendNUIMessage({
                    action = 'saved',
                    data = {
                        message = response.message
                    }
                })
            end

            if response.refresh and overlayOpen then
                refreshOverlay()
            end
        end

        cb(response or { ok = false })
    end, data)
end)

CreateThread(function()
    while true do
        if overlayOpen then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 14, true)
            DisableControlAction(0, 15, true)
            DisableControlAction(0, 16, true)
            DisableControlAction(0, 17, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 45, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 265, true)
            Wait(0)
        else
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            Wait(500)
        end
    end
end)
