lib.versionCheck('s4t4n667/s4t4n667_cinematicbars')
lib.locale()
local config = lib.require('config')

local playerCooldowns = {}
local cooldownTime = config.cooldown
local webhookURL = config.webhookURL
local sendToDiscord = nil

lib.addCommand(config.command, {
    help = locale('command_help'),
    restricted = false,
}, function(source)
    local now = os.time()
    local lastUse = playerCooldowns[source]

    if lastUse and (now - lastUse) < cooldownTime then
        TriggerClientEvent('ox_lib:notify', source, {
            title = locale('notify_title'),
            description = locale('cooldown_notify', cooldownTime - (now - lastUse)),
            type = 'error',
        })
        return
    end

    playerCooldowns[source] = now

    TriggerClientEvent('cinematic:toggle', source)
    sendToDiscord(locale('log_used_title'), locale('log_used_message', GetPlayerName(source), source, config.command), 0x00FF00)
end)

AddEventHandler('playerDropped', function()
    playerCooldowns[source] = nil
end)

function sendToDiscord(title, message, color)
    if not webhookURL or webhookURL == '' then return end

    PerformHttpRequest(webhookURL, function() end, 'POST', json.encode({
        username = locale('log_username'),
        embeds = {{
            title = title,
            description = message,
            color = color or 16777215,
            footer = { text = 's4t4n667_cinematicbars | Asgaard Developments' },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        }},
    }), { ['Content-Type'] = 'application/json' })
end
