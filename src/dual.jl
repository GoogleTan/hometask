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

function newton(x :: T; epsilon = 1e-8, num_max = 10, valdiffIn :: Function) where T
    currentX = x
    for i = 1:num_max 
        currentX = currentX + valdiffIn(currentX)
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
 
function my_log(value, a, e)
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
        -my_log(value, 1/a, e)
    else
        my_log(value, a, e)
    end
end
 
function my_cos(x :: T, n = 10000000) where T
    res = zero(T)
    acc = one(T)
    for i in 1:n
        acc *= -(x * x) / (2.0 * float(i) * (2.0 * float(i) - 1.0))
        res += acc
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

function jakobian(functions :: Vector{Function}, args :: Vector{T})::Matrix{T} where T
    res = zeros(length(functions), length(functions))
    for i in eachindex(functions)
        for j in eachindex(functions)
            argsij = Vector{Union{Dual{T},T}}(args)
            argsij[j] = Dual{T}(argsij[j], one(T))
            res[i, j] =  functions[i](argsij...).b
        end
    end
    return res
end

function jakobian(functions :: Vector{Function}, args :: Matrix{T})::Matrix{T} where T
    res = zeros(length(functions), length(functions))
    for i in 1:length(functions)
        for j in 1:length(functions)
            argsij = Matrix{Union{Dual{T},T}}(args)
            argsij[j] = Dual{T}(argsij[j], one(T))
            res[i, j] =  functions[i](argsij...).b
        end
    end
    return res
end

function apply(functions :: Vector{Function}, args :: Matrix{T})::Matrix{T} where {T}
    res = zeros(T, length(functions), 1)
    for i in eachindex(functions)
        res[i] = functions[i](args...)
    end
    return res
end

function main()
    #1, 2
    println(newton(x -> cos(x) - x, 1.0))
    println(newton(
        1.0,
        valdiffIn = (x) -> - (cos(x) - x) / (-sin(x) - one(typeof(x)))
    ))
    println(newton(x -> my_cos(x) - x, 1.0, valdiffIn = valdif_mathan))
    println()
    # 3
    p = Polynomial{Complex{Float64}}([-1.0 + 0.0im, -3.0 + 0.0im, 5.0 + 0.2im, 1.0 + 0.0im])
    println(root(p, -2.0 + 0.0im, 0.001))
    println()

    #4
    functions = Vector{Function}([(x, y) -> x^2.0 + y^2.0 - 2.0, (x, y) -> x^3.0 * y - 1.0])
    initial = ones(Float64, 2, 1)
    initial[1, 1] = 2.0
    initial[2, 1] = 0.0
    println(
        newton(
            initial,
            valdiffIn = (args) -> -(jakobian(functions, args))\apply(functions, args),
        )
    )

    #5
    println(my_log(10.0, 3.0, 0.0001))
    println(log2(10.0, 1 / 3, 0.0001))
    println()

    #6, 7
    println(my_cos(4.0, 10))
    println(my_cos(4.0))

    #8
    println(exp(4.0))

    #9
    j1(a) = (x) -> j(a, x) 
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

    # 10
    println(newton(x -> jakobian(0, x), 1.0))
    println()
end
