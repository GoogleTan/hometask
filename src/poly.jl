include("dial.jl")
struct Polynomial{T}
    # 1 x x^2 x^3...
    coeff :: Vector{T}

    function Polynomial{T}(arr) where T
        coeff = Vector(undef, length(arr))
        for i in 1:length(arr)
            coeff[i] = arr[i]
        end
        while length(coeff) != 0 && coeff[end] == zero(coeff[end])
            pop!(coeff)
        end
        new{T}(coeff)
    end
end

function (p :: Polynomial{T})(x) where T 
    res = p.coeff[1] * (x ^ 0)
    xx = 1
    for i = 2:length(p.coeff) 
        xx *= x
        res += p.coeff[i] * xx
    end
    res
end

function Base.:(+)(a :: Polynomial{T}, b :: Polynomial{T}) where T 
    coeffs = Vector{T}(undef, max(length(a.coeff), length(b.coeff)))
    for i in 1:length(coeffs)
        coeffs[i] = a.coeff[i] + b.coeff[i]
    end
    return Polynomial{T}(coeffs)
end

Base.:(-)(a :: Polynomial{T}) where T = Polynomial{T}(map((x) -> -x, a.coeff))
Base.:(-)(a :: Polynomial{T}, b :: Polynomial{T}) where T = a + (-b)

function Base.:(*)(a :: Polynomial{T}, b :: Polynomial{T}) where T 
    if length(a.coeff) == 0 
        return Polynomial([])
    end
    if length(b.coeff) == 0 
        return Polynomial([])
    end
    coeffs = repeat([zero(a.coeff[1])], length(a.coeff) * length(b.coeff))
    for i in 1:length(a.coeff)
        for j in 1:length(b.coeff)
            coeffs[i + j - 1] += a.coeff[i] * b.coeff[j]
        end
    end
    return Polynomial{T}(coeffs)
end
Base.:(*)(a :: Polynomial{T}, b :: T) where T = Polynomial{T}(map((x) -> x * b, a.coeff))
Base.:(*)(a :: T, b :: Polynomial{T}) where T = Polynomial{T}(map((x) -> x * a, b.coeff))
Base.:(/)(a :: Polynomial{T}, b :: T) where T = Polynomial{T}(map((x) -> x / b, a.coeff))


function up(a :: Polynomial{T}, value :: Int) where T
    return Polynomial{T}([repeat([zero(T)], value); a.coeff])
end

function add_last(a :: Polynomial{T}, value :: T) where T
    return Polynomial{T}([a.coeff; [value]]) 
end

function divrem(a :: Polynomial{T}, b :: Polynomial{T}) where T 
    if length(a.coeff) < length(b.coeff)
        return (Polynomial{T}([]), a)
    else
        c = up(b, length(a.coeff) - length(b.coeff))
        k = a.coeff[end] / c.coeff[end]
        (d, e) = divrem(a - (c  * k), b)
        return (add_last(d, k), e)
    end
end

function valdiv(a :: Polynomial{T}, x) where T <: Real
    if length(a.coeff) == zero(T)
        return (zero(T) * x, zero(T) * x)
    end
    value = zero(T) * x
    direv = zero(T) * x
    xp = zero(x)
    xx = one(x)
    for i = 1:length(a.coeff) 
        value += a.coeff[i] * xx
        direv += a.coeff[i] * (i - 1) * xp
        xp = xx
        xx *= x
    end
    (value, direv)
end

function Base.show(io::IO, a :: Polynomial{T}) where T
    if length(a.coeff) == zero(T)
        print(io, "0 * x^0")
    end
    for i in 1:length(a.coeff)
        value = a.coeff[i]
        if value != zero(value)
            if i != 1
                print(io, " + ")
            end
            j = i - 1
            print(io, "$value * x^$j")
        end
    end
end

function root(p :: Polynomial{Complex{T}}, start :: Complex{T}, tool :: AbstractFloat) :: Union{Complex{T}, Nothing} where T
    newton((x) -> p(x), start, epsilon = tool)
end

println(
    valdiv(
        Polynomial{Float64}([0, 0, 1]),
        1
    )
)
