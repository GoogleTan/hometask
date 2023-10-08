include("lines.jl")
include("Coordinates.jl")
include("CoordsRobot.jl")

function task7(robot)
    shattle!(robot, West) do
        return !isborder(robot, Nord)
    end
end