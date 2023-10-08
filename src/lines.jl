using HorizonSideRobots

inverse(side :: HorizonSide) = HorizonSide(mod(Int(side) + 2, 4))
inverse(side) = (inverse(side[1]), inverse(side[2]))
left(side :: HorizonSide) = HorizonSide(mod(Int(side) + 1, 4))
right(side :: HorizonSide) = HorizonSide(mod(Int(side) + 3, 4))

function distance(r, side)
   if isborder(r, side)
       return 0
   else
       move!(r, side)
       res = distance(r, side) + 1
       move!(r, inverse(side))
       return res
   end
end

function HorizonSideRobots.move!(robot, side)
    move!(robot, side[1])
    move!(robot, side[2])
end


function HorizonSideRobots.isborder(robot, side)
    if isborder(robot, side[1])
        return true
    else
        move!(robot, side[1])
        res = isborder(robot, side[2])
        move!(robot, inverse(side[1]))
        return res
    end
end

function move_n!(robot, side, n)
    print(side)
    print(n)
    while n > 0
        move!(robot, side)
        n -= 1
    end
end

function move_n_f!(should_stop, robot, side, n)
    print(side)
    print(n)
    while n > 0 && !should_stop()
        move!(robot, side)
        n -= 1
    end
end


function move_n!(robot, side, distance, mark)
   if distance != 0
        move!(robot, side)
        if mark
            putmarker!(robot)
        end
        move_n!(robot, side, distance - 1, mark)
   end
end

function mark_crest(robot)
    putmarker!(robot)
    for side in [Nord, Ost, West, Sud]
        dst = distance(robot, side)
        moveN!(robot, side, dst, true)
        moveN!(robot, inverse(side), dst, false)
    end
end

function mark_crest_diagonal(robot)
    putmarker!(robot)
    for side in [Nord, Sud]
        for side2 in [Ost, West]
            dst = distance(robot, (side, side2))
            moveN!(robot, (side, side2), dst, true)
            moveN!(robot, (inverse(side), inverse(side2)), dst, false)
        end    
    end
end

function mark_perimiter_and_return(robot)
    x = distance(robot, Nord)
    y = distance(robot, Ost)
    moveN!(robot, Nord, x)
    moveN!(robot, Ost, y)

    xsize = distance(robot, Sud)
    ysize = distance(robot, West)
    
    moveN!(robot, West, ysize, true)
    moveN!(robot, Sud, xsize, true)
    moveN!(robot, Ost, ysize, true)
    moveN!(robot, Nord, xsize, true)

    
    moveN!(robot, Sud, x)
    moveN!(robot, West, y)
end

function move_along!(robot, side, should_mark = false)
    res = 0
    while !isborder(robot, side)
        res += 1
        move!(robot, side)
        if should_mark
            putmarker!(robot)
        end
    end
    return res
end

function go_to_corner(robot)
    res = Tuple{HorizonSide, Integer}[]
    while !isborder(robot, West) || !isborder(robot, Sud)
        for i in [West, Sud]
            push!(res, (i, move_along!(robot, i)))
        end
    end
    return res
end

function go_back(robot, path)
    for (side, i) in reverse(path)
        move_n!(robot, inverse(side), i)
    end
end

function mark_perimiter(robot)
    for side in [Nord, Ost, Sud, West]
        move_along!(robot, side, true)
    end
end

function shattle!(shourld_stop, robot, side)
    n = 1
    while !shourld_stop()
        move_n!(robot, side, n)
        n += 1
        side = inverse(side)
    end
end

function spiral!(shourld_stop, robot, side)
    n = 1
    while !shourld_stop()
        move_n_f!(shourld_stop, robot, side, n)
        side = left(side)
        move_n_f!(shourld_stop, robot, side, n)
        side = left(side)
        n += 1
    end
end

function snake!(f, robot, side, side2)
    f()
    while !isborder(robot, side2)
        move!(robot, side2)
        f()
    end
    while !isborder(robot, side)
        move!(robot, side)
        f()
        side2 = inverse(side2)
        while !isborder(robot, side2)
            move!(robot, side2)
            f()
        end
    end
end