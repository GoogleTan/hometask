using HorizonSideRobots

struct RelativePosition
    dx :: Int
    dy :: Int
end

struct AbsolutePosition
    x :: Int
    y :: Int
end

function delta(side :: HorizonSide)
    if side == Nord
        return (1, 0)
    elseif side == West
        return (0, 1)
    elseif side == Sud
        return (-1, 0)
    else
        return (0, -1)
    end
end

function moved(pos :: RelativePosition, side)
    (dx, dy) = delta(side)
    return RelativePosition(pos.dx + dx, pos.dy + dy)
end

function moved(pos :: AbsolutePosition, side)
    (dx, dy) = delta(side)
    return AbsolutePosition(pos.x + dx, pos.y + dy)
end

function Base.push!(collection :: Dict, key, value)
    merge!(collection, Dict(key => value))
end

function dfs_relative!(robot, pattern, position, was :: Dict, possible_directions)
    was_at!(robot, pattern, position)
    push!(was, position, 1)
    for side in possible_directions
        if get(was, moved(position, side), 0) == 0 && can_go!(robot, side)
            move!(robot, side)
            dfs_relative!(robot, pattern, moved(position, side), was, possible_directions)
            move!(robot, inverse(side))
        end
    end
    push!(was, position, 2)
end

function can_go!(robot, side)
    return !isborder(robot, side)
end

function inverse(side :: HorizonSide)
    return HorizonSide(mod(Int(side) + 2, 4))
end

struct Task1 end

function was_at!(robot, pattern :: Task1, position :: RelativePosition)
    if position.dx == 0 || position.dy == 0
        putmarker!(robot)
    end
end

struct Task2 end

function was_at!(robot, pattern :: Task2, position :: RelativePosition)
    for i in [Nord, Sud, Ost, West]
        if isborder(robot, i)
            putmarker!(robot)
        end
    end
end

struct Task3 end

function was_at!(robot, pattern :: Task3, position :: RelativePosition)
    putmarker!(robot)
end

struct Task4
end

function was_at!(robot, pattern :: Task4, position :: RelativePosition)
    if abs(position.dx) == abs(position.dy)
        putmarker!(robot)
    end
end

struct Task5 end

function was_at!(robot, pattern :: Task5, position :: RelativePosition)
    for i in [Nord, Sud, Ost, West]
        if isborder(robot, i)
            putmarker!(robot)
        end
    end
end