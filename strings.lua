local descEN = [[Complex surface station, with underground level and/or tram stop option. 

== IMPORTANT ==
[b]This mod shares the run-time resources with Multi-level / Underground Train Station, you need to have that MOD loaded in order to play.[/b]

Features:
* Station with a surface level with option of an underground level and/or tram stop
* From 2 to 12 tracks for each level
* From 40m to 480m platform lengths
* Cross station options with crossing angle of 30°, 60° and 90°
* Minimaliste entrance option
* Optional underground or tram stop with interchange platforms
* Available since 1900

To be implemented:
* Better-looking tram track
* Underground tram stop (there're some techinique bugs)
* Terminal layout

---------------
Changelog:
1.0
Released version.
- Added surface station with tram stop
- Improved tram stop options
0.9
Pre-release beta
--------------- 
* Planned projects 
- Curved station
- Sunk station 
- Elevated Crossing station
- Better flying junction 
]]

local descFR = [[Gares complexes avec niveau souterrain ou/et l'arrêt de tram. 

== IMPORTANT ==
[b]Ce mod partage des ressource avec le mod de gare souterrain, vous devez avoir les deux mods chargés dans le même temps.[/b]

Caractéristiques:
* Gare en surface avec option de niveau souterrain et/ou l'arrêt de tram
* De 2 jusqu'à 12 voies pour chaques niveaux
* De 40m jusqu'à 480m de longeur de platformes
* Option d'angle de croisement de 30°, 45°, 60° et 90°
* Option d'entrées minimalistes
* Optional de niveau souterrain et/ou arrêt de tram avec passages de correspondances
* Disponible depuis 1900

À implementer:
* Cosmétique pour la voie de tram
* L'arrêt de tram souterrain
* Gares terminaux

---------------
Changelog:
1.0
Version formelle.
- Ajout de gare en surface avec l'arrêt de tram
- Les options de tram sont améliorées
0.9
Pre-release beta
]]

local descZH = [[带有地下站台和有轨电车站台选项的联合车站

== 重要信息 ==
[b]本MOD和地下车站共享一部分运行时资源，需要同时加载这两个MOD运行[/b]

特点:
* 带有地下站台和/或有轨电车站台的地面车站
* 每层2至12个站台
* 站台长度从40米到480米
* 在30°, 45°, 60° 或 90°之间可选的交汇角
* 迷你化入口
* 车站各部之间有换乘通道
* 自1900年起可用

尚未实现:
* 更好看的有轨轨道
* 地下有轨车站
* 尽头站

---------------
Changelog:
1.0
正式版本
- 加入了带有有轨电车站台的地面车站
- 改良过的有轨电车站台选项
0.9
测试版本
]]

function data()
    return {
        en = {
            ["name"] = "Complex Train Stations",
            ["desc"] = descEN
        },
        fr = {
            ["name"] = "Gares de voyageur complexes",
            ["desc"] = descFR,
            ["Ground Level: Number of tracks"] = "Surface: nombre de voies",
            ["Underground Level: Number of tracks"] = "Souterrain: nombre de voies",
            ["Platform length"] = "Longeur de platforme",
            ["Track Type & Catenary"] = "Type de voie & Caténaire",
            ["Elec."] = "Élec.",
            ["Hi-Speed"] = "GV",
            ["Elec.Hi-Speed"] = "GV.Élec.",
            ["Street Connection"] = "Type des entrées",
            ["U Level Lateral Offset"] = "Décalage latéral n.-1",
            ["U Level Medial Offset"] = "Décalage médial n.-1",
            ["U Level Cross Angle"] = "Angle de croisement de n.-1",
            ["Mirrored Underground Level"] = "N.-1 en miroire",
            ["Surface Passenger Station with tram stop"] = "Gare de voyageur avec l'arrêt de tram",
            ["A passenger station with tram stop"] = "Gare de voyageur avec l'arrêt de tram",
            ["Complex Passenger Station"] = "Gare de voyageur complexe",
            ["A complex passenger station with optional tram stop"] = "Gare de voyageur complexe 2 niveaux avec option d'arrêt de tram"
        },
        zh_CN = {
            ["name"] = "联合车站",
            ["desc"] = descZH,
            ["Ground Level: Number of tracks"] = "地面轨道数",
            ["Underground Level: Number of tracks"] = "地下轨道数",
            ["Platform length"] = "站台长度",
            ["Track Type & Catenary"] = "轨道类型和电气化",
            ["Normal"] = "普通",
            ["Elec."] = "电化",
            ["Hi-Speed"] = "无电高速",
            ["Elec.Hi-Speed"] = "电化高速",
            ["1 Mini"] = "1个微型出口",
            ["2 Minis"] = "2个微型出口",
            ["Street Connection"] = "车站入口类型",
            ["U Level Lateral Offset"] = "地下层横向偏移",
            ["U Level Medial Offset"] = "地下层纵向编译",
            ["U Level Cross Angle"] = "地下层交错角",
            ["Mirrored Underground Level"] = "镜像地下层",
            ["Surface Passenger Station with tram stop"] = "附带有轨电车站台的旅客列车站车",
            ["A passenger station with tram stop"] = "附带有轨电车站台的旅客列车站车",
            ["Complex Passenger Station"] = "带有地下层的旅客列车车站",
            ["A complex passenger station with optional tram stop"] = "带有地下层的旅客列车车站，可选有轨电车站台"
        }
    }
end
