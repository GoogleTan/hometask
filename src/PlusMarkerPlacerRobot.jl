using HorizonSideRobots
include("Coordinates.jl")
include("AbstractRobot.jl")
include("CoordsRobot.jl")

"""
    Ставит маркеры только в точках, в которых совпадает одна из координат с изначальной
    base - CoordsRobot
    root - точка начала игры
"""
struct PlusMarkerPlacerRobot <: AbstractRobot
    base :: CoordsRobot
    root :: Coordinates
end

get_base(robot :: PlusMarkerPlacerRobot) = robot.base

function HorizonSideRobots.putmarker!(robot :: PlusMarkerPlacerRobot)
    current_coords = robot.base.coordinates
    root = robot.root
    if root.x == current_coords.x || root.y == current_coords.y
        putmarker!(robot.base)
    end
end
