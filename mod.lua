-- local function modelCallback(fileName, data)
-- 	if data.metadata.cost then
-- 		data.metadata.cost.price = 0.0
-- 	end

-- 	if data.metadata.maintenance then
-- 		data.metadata.maintenance.runningCosts = 0.0
-- 	end

-- 	return data
-- end

function data()
    return {
        info = {
            minorVersion = 0,
            severityAdd = "NONE",
            severityRemove = "CRITICAL",
            name = _("name"),
            description = _("desc"),
            authors = {
                {
                    name = "Enzojz",
                    role = "CREATOR",
                    text = "Idee, Scripting",
                    steamProfile = "enzojz",
                    tfnetId = 27218,
                },
            },
            tags = {"Train Station", "Underground Station", "Passenger Station", "Station", "Cross Station", "Tram Station"},
        },
	-- runFn = function (settings)
	-- 	addModifier("loadModel", modelCallback)
	-- 	addModifier("loadStreet", costCallback)
	-- 	addModifier("loadTrack", costCallback)
	-- 	addModifier("loadBridge", costCallback)
	-- 	addModifier("loadTunnel", costCallback)
	-- 	addModifier("loadRailroadCrossing", costCallback)
	-- 	addModifier("loadConstruction", constructionCallback)

	-- 	local costs = table.copy(game.config.costs)

	-- 	for k, v in pairs(costs) do
	-- 		game.config.costs[k] = 0.0
	-- 	end
	-- end
    }
end
