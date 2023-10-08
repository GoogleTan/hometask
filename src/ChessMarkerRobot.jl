using HorizonSideRobots
include("Coordinates.jl")
include("AbstractRobot.jl")
include("CoordsRobot.jl")

"""
    Ставит маркеры только в точках, в которых совпадает одна из координат с изначальной
    base - CoordsRobot
    root - точка начала игры
"""
struct ChessMarkerPlacerRobot <: AbstractRobot
    base :: CoordsRobot
    root :: Coordinates
    size :: Int
end

get_base(robot :: ChessMarkerPlacerRobot) = robot.base

function HorizonSideRobots.putmarker!(robot :: ChessMarkerPlacerRobot)
    current_coords = robot.base.coordinates
    root = robot.root
    if mod(trunc(root.x / robot.size) + trunc(current_coords.x / robot.size), 2) == mod(trunc(root.y / robot.size) + trunc(current_coords.y / robot.size), 2)
        putmarker!(robot.base)
    end
end
