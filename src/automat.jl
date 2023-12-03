using HorizonSideRobots
HSR = HorizonSideRobots
 
mutable struct Coordinates
    x :: Int
    y :: Int
end
 
Base.:(==)(a :: Coordinates, b :: Coordinates) = a.x == b.x && a.y == b.y
 
function HSR.move!(r :: Coordinates, side)
    if side == Nord 
        r.x += 1
    elseif side == inverse(Nord)
        r.x -= 1
    elseif side == West
        r.y -= 1
    else
        r.y += 1
    end
end
 
abstract type AbstractRobot end
 
function HSR.move!(r :: AbstractRobot, side)
    move!(get_base_robot(r), side)
end

function HSR.putmarker!(r :: AbstractRobot)
    putmarker!(get_base_robot(r))
end

function HSR.isborder(r :: AbstractRobot, side)
    isborder(get_base_robot(r), side)
end
 
AnyRobot = Union{Robot,AbstractRobot}

# Данный робот поддерживает свои актуальные координаты при движении. 
struct TrackingRobot{T <: AnyRobot} <: AbstractRobot
    robot :: T
    coordinates :: Coordinates
end
 
get_base_robot(r :: TrackingRobot) = r.robot
function HSR.move!(r :: TrackingRobot, side)
    move!(get_base_robot(r), side)
    move!(r.coordinates, side)
end

# Рассчитывает направление повёрнутое против часовой стрелки.
anticlockwise(side :: HorizonSide) = HorizonSide(mod(Int(side) + 1, 4))
# Рассчитывает направление повёрнутое по часовой стрелке.
clockwise(side :: HorizonSide) = HorizonSide(mod(Int(side) + 3, 4))
# Рассчитывает направление обратное данному
inverse(side :: HorizonSide) = anticlockwise(anticlockwise(side))

# Обходит покругу лабиринт, находящийся со стороны side от робота robot. На каждом шаге вдоль стены вызывает tick с роботом и стороной, с которой находится стена лабиринта, обход которого совершается.
function go_around_labirint(tick, robot :: AnyRobot, side :: HorizonSide)
    @assert isborder(robot, side)
    haveMovedAtLeastOnce = false
    robot = TrackingRobot(robot, Coordinates(0, 0))
    moveSide = anticlockwise(side)
    while robot.coordinates != Coordinates(0, 0) || !haveMovedAtLeastOnce
        while isborder(robot, moveSide)
            moveSide = anticlockwise(moveSide)
            tick(robot, clockwise(moveSide))    
        end
        move!(robot, moveSide)
        while !isborder(robot, clockwise(moveSide))
            moveSide = clockwise(moveSide)
            move!(robot, moveSide)
        end
        tick(robot, clockwise(moveSide))    
        haveMovedAtLeastOnce = true
    end
end

# Считает площадь лабиринта, стена которого находится со стороны side. 
function sum_around_labirint(r, side)
    sum = 0
    go_around_labirint(r, side) do robot, leadingSide 
        if leadingSide == West && isborder(robot, West)
            sum += robot.coordinates.y - 1
        elseif leadingSide == inverse(West) && isborder(robot, inverse(West))
            sum -= robot.coordinates.y
        end
    end
    return sum
end

# Проверяет, является ли робот снаружи лабиринта, стена которого находится со стороны side. 
function is_outside_labirint(robot, side)
    max_leading_side = ()
    max_x_coordinate = 0

    go_around_labirint(robot, side) do robot, leadingSide
        if robot.coordinates.x > max_x_coordinate 
            max_x_coordinate = robot.coordinates.x
            max_leading_side = leadingSide
        elseif robot.coordinates.x == max_x_coordinate 
            if leadingSide == Nord 
                max_leading_side = Nord
            end
        end
    end
    return max_leading_side != Nord
end
