local laneutil = require "laneutil"
local paramsutil = require "paramsutil"
local func = require "func"
local coor = require "coor"
local trackEdge = require "trackedge"
local station = require "stationlib"
local dump = require "datadumper"

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


local function makeStreet(edges)
    
    return
        {
            type = "STREET",
            params =
            {
                type = "station_new_small.lua",
                tramTrackType = "NO"
            },
            edges = edges,
            snapNodes = {1}
        }
end

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
            key = "trackTypeCatenary",
            name = _("Track Type & Catenary"),
            values = {_("Normal"), _("Elec."), _("Elec.Hi-Speed"), _("Hi-Speed")},
            defaultIndex = 1
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
            key = "angle",
            name = _("Cross angle") .. "(°)",
            values = func.map(angleList, tostring)
        },
        {
            key = "mirrored",
            name = _("Mirrored Underground Level"),
            values = {_("No"), _("Yes")}
        },
        {
            key = "strConnection",
            name = _("Street Connection"),
            values = {_("1"), _("2"), _("1 Mini"), _("2 Minis")}
        },
    }
end



local function makeUpdateFn(config)
    local function platformPatterns(config)
        local basicPattern = {config.platformRepeat, config.platformDwlink}
        local basicPatternR = {config.platformDwlink, config.platformRepeat}
        
        return function(n)
            local ret = (n > 2) and (func.mapFlatten(func.seq(1, n * 0.5), function(i) return basicPatternR end)) or basicPattern
            ret[1] = config.platformStart
            if (n > 2) then ret[#ret] = config.platformEnd end
            return ret
        end
    end
    
    local roofPatterns = function(n)
        local roofs = func.seqMap({1, n}, function(_) return config.platformRoofRepeat end)
        if (n > 2) then
            roofs[1] = config.platformRoofStart
            roofs[n] = config.platformRoofEnd
        end
        return roofs
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
            local height = -15
            local strConn = params.strConnection + 1
            
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
            
            
            local xOffsets0 = ofGroup(xOffsets, 0)
            local uOffsets0 = ofGroup(uOffsets, 0)
            
            local house = config.surface.house[#uOffsets0 > 4 and 3 or math.ceil(#uOffsets0 * 0.5)]
            
            local platformsS, platformsU, roofs =
                station.makePlatforms(ofGroup(uOffsets, 0), platformsSF),
                station.makePlatforms(ofGroup(uOffsets, 1), platformsUG),
                station.makePlatforms(func.range(uOffsets0, 2, #uOffsets0), roofPatterns(nSeg))
            
            local makeEntry = function()
                if (strConn < 3) then
                    local yHouse = ({15, 25, 30})[#uOffsets0 > 4 and 3 or math.ceil(#uOffsets0 * 0.5)]
                    platformsS[math.ceil(nSeg * 0.5)].id = config.surface.platformFstRepeat
                    platformsS[math.ceil(nSeg * 0.5 + 1)].id = config.surface.platformFstRepeat
                    return
                        {newModel(house, coor.rotZ(math.pi * 1.5), coor.transX(-5.5))},
                        makeStreet({
                            {{-5.5 - 10, 0, 0}, {-10, 0, 0}},
                            {{-5.5 - 30, 0, 0}, {-10, 0, 0}}
                        }),
                        {
                            {0, yHouse, 0},
                            {-15.5, yHouse, 0},
                            {-15.5, -yHouse, 0},
                            {0, -yHouse, 0},
                        }
                else
                    func.forEach(station.makePlatforms({uOffsets[1]}, roofPatterns(nSeg)), func.bind(table.insert, roofs))
                    return
                        {newModel(config.staires, coor.transX(0.5 * station.trackWidth), coor.rotZ(math.pi))},
                        makeStreet({
                            {{4 - 10, 0, 0}, {-10, 0, 0}},
                            {{4 - 30, 0, 0}, {-10, 0, 0}}
                        }),
                        {
                            {0, 6, 0},
                            {-6, 6, 0},
                            {-6, -6, 0},
                            {0, -6, 0},
                        }
                end
            end
            
            local makeEntry2 = function()
                if (strConn == 2 or strConn == 4) then
                    if (xOffsets0[#xOffsets0].x > uOffsets0[#uOffsets0].x) then
                        local xRef = xOffsets0[#xOffsets0].x
                        return
                            {newModel(config.stairesPlatform, coor.transX(xRef + station.trackWidth)),
                                newModel(config.staires, coor.transX(xRef + 0.5 + station.trackWidth))},
                            makeStreet({
                                {{xRef + 9, 0, 0}, {10, 0, 0}},
                                {{xRef + 29, 0, 0}, {10, 0, 0}}
                            }),
                            {
                                {xRef, -12, 0},
                                {xRef + 9, -12, 0},
                                {xRef + 9, 12, 0},
                                {xRef, 12, 0}
                            }
                    else
                        local xRef = uOffsets0[#uOffsets0].x
                        return
                            {newModel(config.staires, coor.transX(xRef + 0.5 * station.trackWidth))},
                            makeStreet({
                                {{xRef + 6, 0, 0}, {10, 0, 0}},
                                {{xRef + 26, 0, 0}, {10, 0, 0}}
                            })
                            ,{
                                {xRef, -6, 0},
                                {xRef + 6, -6, 0},
                                {xRef + 6, 6, 0},
                                {xRef, 6, 0}
                            }
                    end
                else
                    return {}, nil, nil
                end
            end
            
            local entry, str, fE = makeEntry()
            local entry2, str2, fE2 = makeEntry2()
            
            result.models = func.flatten({
                platformsS, platformsU, roofs,
                entry, entry2
            }
            )
            result.edgeLists = {
                trackEdge.normal(catenary, trackType, true, snapRule)(sfTracks),
                trackEdge.tunnel(catenary, trackType, snapRule)(ugTracks),
                -- makeTram(snapRule)(tramTrack),
                trackEdge.tunnel(false, "zzz_mock.lua", station.noSnap)(mockTracks),
                str, str2
            
            }
            
            result.terminalGroups = station.makeTerminals(xuIndex)
            
            local totalWidth = station.trackWidth * #ofGroup(xOffsets, 0) + station.platformWidth * #ofGroup(uOffsets, 0)
            
            local xMin = -0.5 * station.platformWidth
            local xMax = xMin + totalWidth
            local yMin = -0.5 * length
            local yMax = 0.5 * length
            
            local faces = {
                {
                    {xMin, yMin, 0},
                    {xMax, yMin, 0},
                    {xMax, yMax, 0},
                    {xMin, yMax, 0}
                }, fE, fE2
            }
            
            result.terrainAlignmentLists = {
                {
                    type = "EQUAL",
                    faces = faces
                },
            }
            
            
            result.groundFaces =
                func.mapFlatten(faces, function(f) return {
                    {face = f, modes = {{type = "FILL", key = "industry_gravel_small_01"}}},
                    {face = f, modes = {{type = "STROKE_OUTER", key = "building_paving"}}}
                } end)
            
            
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
