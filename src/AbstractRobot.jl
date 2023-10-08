
abstract type AbstractRobot
end

function HorizonSideRobots.move!(robot :: AbstractRobot, side)
    local r = get_base(robot)
    move!(r, side)
end

function HorizonSideRobots.isborder(robot :: AbstractRobot, side)
    local r = get_base(robot)
    isborder(r, side)
end

function HorizonSideRobots.putmarker!(robot :: AbstractRobot)
    local r = get_base(robot)
    putmarker!(r)
end