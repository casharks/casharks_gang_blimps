local currentZone = nil
local showMessage = false
local lastMessageTime = 0

function DrawTopNotification(text)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.5, 0.05)
end

Citizen.CreateThread(function()
    -- Create blips
    for _, blimp in pairs(Config.Blimps) do
        local blip = AddBlipForCoord(blimp.coords)
        SetBlipSprite(blip, blimp.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, blimp.scale or 0.8)
        SetBlipColour(blip, blimp.color or 1)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blimp.name .. " Block")
        EndTextCommandSetBlipName(blip)
    end

    -- Zone detection
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local foundZone = nil

        for _, blimp in pairs(Config.Blimps) do
            local distance = #(playerCoords - blimp.coords)
            if distance <= blimp.radius then
                foundZone = blimp
                break
            end
        end

        if foundZone and currentZone ~= foundZone.name then
            currentZone = foundZone.name
            showMessage = true
            lastMessageTime = GetGameTimer()
        elseif not foundZone then
            currentZone = nil
        end

        sleep = 500
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if showMessage and GetGameTimer() - lastMessageTime < 5000 then
            if currentZone then
                DrawTopNotification("~l~You have entered ~r~" .. currentZone .. " block")
            else
                DrawTopNotification("~l~You have entered a ~r~gang block")
            end
        end
    end
end)

