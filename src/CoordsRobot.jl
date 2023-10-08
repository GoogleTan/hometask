using HorizonSideRobots
include("Coordinates.jl")
include("AbstractRobot.jl")

struct CoordsRobot <: AbstractRobot
    base
    coordinates :: Coordinates
end

get_base(robot :: CoordsRobot) = robot.base

function HorizonSideRobots.move!(robot :: CoordsRobot, side)
    move!(robot.base, side)
    move!(robot.coordinates, side)
end