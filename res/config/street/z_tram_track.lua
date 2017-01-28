function data()
    return {
        numLanes = 1,
        streetWidth = 3,
        sidewalkWidth = 0,
        sidewalkHeight = .0,
        yearFrom = 1920,
        yearTo = 0,
        upgrade = false,
        --country = true,
        speed = 100.0,
        transportModesStreet = {"TRAM"},
        transportModesSidewalk = {},
        --type = "tram",
        name = _("Tram track"),
        desc = _("Tram-only track with a speed limit of %2%"),
        materials = {
            streetPaving = {name = "street/new_small_paving.mtl", size = {6.0, 6.0}},
            streetBorder = {},
            streetLane = {name = "street/new_small_lane.mtl", size = {3.0, 3.0}},
            streetStripe = {},
            streetStripeMedian = {},
            streetTram = {name = "street/new_medium_tram.mtl", size = {2.0, 2.0}},
            streetBus = {},
            crossingLane = {},
            crossingBus = {},
            crossingTram = {},
            crossingCrosswalk = {},
            sidewalkPaving = {},
            sidewalkLane = {},
            sidewalkBorderInner = {},
            sidewalkBorderOuter = {},
            sidewalkCurb = {},
            sidewalkWall = {}
        },
        bridges = {},
        cost = 13.0,
    }
end