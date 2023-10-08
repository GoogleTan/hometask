include("lines.jl")
include("Coordinates.jl")
include("CoordsRobot.jl")
include("ChessMarkerRobot.jl")

function task10(r, size)
    robot = ChessMarkerPlacerRobot(CoordsRobot(r, Coordinates(0, 0)), Coordinates(0, 0), size)
    path = go_to_corner(robot)
    snake!(robot, Nord, Ost) do
        putmarker!(robot)
    end
    go_back(robot, path)
end