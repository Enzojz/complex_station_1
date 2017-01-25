local laneutil = require "laneutil"
local paramsutil = require "paramsutil"
local func = require "func"
local coor = require "coor"
local trackEdge = require "trackedge"
local station = require "stationlib"

local platformSegments = {2, 4, 8, 12, 16, 20, 24}
local angleList = {0, 15, 30, 45, 60, 75, 90}
local nbTracksLevelList = {2, 3, 4, 5, 6, 7, 8, 10, 12}
local offsetLat = {0, 1, 2, 4, 6, 8, 10, 12}
local offsetMed = {0, 0.25, 0.5, 0.75, 1}

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
        {
            key = "offsetLat",
            name = _("Lateral Offset"),
            values = func.map(offsetLat, tostring),
        },
        {
            key = "offsetMed",
            name = _("Medial Offset"),
            values = func.map(offsetMed, tostring),
        },
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
    local function platformPatterns(config)
        local basicPattern = {config.platformRepeat, config.platformDwlink}
        local basicPatternR = {config.platformDwlink, config.platformRepeat}
        
        return function(n)
            return (n > 2) and (func.mapFlatten(func.seq(1, n * 0.5), function(i) return basicPatternR end)) or basicPattern end
    end
    local stationHouse = config.stationHouse
    local staires = config.staires
    
    return function(params)
            
            local result = {}
            
            local trackType = ({"standard.lua", "standard.lua", "high_speed.lua", "high_speed.lua"})[params.trackTypeCatenary + 1]
            local catenary = (params.trackTypeCatenary == 1) or (params.trackTypeCatenary == 2)
            local nSeg = platformSegments[params.length + 1]
            local length = nSeg * station.segmentLength
            local nbTracksSf = nbTracksLevelList[params.nbTracksSf + 1]
            local nbTracksUG = nbTracksLevelList[params.nbTracksUG + 1]
            local height = -10
            
            local offsetX = offsetLat[params.offsetLat + 1] * station.trackWidth
            local offsetY = offsetMed[params.offsetMed + 1] * length

            local levels = {
                {
                    mz = coor.I(),
                    mr = coor.I(),
                    mdr = coor.I(),
                    nbTracks = nbTracksSf,
                    baseX = 0,
                    ignoreFst = false,
                    ignoreLst = false,
                    id = 0
                },
                {
                    mz = coor.transZ(height),
                    mr = coor.I(),
                    mdr = coor.mul(coor.transX(offsetX), coor.transY(offsetY)),
                    nbTracks = nbTracksUG,
                    baseX = 0,
                    ignoreFst = true,
                    ignoreLst = true,
                    id = 1
                },
            -- {
            --     mz = coor.I(),
            --     mr = coor.I(),
            --     mdr = coor.I(),
            --     nbTracks = 1,
            --     baseX = -15,
            --     id = 2,
            --     ignoreFst = false,
            --     ignoreLst = false,
            -- }
            }
            
            local ofGroup = function(offsets, id) return func.filter(offsets, function(xOffset) return xOffset.id == id end) end
            
            local platformsUG = platformPatterns(config.underground)(nSeg)
            local platformsSF = platformPatterns(config.surface)(nSeg)
            local xOffsets, uOffsets, xuIndex = station.buildCoors(nSeg, true)(levels, {}, {}, {}, {})
            
            local sfTracks = station.generateTrackGroups(ofGroup(xOffsets, 0), length)
            local ugTracks = station.generateTrackGroups(ofGroup(xOffsets, 1), length)
            local mockTracks = station.generateTrackGroups(ofGroup(uOffsets, 1), length)
            
            -- local tramTrack = coor.applyEdges(coor.flipY(), coor.flipY())(station.generateTrackGroups(ofGroup(xOffsets, 2), length))
            local function makeTram(snapNodeRule)
                return function(edges)
                    return {
                        type = "STREET",
                        -- edgeType = "TUNNEL",
                        -- edgeTypeName = "railroad_old.lua",
                        params = {
                            type = "z_tram_track.lua",
                            tramTrackType = "ELECTRIC"
                        },
                        edges = edges,
                        snapNodes = snapNodeRule(edges),
                    }
                end
            end
                        
            result.edgeLists = {
                trackEdge.normal(catenary, trackType, true, snapRule)(sfTracks),
                trackEdge.tunnel(catenary, trackType, snapRule)(ugTracks),
                -- makeTram(snapRule)(tramTrack),
                trackEdge.tunnel(false, "zzz_mock.lua", station.noSnap)(mockTracks),
            
            }
            
            result.models = func.flatten({
                station.makePlatforms(ofGroup(uOffsets, 0), platformsSF),
                station.makePlatforms(ofGroup(uOffsets, 1), platformsUG),
            }
            )
            result.terminalGroups = station.makeTerminals(xuIndex)
            
            local totalWidth = station.trackWidth * #(ofGroup(xOffsets, 0)) + station.platformWidth * #(ofGroup(uOffsets, 0))

            local xMin = -0.5 * station.platformWidth
            local xMax = xMin + totalWidth
            local yMin = -0.5 * length
            local yMax = 0.5 * length

            result.groundFaces = {}
            result.terrainAlignmentLists = {
                {
                    type = "EQUAL",
                    faces = {
                        {
                            {xMin, yMin, 0},
                            {xMax, yMin, 0},
                            {xMax, yMax, 0},
                            {xMin, yMax, 0}
                        }
                    },
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
