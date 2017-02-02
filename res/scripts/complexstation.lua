local laneutil = require "laneutil"
local paramsutil = require "paramsutil"
local func = require "func"
local coor = require "coor"
local trackEdge = require "trackedge"
local station = require "stationlib"

local dump = require "datadumper"

local platformSegments = {2, 4, 8, 12, 16, 20, 24}
local angleList = {-60, -30, -45, 0, 30, 45, 60, 90}
local nbTracksLevelList = {2, 3, 4, 5, 6, 7, 8, 10, 12}
local offsetLat = {0, 1, 2, 3, 4, 6, 8, 10, 12, 13}
local offsetMed = {-12, -6, -4, -2, 0, 2, 4, 6, 12}

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

local function paramsTram()
    return {
        {
            key = "nbTracksSf",
            name = _("Ground Level: Number of tracks"),
            values = func.map(nbTracksLevelList, tostring),
        },
        {
            key = "length",
            name = _("Platform length") .. "(m)",
            values = func.map(platformSegments, function(l) return tostring(l * station.segmentLength) end),
            defaultIndex = 2
        },
        paramsutil.makeTrackTypeParam(),
        paramsutil.makeTrackCatenaryParam(),
        {
            key = "strConnection",
            name = _("Street Connection"),
            values = {_("1"), _("2"), _("1 Mini"), _("2 Minis")},
            defaultIndex = 0
        },
        paramsutil.makeTramTrackParam1(),
        paramsutil.makeTramTrackParam2()
    }
end

local function paramsUG()
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
            values = func.map(platformSegments, function(l) return tostring(l * station.segmentLength) end),
            defaultIndex = 2
        },
        {
            key = "trackTypeCatenary",
            name = _("Track Type & Catenary"),
            values = {_("Normal"), _("Elec.")},
            yearFrom = 1910,
            yearTo = 1925,
            defaultIndex = 1
        },
        {
            key = "trackTypeCatenary",
            name = _("Track Type & Catenary"),
            values = {_("Normal"), _("Elec."), _("Elec.Hi-Speed"), _("Hi-Speed")},
            yearFrom = 1925,
            yearTo = 0,
            defaultIndex = 1
        },
        {
            key = "strConnection",
            name = _("Street Connection"),
            values = {_("1"), _("2"), _("1 Mini"), _("2 Minis")},
            defaultIndex = 0
        },
        paramsutil.makeTramTrackParam1(),
        paramsutil.makeTramTrackParam2(),
        {
            key = "offsetLat",
            name = _("U Level Lateral Offset") .. "(m)",
            values = func.map(offsetLat, function(o) return tostring(math.floor(o * 7.5)) end),
            defaultIndex = 0
        },
        {
            key = "offsetMed",
            name = _("U Level Medial Offset") .. "(m)",
            values = func.map(offsetMed, function(o) return tostring(math.floor(o * station.segmentLength)) end),
            defaultIndex = 4
        },
        {
            key = "angle",
            name = _("U Level Cross Angle") .. "(°)",
            values = func.map(angleList, tostring),
            defaultIndex = 3
        },
        {
            key = "mirrored",
            name = _("Mirrored Underground Level"),
            values = {_("No"), _("Yes")},
            defaultIndex = 0
        },
    }
end

local function makeTram(type, tramType, snapNode)
    return function(edges)
        return {
            type = "STREET",
            alignTerrain = false,
            -- edgeType = "TUNNEL",
            -- edgeTypeName = "street_old.lua",
            params = {
                type = type,
                tramTrackType = tramType
            },
            edges = edges,
            snapNodes = snapNode
        }
    end
end

local ofGroup = function(offsets, id) return func.filter(offsets, function(xOffset) return xOffset.id == id end) end

local function tramPlatformRoofPattern(config, offsetX)
    return {
        newModel(config.platformRoofStart, coor.transX(offsetX), coor.transY(-30)),
        newModel(config.platformRoofRepeat, coor.transX(offsetX), coor.transY(-10)),
        newModel(config.platformRoofRepeat, coor.transX(offsetX), coor.transY(10)),
        newModel(config.platformRoofEnd, coor.transX(offsetX), coor.transY(30))
    }
end

local tramTrackExtCoor =
    {
        {{0, -70, 0}, {0, -10, 0}},
        {{0, -80, 0}, {0, -10, 0}},
        {{0, 70, 0}, {0, 10, 0}},
        {{0, 80, 0}, {0, 10, 0}}
    }

