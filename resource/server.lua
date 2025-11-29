local config = lib.require('config')

local COOLDOWN_TIME = config.cooldown -- seconds
local playerCooldowns = {}

local WEBHOOK_URL = config.webhookURL

local function sendToDiscord(title, message, color)
    local embed = {
        {
            title = title,
            description = message,
            color = color or 16777215,
            footer = {
                text = "s4t4n667_cinematicbars | Asgaard Developments"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(WEBHOOK_URL, function(err, text, headers) 

    end, "POST", json.encode({
        username = "Cinematic Bars",
        embeds = embed
    }), { ["Content-Type"] = "application/json" })
end

lib.addCommand(config.command, {
    help = 'Toggle cinematic bars with customizable thickness.',
    restricted = false
}, function(source)
    local player = source
    local now = os.time()
    local name = GetPlayerName(player)

    local lastUse = playerCooldowns[player]
    if lastUse and (now - lastUse) < COOLDOWN_TIME then
        local remaining = COOLDOWN_TIME - (now - lastUse)

        local cooldownMessage = ("Player: **%s** (ID: %d) attempted to use /cinematic but is on cooldown (%d seconds left).")
            :format(name, player, remaining)

        sendToDiscord("Cinematic Command (Cooldown Blocked)", cooldownMessage, 0xFF0000) -- red

        TriggerClientEvent('ox_lib:notify', player, {
            title = 'Cinematic Mode',
            description = ('Please wait %d more seconds before using this again.'):format(remaining),
            iconColor = '#76A9D2',
            type = 'error'
        })
        return
    end

    playerCooldowns[player] = now

    TriggerClientEvent('cinematic:toggle', player)

    local successMessage = ("Player: **%s** (ID: %d) toggled cinematic mode."):format(name, player)
    sendToDiscord("Cinematic Command Used", successMessage, 0x00FF00) -- green
end)


AddEventHandler('playerDropped', function()
    playerCooldowns[source] = nil
end)