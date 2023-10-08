using HorizonSideRobots

mutable struct Coordinates
    x :: Int64
    y :: Int64
end

function deltas(side :: HorizonSide)
    if side == Nord
        return (1, 0)
    elseif side == Sud
        return (-1, 0)
    elseif side == West
        return (0, 1)
    else
        return (0, -1)
    end
end

function HorizonSideRobots.move!(coordinates :: Coordinates, side :: HorizonSide)
    (dx, dy) = deltas(side)
    coordinates.x += dx
    coordinates.y += dy
end