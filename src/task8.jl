include("lines.jl")
include("Coordinates.jl")
include("CoordsRobot.jl")

function task8(robot)
    spiral!(robot, West) do
        return ismarker(robot)
    end
end