local function makeCommonPlatformTram(base, config, tramType)
    local tramTrackCoor = laneutil.makeLanes({
        {{-2.5, 40, 0}, {-2.5, 0, 0}, {0, -1, 0}, {0, -1, 0}},
        {{-2.5, 0, 0}, {-2.5, -40, 0}, {0, -1, 0}, {0, -1, 0}},
        
        {{2.5, -40, 0}, {2.5, 0, 0}, {0, 1, 0}, {0, 1, 0}},
        {{2.5, 0, 0}, {2.5, 40, 0}, {0, 1, 0}, {0, 1, 0}},
        
        {{2.5, -40.25, 0}, {3.5, -69.75, 0}, {0, -1, 0}, {0, -1, 0}},
        {{-2.5, -40.25, 0}, {0.5, -69.75, 0}, {0, -1, 0}, {0, -1, 0}},
        {{2.5, 40.25, 0}, {3.5, 69.75, 0}, {0, 1, 0}, {0, 1, 0}},
        {{-2.5, 40.25, 0}, {0.5, 69.75, 0}, {0, 1, 0}, {0, 1, 0}},
    })
    
    local tramTracks = coor.applyEdges(coor.mul(coor.transX(base + 7.5)), coor.I())(tramTrackCoor)
    local tramTracksExt = coor.applyEdges(coor.mul(coor.transX(base + 9.5)), coor.I())(tramTrackExtCoor)
    
    local tramPlatform = func.concat({
        newModel(config.tram.platformStart, coor.transX(base + 15), coor.transY(-30)),
        newModel(config.tram.platformRepeat, coor.transX(base + 15), coor.transY(-10)),
        newModel(config.tram.platformDwlink, coor.transX(base + 15), coor.transY(10)),
        newModel(config.tram.platformEnd, coor.transX(base + 15), coor.transY(30)),
    }, tramPlatformRoofPattern(config, base + 15))
    
    return {
        edges = {makeTram("z_tram_track.lua", tramType, {})(tramTracks), makeTram("new_small.lua", tramType, {1, 3})(tramTracksExt)},
        platforms = tramPlatform,
        face = {
            {base + 2.5, -80, 0},
            {base + 17.5, -80, 0},
            {base + 17.5, 80, 0},
            {base + 2.5, 80, 0},
        },
        xMax = base + 17.5,
        terminals = function(uOffsets, xOffsets, nSeg)
            local uOffsets0 = ofGroup(uOffsets, 0)
            local trainPlatform = #uOffsets0 * nSeg - 0.5 * nSeg
            return
                {
                    {
                        terminals = {{trainPlatform, 1}, {trainPlatform + 1, 1}, {trainPlatform - 1, 1}, {trainPlatform - 2, 1}},
                        vehicleNodeOverride = #xOffsets * 4 + 1
                    },
                    {
                        terminals = {{#uOffsets * nSeg + 3, 0}, {#uOffsets * nSeg + 2, 0}, {#uOffsets * nSeg + 1, 0}, {#uOffsets * nSeg, 0}},
                        vehicleNodeOverride = #xOffsets * 4 + 5
                    }
                }
        end,
    }
end


local function makeIndividualPlatformTram(base, config, tramType)
    local tramTrackCoor = laneutil.makeLanes({
        {{-2.5, 40, 0}, {-2.5, 0, 0}, {0, -1, 0}, {0, -1, 0}},
        {{-2.5, 0, 0}, {-2.5, -40, 0}, {0, -1, 0}, {0, -1, 0}},
        
        {{2.5, -40, 0}, {2.5, 0, 0}, {0, 1, 0}, {0, 1, 0}},
        {{2.5, 0, 0}, {2.5, 40, 0}, {0, 1, 0}, {0, 1, 0}},
        
        {{2.5, -40.25, 0}, {1.5, -69.75, 0}, {0, -1, 0}, {0, -1, 0}},
        {{-2.5, -40.25, 0}, {-1.5, -69.75, 0}, {0, -1, 0}, {0, -1, 0}},
        {{2.5, 40.25, 0}, {1.5, 69.75, 0}, {0, 1, 0}, {0, 1, 0}},
        {{-2.5, 40.25, 0}, {-1.5, 69.75, 0}, {0, 1, 0}, {0, 1, 0}},
    })
    
    
    local tramTracks = coor.applyEdges(coor.mul(coor.transX(base + 12.5)), coor.I())(tramTrackCoor)
    local tramTracksExt = coor.applyEdges(coor.mul(coor.transX(base + 12.5)), coor.I())(tramTrackExtCoor)
    
    local tramPlatform = func.concat({
        newModel(config.tram.platformStart, coor.transX(base + 5), coor.transY(-30)),
        newModel(config.tram.platformRepeat, coor.transX(base + 5), coor.transY(-10)),
        newModel(config.tram.platformDwlink2, coor.transX(base + 5), coor.transY(10)),
        newModel(config.tram.platformEnd, coor.transX(base + 5), coor.transY(30)),
        
        newModel(config.tram.platformStart, coor.transX(base + 20), coor.transY(-30)),
        newModel(config.tram.platformDwlink2, coor.rotZ(math.pi), coor.transX(base + 20), coor.transY(-10)),
        newModel(config.tram.platformRepeat, coor.transX(base + 20), coor.transY(10)),
        newModel(config.tram.platformEnd, coor.transX(base + 20), coor.transY(30)),
    }, func.concat(
        tramPlatformRoofPattern(config, base + 5),
        tramPlatformRoofPattern(config, base + 20)
    ))
    return {
        edges = {makeTram("z_tram_track.lua", tramType, {})(tramTracks), makeTram("new_small.lua", tramType, {1, 3})(tramTracksExt)},
        platforms = tramPlatform,
        face =
        {
            {base + 2.5, -80, 0},
            {base + 22.5, -80, 0},
            {base + 22.5, 80, 0},
            {base + 2.5, 80, 0},
        },
        xMax = base + 22.5,
        terminals = function(uOffsets, xOffsets, nSeg)
            return
                {
                    {
                        terminals = {{#uOffsets * nSeg + 3, 1}, {#uOffsets * nSeg + 2, 1}, {#uOffsets * nSeg + 1, 1}, {#uOffsets * nSeg, 1}},
                        vehicleNodeOverride = #xOffsets * 4 + 1
                    },
                    {
                        terminals = {{#uOffsets * nSeg + 7, 0}, {#uOffsets * nSeg + 6, 0}, {#uOffsets * nSeg + 5, 1}, {#uOffsets * nSeg + 4, 0}},
                        vehicleNodeOverride = #xOffsets * 4 + 5
                    }
                }
        end,
    }
end

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

local function roofPatterns(config)
    return function(n)
        local roofs = func.seqMap({1, n}, function(_) return config.platformRoofRepeat end)
        if (n > 2) then
            roofs[1] = config.platformRoofStart
            roofs[n] = config.platformRoofEnd
        end
        return roofs
    end
end

local function makeThrough(config, xOffsets, uOffsets, nSeg)
    local uOffsets0 = ofGroup(uOffsets, 0)
    local xOffsets0 = ofGroup(xOffsets, 0)
    local uOffsets1 = ofGroup(uOffsets, 1)
    local xOffsets1 = ofGroup(xOffsets, 1)
    local length = station.segmentLength * nSeg
    return {
        makeEntry = function(strConn, platformsS, roofs)
            local yHouse = ({15, 25, 30})[#uOffsets0 > 4 and 3 or math.ceil(#uOffsets0 * 0.5)]
            local house = config.surface.house[#uOffsets0 > 4 and 3 or math.ceil(#uOffsets0 * 0.5)]
            return function()
                if (strConn < 3) then
                    platformsS[math.ceil(nSeg * 0.5)].id = config.surface.platformFstRepeat
                    platformsS[math.ceil(nSeg * 0.5 + 1)].id = config.surface.platformFstRepeat
                    return
                        {
                            newModel(house, coor.rotZ(math.pi * 1.5), coor.transX(-5.5))
                        },
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
                    func.forEach(station.makePlatforms({uOffsets[1]}, roofPatterns(config)(nSeg)), func.bind(table.insert, roofs))
                    return
                        {
                            newModel(config.staires, coor.transX(0.5 * station.trackWidth), coor.rotZ(math.pi))
                        },
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
        end,
        
        makeEntry2 = function(strConn, hasTramStop, xMax)
            return function()
                if (strConn == 2 or strConn == 4) then
                    local xRef = xMax - 0.5 * station.platformWidth
                    if ((xOffsets0[#xOffsets0].x < uOffsets0[#uOffsets0].x) or hasTramStop) then
                        return
                            {
                                newModel(config.staires, coor.transX(xRef + 0.5 * station.trackWidth))
                            },
                            makeStreet({
                                {{xRef + 6, 0, 0}, {10, 0, 0}},
                                {{xRef + 26, 0, 0}, {10, 0, 0}}
                            }),
                            {
                                {xRef, -6, 0},
                                {xRef + 6, -6, 0},
                                {xRef + 6, 6, 0},
                                {xRef, 6, 0}
                            }
                    else
                        return
                            {
                                newModel(config.stairesPlatform, coor.transX(xRef + station.trackWidth)),
                                newModel(config.staires, coor.transX(xRef + 0.5 + station.trackWidth))
                            },
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
                    end
                else
                    return {}, nil, nil
                end
            end
        end,
        
        makeTrackGroups = function()
            return {
                sf = station.generateTrackGroups(xOffsets0, length + 5),
                ug = station.generateTrackGroups(xOffsets1, length + 5),
                mock = station.generateTrackGroups(ofGroup(uOffsets, 1), length)
            }
        end,
        
        makePlatforms = function()
            local platformsUG = platformPatterns(config.underground)(nSeg)
            local platformsSF = platformPatterns(config.surface)(nSeg)
            return {
                surface = station.makePlatforms(ofGroup(uOffsets, 0), platformsSF),
                underground = station.makePlatforms(ofGroup(uOffsets, 1), platformsUG),
                roofs = station.makePlatforms(func.range(uOffsets0, 2, #uOffsets0), roofPatterns(config)(nSeg))
            }
        end
    }
end


local function makeTerminal(config, xOffsets, uOffsets, nSeg)
    local uOffsets0 = ofGroup(uOffsets, 0)
    local xOffsets0 = ofGroup(xOffsets, 0)
    local uOffsets1 = ofGroup(uOffsets, 1)
    local xOffsets1 = ofGroup(xOffsets, 1)
    local length = station.segmentLength * nSeg
    return {
        makeEntry = function(strConn, platformsS, roofs)
            local yOffset = -nSeg * station.segmentLength * 0.5
            local xHouse = ({15, 25, 30})[#uOffsets0 > 4 and 3 or math.ceil(#uOffsets0 * 0.5)]
            local house = config.surface.house[#uOffsets0 > 4 and 3 or math.ceil(#uOffsets0 * 0.5)]
            
            local allOffset = func.map(func.flatten({uOffsets0, xOffsets0}), function(o) return o.x end)
            table.sort(allOffset)
            local baseX = (allOffset[math.ceil((1 + #allOffset) * 0.5)] + allOffset[math.floor((1 + #allOffset) * 0.5)]) * 0.5
            
            return function()
                return
                    func.flatten(
                        {
                            {newModel(house, coor.transY(yOffset - 10), coor.transX(baseX))},
                            func.map(xOffsets0, function(x) return newModel(config.surface.platformHeadTrack, coor.transY(yOffset), x.mpt) end),
                            func.map(uOffsets0, function(x) return newModel(config.surface.platformHead, coor.transY(yOffset), x.mpt) end)
                        }
                    ),
                    makeStreet({
                        {{baseX, yOffset - 15, 0}, {0, -1, 0}},
                        {{baseX, yOffset - 45, 0}, {0, -1, 0}}
                    }),
                    {
                        {0, xHouse, 0},
                        {-15.5, xHouse, 0},
                        {-15.5, -xHouse, 0},
                        {0, -xHouse, 0},
                    }
            end
        end,
        
        makeEntry2 = function(strConn, hasTramStop, xMax)
            return function()
                if (strConn == 2 or strConn == 4) then
                    local xRef = xMax - 0.5 * station.platformWidth
                    if ((xOffsets0[#xOffsets0].x < uOffsets0[#uOffsets0].x) or hasTramStop) then
                        return
                            {
                                newModel(config.staires, coor.transX(xRef + 0.5 * station.trackWidth))
                            },
                            makeStreet({
                                {{xRef + 6, 0, 0}, {10, 0, 0}},
                                {{xRef + 26, 0, 0}, {10, 0, 0}}
                            }),
                            {
                                {xRef, -6, 0},
                                {xRef + 6, -6, 0},
                                {xRef + 6, 6, 0},
                                {xRef, 6, 0}
                            }
                    else
                        return
                            {
                                newModel(config.stairesPlatform, coor.transX(xRef + station.trackWidth)),
                                newModel(config.staires, coor.transX(xRef + 0.5 + station.trackWidth))
                            },
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
                    end
                else
                    return {}, nil, nil
                end
            end
        end,
        
        makeTrackGroups = function()
            local extra = {
                mpt = coor.transY(2.5),
                mvec = coor.I()
            }
            
            return {
                sf = station.generateTrackGroups(xOffsets0, length + 5, extra),
                ug = station.generateTrackGroups(xOffsets1, length + 5),
                mock = station.generateTrackGroups(ofGroup(uOffsets, 1), length)
            }
        end,
        
        makePlatforms = function()
            local platformsUG = platformPatterns(config.underground)(nSeg)
            local platformsSF = platformPatterns(config.surface)(nSeg)
            platformsSF[1] = config.surface.platformRepeat
            return {
                surface = station.makePlatforms(ofGroup(uOffsets, 0), platformsSF),
                underground = station.makePlatforms(ofGroup(uOffsets, 1), platformsUG),
                roofs = station.makePlatforms(ofGroup(uOffsets, 0), roofPatterns(config)(nSeg))
            }
        end
    }
end

local function makeUpdateFn(config, hasUGLevel, makers)
    
    
    local stationHouse = config.stationHouse
    local staires = config.staires
    
    local function defaultParams(params)
        params.nbTracksSf = params.nbTracksSf or 0
        params.nbTracksUG = params.nbTracksUG or 0
        params.length = params.length or 2
        if (hasUGLevel) then
            params.trackTypeCatenary = params.trackTypeCatenary or 1
            params.trackType = ({0, 0, 1, 1})[params.trackTypeCatenary + 1]
            params.catenary = ({0, 1, 1, 0})[params.trackTypeCatenary + 1]
            params.tramTrack = params.tramTrack or 0
        else
            params.trackType = params.trackType or 0
            params.catenary = params.catenary or 1
            params.tramTrack = (params.tramTrack and params.tramTrack > 0 and params.tramTrack) or 2
        end
        params.strConnection = params.strConnection or 0
        params.offsetLat = params.offsetLat or 0
        params.offsetMed = params.offsetMed or 4
        params.angle = params.angle or 3
        params.mirrored = params.mirrored or 0
    end
    
    return function(params)
            
            defaultParams(params)
            local result = {}
            
            local trackType = ({"standard.lua", "high_speed.lua"})[params.trackType + 1]
            local catenary = params.catenary == 1
            local nSeg = platformSegments[params.length + 1]
            local length = nSeg * station.segmentLength
            local nbTracksSf = nbTracksLevelList[params.nbTracksSf + 1]
            local nbTracksUG = nbTracksLevelList[params.nbTracksUG + 1]
            local height = -15
            local strConn = params.strConnection + 1
            local hasTramStop = params.tramTrack ~= 0
            local tramType = ({"YES", "ELECTRIC"})[params.tramTrack]
            
            local _, preUOffsets0 = station.preBuild(nbTracksSf, 0, false, false)
            local _, preUOffsets1 = station.preBuild(nbTracksUG, 0, nbTracksUG % 4 == 0, nbTracksUG % 4 == 0)
            local maxOffset = preUOffsets0[#preUOffsets0] + 7.5
            local offsetX = offsetLat[params.offsetLat + 1] * 7.5
            local offsetY = offsetMed[params.offsetMed + 1] * station.segmentLength
            
            offsetX = maxOffset < offsetX and maxOffset or offsetX
            offsetY = math.abs(offsetY) < length * 0.5 and offsetY or (length * 0.5 - 2 * station.segmentLength) * (offsetY < 0 and -1 or 1)
            local rad = math.rad(angleList[params.angle + 1])
            
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
                hasUGLevel and {
                    mz = coor.transZ(height),
                    mr = coor.rotZ(rad),
                    mdr = coor.mul(coor.transX(-preUOffsets1[1]), (params.mirrored == 0 and coor.I() or coor.flipX()), coor.rotZ(rad), coor.transX(offsetX), coor.transY(offsetY)),
                    nbTracks = nbTracksUG,
                    baseX = 0,
                    ignoreFst = nbTracksUG % 4 == 0,
                    ignoreLst = nbTracksUG % 4 == 0,
                    id = 1
                } or nil
            }
            
            local xOffsets, uOffsets, xuIndex = station.buildCoors(nSeg, true)(levels, {}, {}, {}, {})
            local xOffsets0 = ofGroup(xOffsets, 0)
            local xOffsets1 = ofGroup(xOffsets, 1)
            local uOffsets0 = ofGroup(uOffsets, 0)
            
            local tram = hasTramStop and (
                uOffsets0[#uOffsets0].x > xOffsets0[#xOffsets0].x and
                makeCommonPlatformTram(uOffsets0[#uOffsets0].x, config, tramType) or
                makeIndividualPlatformTram(xOffsets0[#xOffsets0].x, config, tramType)) or
                {
                    platforms = {}, edges = {},
                    xMax = (uOffsets0[#uOffsets0].x > xOffsets0[#xOffsets0].x and uOffsets0[#uOffsets0].x or xOffsets0[#xOffsets0].x) + 2.5
                }
            
            local xMax = tram.xMax
            
            local makersFn = makers(config, xOffsets, uOffsets, nSeg)
            
            local platforms = makersFn.makePlatforms()
            local tracks = makersFn.makeTrackGroups()
            
            local entry, str, fE = makersFn.makeEntry(strConn, platforms.surface, roofs)()
            local entry2, str2, fE2 = makersFn.makeEntry2(strConn, hasTramStop, xMax)()
            
            result.models = func.flatten({
                platforms.surface, platforms.underground, tram.platforms, platforms.roofs,
                entry, entry2,
            }
            )
            result.edgeLists = func.flatten(
                {
                    {
                        trackEdge.normal(catenary, trackType, true, snapRule)(tracks.sf),
                        trackEdge.tunnel(catenary, trackType, snapRule)(tracks.ug)
                    },
                    tram.edges,
                    {
                        trackEdge.tunnel(false, "zzz_mock.lua", station.noSnap)(tracks.mock),
                        str, str2
                    }
                }
            )
            result.terminalGroups = func.flatten({
                station.makeTerminals(xuIndex),
                hasTramStop and tram.terminals(uOffsets, xOffsets, nSeg) or {}
            })
            
            -- local totalWidth = station.trackWidth * #ofGroup(xOffsets, 0) + station.platformWidth * #ofGroup(uOffsets, 0)
            local xMin = -0.5 * station.platformWidth
            -- local xMax = xMin + totalWidth
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
                    {face = f, modes = {{type = "FILL", key = "town_concrete"}}},
                    {face = f, modes = {{type = "STROKE_OUTER", key = "town_concrete_border"}}}
                } end)
            
            
            -- func.forEach(entryLocations, func.bind(addEntry, result, tramTrack))
            result.cost = 120000 + (nbTracksSf + nbTracksUG) * 24000
            result.maintenanceCost = result.cost / 6
            
            return result
    end
end


local complex = {
    makeComplexUG = function(config)
        return function()
            return {
                type = "RAIL_STATION",
                description = {
                    name = _("Complex Passenger Station"),
                    description = _("A complex passenger station with optional tram stop")
                },
                availability = config.availability,
                order = config.order,
                soundConfig = config.soundConfig,
                params = paramsUG(),
                updateFn = makeUpdateFn(config, true, makeEntry, makeEntry2)
            }
        end
    end,
    
    makeComplexTram = function(config)
        return function()
            return {
                type = "RAIL_STATION",
                description = {
                    name = _("Surface Passenger Station with tram stop"),
                    description = _("A passenger station with tram stop")
                },
                availability = config.availability,
                order = config.order,
                soundConfig = config.soundConfig,
                params = paramsTram(),
                updateFn = makeUpdateFn(config, false, makeThrough)
            }
        end
    end,
    
    
    makeComplexTramTerminal = function(config)
        return function()
            return {
                type = "RAIL_STATION",
                description = {
                    name = _("Surface Passenger Station with tram stop"),
                    description = _("A passenger station with tram stop")
                },
                availability = config.availability,
                order = config.order,
                soundConfig = config.soundConfig,
                params = paramsTram(),
                updateFn = makeUpdateFn(config, false, makeThrough)
            }
        end
    end,
    
    
    makeComplexUGTerminal = function(config)
        return function()
            return {
                type = "RAIL_STATION",
                description = {
                    name = _("Surface Passenger Station with tram stop"),
                    description = _("A passenger station with tram stop")
                },
                availability = config.availability,
                order = config.order,
                soundConfig = config.soundConfig,
                params = paramsTram(),
                updateFn = makeUpdateFn(config, false, makeTerminal)
            }
        end
    end
}

return complex
