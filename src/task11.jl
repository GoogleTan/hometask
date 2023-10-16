using HorizonSideRobots
include("lines.jl")


function task11(r)
    robot = r
    path = go_to_corner(r)
    res = count_walls(r)
    go_back(r, path)
    return res
end

function count_walls(robot)
    state = 0
    cnt = 0
    walk_side = Ost
    while !isborder(robot, walk_side)
        move!(robot, walk_side)
        if isborder(robot, Nord)
            if state == 0
                cnt += 1
            end
            state = 1
        else
            state = 0
        end
    end
    while !isborder(robot, Nord)
        move!(robot, Nord)
        walk_side = inverse(walk_side)
        while !isborder(robot, walk_side)
            move!(robot, walk_side)
            if isborder(robot, Nord)
            if state == 0
                cnt += 1
            end
            state = 1
        else
            state = 0
        end
        end
    end
    go_to_corner(r)
    return cnt - 1 # мы ещё по ошибке считаем паотолок. Его надо вычесть
end