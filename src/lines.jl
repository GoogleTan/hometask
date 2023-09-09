inverse(side :: HorizonSide) = HorizonSide(mod(Int(side) + 2, 4))
inverse(side) = (inverse(side[1]), inverse(side[2]))


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



function moveN!(robot, side, distance, mark=false)
   if distance != 0
        move!(robot, side)
        if mark
            putmarker!(robot)
        end
        moveN!(robot, side, distance - 1, mark)
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