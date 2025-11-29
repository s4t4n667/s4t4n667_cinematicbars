local config = lib.require('config')

local CAM_HEIGHT = 0.15 
local camActive = false
local camMoving = false
local camHeight = 0.0

local function handleCinematicAnim()
    camMoving = true
    DisplayRadar(not camActive)

    if GetResourceState("jg-hud") == "started" then
        exports["jg-hud"]:toggleHud(not camActive)
        exports["jg-hud"]:toggleVehicleControl(not camActive)
    elseif GetResourceState("0r-hud-v3") == "started" then
        exports['0r-hud-v3']:ToggleVisible(not camActive)
    elseif GetResourceState("otherhud") == "started" then
        -- custom export
    else
        print("No HUD detected!")
    end

    local target = camActive and CAM_HEIGHT or 0.0
    local step = camActive and 0.01 or -0.01

    for i = camHeight, target, step do
        camHeight = i
        Wait(10)
    end

    camHeight = target 
    camMoving = false
end

CreateThread(function()
    while true do
        Wait(0)
        if camActive or camMoving then
            DrawRect(0.5, camHeight / 2.0, 1.0, camHeight, 0, 0, 0, 255)
            DrawRect(0.5, 1.0 - camHeight / 2.0, 1.0, camHeight, 0, 0, 0, 255)
        end
    end
end)

local function promptBarThickness()
    local options = {
        { value = 0.05, label = 'Thin' },
        { value = 0.10, label = 'Medium' },
        { value = 0.20, label = 'Thick' },
        { value = 0.30, label = 'Extra Thick' }
    }

    local input = lib.inputDialog(config.menuTitle, {{
        type = 'select',
        label = 'Bar Thickness',
        options = options,
        default = tostring(CAM_HEIGHT)
    }})

    return input and tonumber(input[1])
end

local function toggleCinematic(forceOff)
    if IsPauseMenuActive() or camMoving then return end

    if forceOff then
        if not camActive then return end
        camActive = false
    else
        if not camActive then
            local value = promptBarThickness()
            if not value then return end
            CAM_HEIGHT = value
        end
        camActive = not camActive
    end

    CreateThread(handleCinematicAnim)
end

RegisterNetEvent('cinematic:toggle', function()
    toggleCinematic(false)
end)

RegisterNetEvent('cinematic:forceOff', function()
    toggleCinematic(true)
end)