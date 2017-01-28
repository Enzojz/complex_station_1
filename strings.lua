local descEN = [[Complex station with a surface level and an underground level, optional tram stop. 

This mod shares the run-time resources with Multi-level / Underground Train Station, you need to have that MOD loaded in order to play.

Features:
* Station with a surface level and an underground level
* From 2 to 12 tracks for each level
* From 40m to 480m platform lengths
* Cross station options with crossing angle of 30°, 60° and 90°
* Minimaliste entrance option
* Optional tram stop with interchange platforms
* Available since 1900

To be implemented:
* Better-looking tram track
* Underground tram stop (there're some techinique bugs)
* Pass-through layout

=== ATTENTION ===
* This is the pre-release version of the mod, please use it with attention. Backup your important gameplay before application.
* The purpose of this release is mainly collect feedback and check of stability.

---------------
0.9
Pre-release beta
--------------- 
* Planned projects 
- Curved station
- Sunk station 
- Elevated Crossing station
- Better flying junction 
]]

function data()
    return {
        en = {
            ["name"] = "Complex Train Stations",
            ["desc"] = descEN
        }
    }
end
