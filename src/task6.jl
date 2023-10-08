using HorizonSideRobots
include("CoordsRobot.jl")
include("PlusMarkerPlacerRobot.jl")
include("lines.jl")

function task6a(robot)
    path = go_to_corner(robot)
    print(path)
    mark_perimiter(robot)
    go_back(r, path)
end

function task6b(r)
    robot = PlusMarkerPlacerRobot(CoordsRobot(r, Coordinates(0, 0)), Coordinates(0, 0))
    path = go_to_corner(robot)
    print(path)
    mark_perimiter(robot)
    go_back(r, path)
end
