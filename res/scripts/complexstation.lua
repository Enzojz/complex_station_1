local laneutil = require "laneutil"
local paramsutil = require "paramsutil"
local func = require "func"
local coor = require "coor"
local trackEdge = require "trackedge"
local station = require "stationlib"

local platformSegments = {2, 4, 8, 12, 16, 20, 24}
local angleList = {0, 15, 30, 45, 60, 75, 90}
local nbTracksLevelList = {2, 3, 4, 5, 6, 7, 8, 10, 12}
local offsetX = {0, 1, 2, 4, 6, 8, 10, 12}
local offsetY = {0, 0.25, 0.5, 0.75, 1}

local newModel = function(m, ...)
    return {
        id = m,
        transf = coor.mul(...)
    }
end

local snapRule = function(e) return func.filter(func.seq(0, #e - 1), function(e) return e % 4 == 0 or (e - 3) % 4 == 0 end) end

local function params()
    return {
        {
            key = "nbTracksSf",
            name = _("Ground Level: Number of tracks"),
            values = func.map(nbTracksLevelList, tostring),
        },
        {
            key = "nbTracksUG",
            name = _("Underground Level: Number of tracks"),
            values = func.map(nbTracksLevelList, tostring),
        },
        {
            key = "length",
            name = _("Platform length") .. "(m)",
            values = func.map(platformSegments, function(l) return _(tostring(l * station.segmentLength)) end),
            defaultIndex = 2
        },
        -- {
        --     key = "offsetX",
        --     name = _("Lateral Offset"),
        --     value = func.map(offsetX, tostring),
        -- },
        -- {
        --     key = "offsetY",
        --     name = _("Medial Offset"),
        --     value = func.map(offsetY, tostring),
        -- },
        {
            key = "trackTypeCatenary",
            name = _("Track Type & Catenary"),
            values = {_("Normal"), _("Elec."), _("Elec.Hi-Speed"), _("Hi-Speed")},
            defaultIndex = 1
        },
        {
            key = "angle",
            name = _("Cross angle") .. "(°)",
            values = func.map(angleList, tostring)
        },
        {
            
            key = "mirrored",
            name = _("Mirrored Underground Level"),
            values = {_("No"), _("Yes")}
        },
    }
end



local function makeUpdateFn(config)
    
    local basicPattern = {config.platformRepeat, config.platformDwlink}
    local basicPatternR = {config.platformDwlink, config.platformRepeat}
    local platformPatterns = function(n)
        return (n > 2) and (func.mapFlatten(func.seq(1, n * 0.5), function(i) return basicPatternR end)) or basicPattern end
    local stationHouse = config.stationHouse
    local staires = config.staires
    
    return function(params)
            
            local result = {}
            
            local trackType = ({"standard.lua", "standard.lua", "high_speed.lua", "high_speed.lua"})[params.trackTypeCatenary + 1]
            local catenary = (params.trackTypeCatenary == 1) or (params.trackTypeCatenary == 2)
            local nSeg = platformSegments[params.length + 1]
            local length = nSeg * segmentLength
            local nbTracksSf = nbTracksLevelList[params.nbTracksSf + 1]
            local nbTracksUG = nbTracksLevelList[params.nbTracksUG + 1]
            local height = -10
            
            local levels = {
                {
                    mz = coor.I(),
                    mr = coor.I(),
                    mdr = coor.I(),
                    nbTracks = nbTracksSf,
                    baseX = 0,
                    id = 0
                },
                {
                    mz = coor.transZ(height),
                    mr = coor.I(),
                    mdr = coor.I(),
                    nbTracks = nbTracksUG,
                    baseX = 0,
                    id = 1
                }
            }
            
            local platforms = platformPatterns(nSeg)
            local xOffsets, uOffsets, xuIndex = station.buildCoors(nSeg)(levels, {}, {}, {}, {})
            
            local sfTracks = station.generateTrackGroups(func.filter(xOffsets, function(xOffset) return xOffset.id == 0 end), length)
            local ugTracks = station.generateTrackGroups(func.filter(xOffsets, function(xOffset) return xOffset.id == 1 end), length)
            local mockTracks = station.generateTrackGroups(func.filter(uOffsets, function(xOffset) return xOffset.id == 1 end), length)
            
            result.edgeLists = {
                trackEdge.normal(catenary, trackType, true, station.noSnap)(sfTracks),
                trackEdge.tunnel(catenary, trackType, station.noSnap)(ugTracks),
                trackEdge.tunnel(false, "zzz_mock.lua", station.noSnap)(mockTracks)
            }
            
            result.models = station.makePlatforms(uOffsets, platforms)
            result.terminalGroups = station.makeTerminals(xuIndex)
            
            result.groundFaces = {}
            result.terrainAlignmentLists = {
                {
                    type = "EQUAL",
                    faces = {},
                },
            
            }
            
            -- func.forEach(entryLocations, func.bind(addEntry, result, tramTrack))
            result.cost = 120000 + (nbTracksSf + nbTracksUG) * 24000
            result.maintenanceCost = result.cost / 6
            
            return result
    end
end


local mlugstation = {
    makeUpdateFn = function(config)
        return function()
            return {
                type = "RAIL_STATION",
                description = {
                    name = _("Underground / Multi-level Passenger Station"),
                    description = _("An underground / multi-level passenger station")
                },
                availability = config.availability,
                order = config.order,
                soundConfig = config.soundConfig,
                params = params(),
                updateFn = makeUpdateFn(config)
            }
        end
    end
}

return mlugstation
