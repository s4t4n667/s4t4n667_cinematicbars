local config = lib.require('config')
lib.locale()

local camActive = false
local camMoving = false
local camHeight = 0.0
local drawing = false

local thicknessOptions = {
    { value = '0.05', label = locale('thickness_thin') },
    { value = '0.10', label = locale('thickness_medium') },
    { value = '0.20', label = locale('thickness_thick') },
    { value = '0.30', label = locale('thickness_extra_thick') },
}

local function setHudVisible(visible)
    DisplayRadar(visible)

    if GetResourceState('jg-hud') == 'started' then
        exports['jg-hud']:toggleHud(visible)
        exports['jg-hud']:toggleVehicleControl(visible)
    elseif GetResourceState('0r-hud-v3') == 'started' then
        exports['0r-hud-v3']:ToggleVisible(visible)
    elseif GetResourceState('otherhud') == 'started' then
        -- custom export
    end
end

local function startDrawLoop()
    if drawing then return end
    drawing = true

    CreateThread(function()
        while camActive or camMoving do
            DrawRect(0.5, camHeight / 2.0, 1.0, camHeight, 0, 0, 0, 255)
            DrawRect(0.5, 1.0 - camHeight / 2.0, 1.0, camHeight, 0, 0, 0, 255)
            Wait(0)
        end
        drawing = false
    end)
end

local function slideOut()
    CreateThread(function()
        for i = camHeight, 0.0, -0.01 do
            camHeight = i
            Wait(10)
        end

        camHeight = 0.0
        camMoving = false
    end)
end

local function promptBarThickness()
    local input = lib.inputDialog(locale('menu_title'), {{
        type = 'select',
        label = locale('bar_thickness'),
        options = thicknessOptions,
        required = true,
    }})

    return input and tonumber(input[1])
end

local function toggleCinematic(forceOff)
    if IsPauseMenuActive() or camMoving then return end

    if camActive then
        camActive = false
        camMoving = true
        setHudVisible(true)
        slideOut()
    elseif not forceOff then
        local value = promptBarThickness()
        if not value or camActive or camMoving then return end
        camHeight = value
        camActive = true
        setHudVisible(false)
        startDrawLoop()
    end
end

RegisterNetEvent('cinematic:toggle', function()
    toggleCinematic(false)
end)

RegisterNetEvent('cinematic:forceOff', function()
    toggleCinematic(true)
end)
