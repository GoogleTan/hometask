using Plots
struct Dual{T}
    a :: T
    b :: T
end

Base.:(+)(a :: Dual{T}, b :: Dual{T}) where T = Dual(a.a + b.a, a.b + b.b)
Base.:(+)(a :: Dual{T}, b :: T) where T = Dual(a.a + b, a.b)
Base.:(+)(a :: T, b :: Dual{T}) where T = Dual(a + b.a, b.b)
 
Base.:(-)(a :: Dual) = Dual(-a.a, -a.b)
Base.:(-)(a :: Dual{T}, b :: Dual{T}) where T = a + (-b)
Base.:(-)(a :: Dual{T}, b :: T) where T = a - Dual(b, zero(T))
Base.:(-)(a :: T, b :: Dual{T}) where T = Dual(a, zero(T)) + b
 
Base.:(*)(a :: Dual{T}, b :: Dual{T}) where T =  Dual(a.a * b.a, a.b * b.a + a.a * b.b)
Base.:(*)(a :: T, b :: Dual{T}) where T =  Dual(a * b.a, a * b.b)
Base.:(*)(a :: Dual{T}, b :: T) where T =  Dual(a.a * b, a.b * b)
 
Base.:(/)(a :: Dual{T}, b :: Dual{T}) where T =  Dual(a.a / b.a, (a.b * b.a - a.a * b.b) / (b.a * b.a))
Base.:(/)(a :: T, b :: Dual{T}) where T =  Dual(a, one(T)) / b
Base.:(/)(a :: Dual{T}, b :: T) where T =  a / Dual(b, one(T))
Base.:(/)(a :: Dual{T}, b) where T =  a / Dual(one(T) * b, one(T))
 
Base.:(sin)(a :: Dual{T}) where T = Dual(sin(a.a), (a.b) * cos(a.a))
Base.:(cos)(a :: Dual{T}) where T = Dual(cos(a.a), (a.b) * (-sin(a.a)))
Base.:(tan)(a :: Dual{T}) where T = sin(a) / cos(a.a)
Base.:(cot)(a :: Dual{T}) where T = cos(a) / sin(a.a)
Base.:(asin)(a :: Dual{T}) where T = Dual(asin(a.a), (a.b) * 1/(1-a.a*a.a))
Base.:(acos)(a :: Dual{T}) where T = Dual(acos(a.a), (a.b) * -1/(1-a.a*a.a))
Base.:(atan)(a :: Dual{T}) where T = Dual(atan(a.a), (a.b) * 1/(1+a.a*a.a))
Base.:(acot)(a :: Dual{T}) where T = Dual(acot(a.a), (a.b) * -1/(1+a.a*a.a))
Base.:(log)(a :: Dual{T}) where T = Dual(log(a.a), (a.b) * 1 / (a.a))
Base.:(log)(a :: AbstractFloat, b :: Dual{T}) where T = Dual(log(a, b.a), (b.b) / (b.a * log(a)))
Base.:(log2)(b :: Dual{T}) where T = log(2, b)
Base.:(log10)(b :: Dual{T}) where T = log(10, b)
Base.:(exp)(a :: Dual{T}) where T = Dual(exp(a.a), (a.b) * exp(a.a))     
Base.:(sqrt)(a :: Dual{T}) where T = Dual(sqrt(a.a), a.b / (2 * sqrt(a.a)))
 
Base.:(zero)(a :: Type{Dual{T}}) where T = Dual(zero(T), zero(T))
Base.:(one)(a :: Type{Dual{T}}) where T = Dual(one(T), zero(T))
 
Base.:^(x::Dual{T}, y::AbstractFloat) where T = Dual{T}(x.a^y, y*x.a^(y-1)*x.b) 
Base.:^(x::Dual{T}, y::Dual{T}) where T = Dual{T}(x.a^y.a, (y.a*x.b*x.a^(y.a-1) + x.a^y.a*log(x.a)*y.b)) 
Base.:^(x::Dual{T}, y::T) where T = Dual{T}(x.a^y, y*x.a^(y-1)*x.b) 
Base.:^(x::T, y::Dual{T}) where T = Dual{T}(x^y.a, y*x^(y.a-1)*x.b) 

Base.:zero(:: Type{Dual{T}}) where T  = Dual{T}(zero(T), zero(T))
Base.:iszero(a:: Dual{T}) where T  = iszero(a.a) && iszero(a.b)

function valdiff(f :: Function, x :: T) where T
    res = f(Dual(x, one(T)))
    return (res.a, res.b)
end
 
function Base.show(io::IO, a :: Dual)
    f = a.a
    s = a.b
    print(io, "$f + $s ε")
end
 
function newton(f :: Function, x :: T; epsilon = 1e-8, num_max = 10, valdiffIn :: Function = valdiff) where T
    currentX = x
    for i = 1:num_max 
        (value, dif) = valdiffIn(f, currentX)
        currentX = currentX - value / dif
        if abs(f(currentX)) < epsilon
            return currentX
        end
    end
    if abs(f(x) - zero(T)) < epsilon 
        @warn("Max iterations exceeded")
        return nothing
    end 
    currentX
end
 
function valdif_mathan(f, x) 
    df(x) = (f(x + 1e-5) - f(x)) / (1e-5)
    return (f(x), df(x))
end
 
 
function forth() 
    f(x) = x * x + 1.0 / (x * x * x * x * x * x) - 2.0
    pair(x) = (x, 1/(x * x * x))
    println(pair(newton(f, 5.0)))
    println(pair(newton(f, -5.0)))
    println(pair(newton(f, 0.5)))
    println(pair(newton(f, -0.5)))
end
 
function log(value, a, e)
    z = value
    t = 1.0
    y = 0.0
    while z < 1/a || z > a || t > e
        if z < 1/a
            z *= a
            y -= t
        elseif z > a
            z /= a
            y += t
        elseif t > e
            t /= 2
            z *= z
        end
    end
    return y
end 
 
function log2(value, a, e)
    if a < 1
        -log(value, 1/a, e)
    else
        log(value, a, e)
    end
end
 
function cos(x, n = 1000)
    res = 0
    i = n
    while i > 0
        res += 2 * x
        res *= x
        res /= 2 * i
        res /= 2 * i - 1
        i -= 1
    end
    res
end
 
function exp(x) 
    if x < 0
        return 1 / exp(-x)
    end
    res :: Float64 = 0
    a = 1
    i = 1
    while a != 0
        res += a
        a *= x / i
        i += 1
    end
    res
end

function j(A :: Int64, x :: T) where T
    res :: T = zero(T)
    a :: Float64 = float(A)
    d :: T = ((x / 2.0) ^ float(a)) / float(factorial(A))
    m = 1
    while !iszero(d)
        res = res + d
        d = d * -(x * x) / (4.0 * m * (m + a))
        m += 1
    end
    res
end

function j1(a :: Int64)
    (x) -> j(a, x)
end

function make_plot()
    xx = 0:0.01:10π

    yy = j1(0).(xx)
    p=plot(xx, yy) 
    
    yy2 = j1(1).(xx)
    p2=plot(xx, yy2) 

    yy3 = j1(2).(xx)
    p3=plot(xx, yy3) 

    plot!(p3, xx,yy)
    display(p) 
    display(p2) 
    display(p3) 
    
end

function jakobian(functions :: Vector{Function})
    res = Array{Function}(undef, functions.length(), functions.length())
    for i in 1:functions.length()
        for j in 1:functions.length()
            res[i, j] =  
        end
    end
end
