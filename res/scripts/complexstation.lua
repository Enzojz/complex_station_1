local function load(module) return require("underground/" .. module) end

local laneutil = require "laneutil"
local paramsutil = require "paramsutil"
local func = load "func"
local pipe = load "pipe"
local coor = load "coor"
local trackEdge = load "trackedge"
local station = load "stationlib"

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
        paramsutil.makeTrackTypeParam(),
        paramsutil.makeTrackCatenaryParam(),
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


local function paramsTerminalTram()
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
            values = {_("1"), _("2"), _("Tram"), _("2") .. "+" .. _("Tram")},
            defaultIndex = 0
        },
        paramsutil.makeTramTrackParam1(),
        paramsutil.makeTramTrackParam2()
    }
end

local function paramsTerminalUG()
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
        paramsutil.makeTrackTypeParam(),
        paramsutil.makeTrackCatenaryParam(),
        {
            key = "strConnection",
            name = _("Street Connection"),
            values = {_("1"), _("2"), _("Tram"), _("2") .. "+" .. _("Tram")},
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

local function tramPlatformRoofPattern(config, offsetX, offsetY)
    return {
        newModel(config.platformRoofStart, coor.transX(offsetX), coor.transY(-30 + offsetY)),
        newModel(config.platformRoofRepeat, coor.transX(offsetX), coor.transY(-10 + offsetY)),
        newModel(config.platformRoofRepeat, coor.transX(offsetX), coor.transY(10 + offsetY)),
        newModel(config.platformRoofEnd, coor.transX(offsetX), coor.transY(30 + offsetY))
    }
end

local tramTrackExtCoor =
    {
        {{0, -70, 0}, {0, -10, 0}},
        {{0, -80, 0}, {0, -10, 0}},
        {{0, 70, 0}, {0, 10, 0}},
        {{0, 80, 0}, {0, 10, 0}}
    }

local function makeCommonPlatformTram(yOffset)
    return function(base, config, tramType)
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
        
        local tramTracks = coor.applyEdges(coor.trans({x = base + 7.5, y = yOffset, z = 0}), coor.I())(tramTrackCoor)
        local tramTracksExt = coor.applyEdges(coor.trans({x = base + 9.5, y = yOffset, z = 0}), coor.I())(tramTrackExtCoor)
        
        local tramPlatform = func.concat({
            newModel(config.tram.platformStart, coor.transX(base + 15), coor.transY(-30 + yOffset)),
            newModel(config.tram.platformRepeat, coor.transX(base + 15), coor.transY(-10 + yOffset)),
            newModel(config.tram.platformDwlink, coor.transX(base + 15), coor.transY(10 + yOffset)),
            newModel(config.tram.platformEnd, coor.transX(base + 15), coor.transY(30 + yOffset)),
        }, tramPlatformRoofPattern(config, base + 15, yOffset))
        
        return {
            edges = {makeTram("z_tram_track.lua", tramType, {})(tramTracks), makeTram("new_small.lua", tramType, {1, 3})(tramTracksExt)},
            platforms = tramPlatform,
            face = {
                {base + 2.5, -80 + yOffset, 0},
                {base + 17.5, -80 + yOffset, 0},
                {base + 17.5, 80 + yOffset, 0},
                {base + 2.5, 80 + yOffset, 0},
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
end


local function makeIndividualPlatformTram(yOffset)
    return function(base, config, tramType)
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
        
        
        local tramTracks = coor.applyEdges(coor.trans({x = base + 12.5, y = yOffset, z = 0}), coor.I())(tramTrackCoor)
        local tramTracksExt = coor.applyEdges(coor.trans({x = base + 12.5, y = yOffset, z = 0}), coor.I())(tramTrackExtCoor)
        
        local tramPlatform = pipe.new
            + {
                newModel(config.tram.platformStart, coor.transX(base + 5), coor.transY(-30 + yOffset)),
                newModel(config.tram.platformRepeat, coor.transX(base + 5), coor.transY(-10 + yOffset)),
                newModel(config.tram.platformDwlink2, coor.transX(base + 5), coor.transY(10 + yOffset)),
                newModel(config.tram.platformEnd, coor.transX(base + 5), coor.transY(30 + yOffset)),
                
                newModel(config.tram.platformStart, coor.transX(base + 20), coor.transY(-30 + yOffset)),
                newModel(config.tram.platformDwlink2, coor.rotZ(math.pi), coor.transX(base + 20), coor.transY(-10 + yOffset)),
                newModel(config.tram.platformRepeat, coor.transX(base + 20), coor.transY(10 + yOffset)),
                newModel(config.tram.platformEnd, coor.transX(base + 20), coor.transY(30 + yOffset)),
            }
            + tramPlatformRoofPattern(config, base + 5, yOffset)
            + tramPlatformRoofPattern(config, base + 20, yOffset)
        
        return {
            edges = {makeTram("z_tram_track.lua", tramType, {})(tramTracks), makeTram("new_small.lua", tramType, {1, 3})(tramTracksExt)},
            platforms = tramPlatform,
            face =
            {
                {base + 2.5, -80 + yOffset, 0},
                {base + 22.5, -80 + yOffset, 0},
                {base + 22.5, 80 + yOffset, 0},
                {base + 2.5, 80 + yOffset, 0},
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

local function makeStairsEntry(config, mpt, mr)
    return {
        models =
        {
            newModel(config.staires, coor.transX(0.5 * station.trackWidth), mpt)
        },
        streets = {
            makeStreet(coor.applyEdges(mpt, mr or coor.I())({
                {{6, 0, 0}, {10, 0, 0}},
                {{26, 0, 0}, {10, 0, 0}}
            }))
        },
        faces = func.map({
            {
                {0, -6, 0}, {6, -6, 0},
                {6, 6, 0}, {0, 6, 0}
            }
        }, station.faceMapper(mpt))
    }
end

local function makePlatformStairsEntry(config, mpt, mr)
    return {
        models =
        {
            newModel(config.stairesPlatform, coor.transX(station.trackWidth), mpt),
            newModel(config.staires, coor.transX(3 + 0.5 * station.trackWidth), mpt)
        },
        streets = {
            makeStreet(coor.applyEdges(mpt, mr or coor.I())({
                {{9, 0, 0}, {10, 0, 0}},
                {{29, 0, 0}, {10, 0, 0}}
            }))
        },
        faces = func.map({
            {
                {0, -12, 0}, {9, -12, 0},
                {9, 12, 0}, {0, 12, 0}
            }
        }, station.faceMapper(mpt))
    }
end

local function makeThrough(config, xOffsets, uOffsets, nSeg)
    local uOffsets0 = ofGroup(uOffsets, 0)
    local xOffsets0 = ofGroup(xOffsets, 0)
    local uOffsets1 = ofGroup(uOffsets, 1)
    local xOffsets1 = ofGroup(xOffsets, 1)
    local length = station.segmentLength * nSeg
    
    return {
        makeEntry = function(strConn, platforms)
            return function()
                if (strConn < 3) then
                    
                    local yHouse = ({15, 25, 30})[#uOffsets0 > 4 and 3 or math.ceil(#uOffsets0 * 0.5 + 1)]
                    local house = config.surface.house[#uOffsets0 > 4 and 3 or math.ceil(#uOffsets0 * 0.5 + 1)]
                    
                    platforms.surface[math.ceil(nSeg * 0.5)].id = config.surface.platformFstRepeat
                    platforms.surface[math.ceil(nSeg * 0.5 + 1)].id = config.surface.platformFstRepeat
                    return {
                        models = {
                            newModel(house, coor.rotZ(math.pi * 1.5), coor.transX(-5.5))
                        },
                        streets =
                        {
                            makeStreet({
                                {{-5.5 - 10, 0, 0}, {-10, 0, 0}},
                                {{-5.5 - 30, 0, 0}, {-10, 0, 0}}
                            })
                        },
                        faces = {
                            {
                                {0, yHouse, 0}, {-15.5, yHouse, 0},
                                {-15.5, -yHouse, 0}, {0, -yHouse, 0},
                            }
                        }
                    }
                else
                    func.forEach(station.makePlatforms({uOffsets0[1]}, roofPatterns(config)(nSeg)), func.bind(table.insert, platforms.roofs))
                    return makeStairsEntry(config, coor.rotZ(math.pi), coor.rotZ(math.pi))
                end
            end
        end,
        
        makeEntry2 = function(strConn, hasTramStop, xMax)
            return function()
                if (strConn == 2 or strConn == 4) then
                    local xRef = xMax - 0.5 * station.platformWidth
                    return ((xOffsets0[#xOffsets0].x < uOffsets0[#uOffsets0].x) or hasTramStop)
                        and makeStairsEntry(config, coor.trans({x = xRef, y = 0, z = 0}))
                        or makePlatformStairsEntry(config, coor.trans({x = xRef, y = 0, z = 0}))
                else
                    return {models = {}, streets = {}, faces = {}}
                end
            end
        end,
        
        makeTrackGroups = function()
            return {
                surface = station.generateTrackGroups(xOffsets0, length + 5),
                underground = station.generateTrackGroups(xOffsets1, length + 5),
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
        end,
        
        makeTramCommonPlatformTram = makeCommonPlatformTram(0),
        makeTramIndividualPlatformTram = makeIndividualPlatformTram(0)
    }
end


local function makeTerminal(config, xOffsets, uOffsets, nSeg)
    local uOffsets0 = ofGroup(uOffsets, 0)
    local xOffsets0 = ofGroup(xOffsets, 0)
    local uOffsets1 = ofGroup(uOffsets, 1)
    local xOffsets1 = ofGroup(xOffsets, 1)
    local length = station.segmentLength * nSeg
    local tramOffset = nSeg > 8 and -0.5 * length + 80 or 0
    return {
        makeEntry = function(strConn, _)
            local yOffset = -nSeg * station.segmentLength * 0.5
            local allOffsets =
                (
                pipe.from(xOffsets0)
                * pipe.map(function(o) return func.with(o, {isTrack = true}) end)
                + pipe.from(uOffsets0)
                * pipe.map(function(o) return func.with(o, {isTrack = false}) end)
                )
                * pipe.sort(function(l, r) return l.x < r.x end)
            
            local xHouse = (#uOffsets0 * station.platformWidth + #xOffsets0 * station.trackWidth) * 0.5
            local house = config.surface.house[#allOffsets > 14 and 4 or math.floor(#allOffsets * 0.33 + 0.3)]
            local baseX = (allOffsets[math.ceil((1 + #allOffsets) * 0.5)].x + allOffsets[math.floor((1 + #allOffsets) * 0.5)].x) * 0.5
            
            return function()
                return {
                    models = pipe.new
                    / newModel(house, coor.transY(yOffset - 10), coor.transX(baseX))
                    + (function()
                        local function fn(i, res)
                            local next = function(...) return fn(i + 1, func.concat(res, {...})) end
                            local l = allOffsets[i - 1]
                            local c = allOffsets[i]
                            local r = allOffsets[i + 1]
                            if (c == nil) then
                                return res
                            elseif (l == nil and c.isTrack) then --First as track
                                return next(newModel(config.surface.platformHeadTrackEnd, coor.flipX(), coor.transY(yOffset), c.mpt))
                            elseif (c.isTrack and r == nil) then -- Last as track
                                return next(newModel(config.surface.platformHeadTrackEnd, coor.transY(yOffset), c.mpt))
                            elseif (l == nil and not c.isTrack) then -- First as platform
                                return next(newModel(config.surface.platformHeadPlatformEnd, coor.flipX(), coor.transY(yOffset), c.mpt))
                            elseif (not c.isTrack and r == nil) then -- Last as platform
                                return next(newModel(config.surface.platformHeadPlatformEnd, coor.transY(yOffset), c.mpt))
                            elseif (not c.isTrack) then -- Platforms
                                return next(newModel(config.surface.platformHead, coor.transY(yOffset), c.mpt))
                            elseif (c.isTrack and r.isTrack) then
                                return next(newModel(config.surface.platformHeadTrack, coor.transY(yOffset), c.mpt))
                            elseif (c.isTrack and not r.isTrack) then
                                return next()
                            else
                                return next()
                            end
                        end
                        return fn(1, {})
                    end)()
                    ,
                    streets = {
                        makeStreet({
                            {{baseX, yOffset - 20, 0}, {0, -1, 0}},
                            {{baseX, yOffset - 40, 0}, {0, -1, 0}}
                        })
                    },
                    faces = {
                        {
                            {baseX + xHouse, yOffset, 0},
                            {baseX - xHouse, yOffset, 0},
                            {baseX - xHouse, yOffset - 20, 0},
                            {baseX + xHouse, yOffset - 20, 0},
                        }
                    }
                }
            end
        end,
        
        makeEntry2 = function(strConn, hasTramStop, xMax)
            return function()
                local xRef = xOffsets0[#xOffsets0].x < uOffsets0[#uOffsets0].x and uOffsets0[#uOffsets0].x or xOffsets0[#xOffsets0].x
                local yOffset = length * 0.5 - 2 * station.segmentLength
                local entryRight = ((hasTramStop and nSeg < 9) or (strConn == 1 or strConn == 3))
                    and {models = {}, streets = {}, faces = {}}
                    or (
                    (xOffsets0[#xOffsets0].x < uOffsets0[#uOffsets0].x)
                    and makeStairsEntry(config, coor.trans({x = xRef, y = yOffset, z = 0}))
                    or makePlatformStairsEntry(config, coor.trans({x = xRef, y = yOffset, z = 0}))
                )
                local entryLeft = (strConn == 1 or strConn == 3)
                    and {models = {}, streets = {}, faces = {}}
                    or (
                    (xOffsets0[1].x < uOffsets0[1].x)
                    and makePlatformStairsEntry(config, coor.rotZ(math.pi) * coor.transY(yOffset), coor.rotZ(math.pi))
                    or makeStairsEntry(config, coor.rotZ(math.pi) * coor.transY(yOffset), coor.rotZ(math.pi))
                )
                local entryTram = (hasTramStop and strConn > 2)
                    and makeStairsEntry(config, coor.trans({x = xMax - 0.5 * station.platformWidth, y = tramOffset, z = 0}))
                    or {models = {}, streets = {}, faces = {}}
                
                return
                    {
                        models = func.flatten({entryRight.models, entryLeft.models, entryTram.models}),
                        streets = func.flatten({entryRight.streets, entryLeft.streets, entryTram.streets}),
                        faces = func.flatten({entryRight.faces, entryLeft.faces, entryTram.faces})
                    }
            end
        end,
        
        makeTrackGroups = function()
            local extra = {
                mpt = coor.transY(2.5),
                mvec = coor.I()
            }
            
            return {
                surface = station.generateTrackGroups(xOffsets0, length + 5, extra),
                underground = station.generateTrackGroups(xOffsets1, length + 5),
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
        end,
        
        makeTramCommonPlatformTram = makeCommonPlatformTram(tramOffset),
        makeTramIndividualPlatformTram = makeIndividualPlatformTram(tramOffset)
    }
end

local function makeUpdateFn(config, hasUGLevel, makers)
    
    
    local stationHouse = config.stationHouse
    local staires = config.staires
    
    local function defaultParams(params)
        params.nbTracksSf = params.nbTracksSf or 0
        params.nbTracksUG = params.nbTracksUG or 0
        params.length = params.length or 2
        params.trackType = params.trackType or 0
        params.catenary = params.catenary or 1
        params.tramTrack = hasUGLevel and (params.tramTrack or 0) or ((params.tramTrack and params.tramTrack > 0 and params.tramTrack) or 2)
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
                    mdr = coor.transX(-preUOffsets1[1]) * (params.mirrored == 0 and coor.I() or coor.flipX()) * coor.rotZ(rad) * coor.transX(offsetX) * coor.transY(offsetY),
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
            
            
            local makersFn = makers(config, xOffsets, uOffsets, nSeg)
            
            local tram = hasTramStop and (
                uOffsets0[#uOffsets0].x > xOffsets0[#xOffsets0].x and
                makersFn.makeTramCommonPlatformTram(uOffsets0[#uOffsets0].x, config, tramType) or
                makersFn.makeTramIndividualPlatformTram(xOffsets0[#xOffsets0].x, config, tramType)) or
                {
                    platforms = {}, edges = {},
                    xMax = (uOffsets0[#uOffsets0].x > xOffsets0[#xOffsets0].x and uOffsets0[#uOffsets0].x or xOffsets0[#xOffsets0].x) + 2.5,
                    face = nil
                }
            
            local platforms = makersFn.makePlatforms()
            local tracks = makersFn.makeTrackGroups()
            
            local entry = makersFn.makeEntry(strConn, platforms)()
            local entry2 = makersFn.makeEntry2(strConn, hasTramStop, tram.xMax)()
            
            result.models = pipe.new
                + platforms.surface
                + platforms.underground
                + tram.platforms
                + platforms.roofs
                + entry.models
                + entry2.models
            
            result.edgeLists = pipe.new
                + {
                    trackEdge.normal(catenary, trackType, true, snapRule)(tracks.surface),
                    trackEdge.tunnel(catenary, trackType, snapRule)(tracks.underground)
                }
                + tram.edges
                + {trackEdge.tunnel(false, "zzz_mock.lua", station.noSnap)(tracks.mock)}
                + entry.streets
                + entry2.streets
            
            result.terminalGroups = pipe.new
                + station.makeTerminals(xuIndex)
                + (hasTramStop and tram.terminals(uOffsets, xOffsets, nSeg) or {})
            
            local totalWidth = station.trackWidth * #ofGroup(xOffsets, 0) + station.platformWidth * #ofGroup(uOffsets, 0)
            local xMin = -0.5 * station.platformWidth
            local xMax = xMin + totalWidth
            local yMin = -0.5 * length
            local yMax = 0.5 * length
            
            local faces = func.flatten({
                {
                    {
                        {xMin, yMin, 0},
                        {xMax, yMin, 0},
                        {xMax, yMax, 0},
                        {xMin, yMax, 0}
                    }, tram.face
                },
                entry.faces,
                entry2.faces,
            }
            )
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
                updateFn = makeUpdateFn(config, true, makeThrough)
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
                params = paramsTerminalTram(),
                updateFn = makeUpdateFn(config, false, makeTerminal)
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
                params = paramsTerminalUG(),
                updateFn = makeUpdateFn(config, true, makeTerminal)
            }
        end
    end
}

return complex
