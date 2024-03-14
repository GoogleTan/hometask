struct Dual{T}
    a :: T
    b :: T
end
 
Base.:(+)(a :: Dual{T}, b :: Dual{T}) where T = Dual(a.a + b.a, a.b + b.b)
Base.:(+)(a :: Dual{T}, b :: T) where T = Dual(a.a + b, a.b)
Base.:(+)(a :: T, b :: Dual{T}) where T = Dual(a + b.a, b.b)

Base.:(-)(a :: Dual) = Dual(-a.a, -a.b)
Base.:(-)(a :: Dual{T}, b :: Dual{T}) where T = a + (-b)
Base.:(-)(a :: Dual{T}, b :: T) where T = a + Dual(b, zero(T))
Base.:(-)(a :: T, b :: Dual{T}) where T = Dual(a, zero(T)) + b

Base.:(*)(a :: Dual{T}, b :: Dual{T}) where T =  Dual(a.a * b.a, a.a * b.b + a.b * b.a)
Base.:(*)(a :: T, b :: Dual{T}) where T =  Dual(a * b.a, a * b.b)
Base.:(*)(a :: Dual{T}, b :: T) where T =  Dual(a.a * b, a.b * b)

Base.:(/)(a :: Dual{T}, b :: Dual{T}) where T =  Dual(a.a / b.a, (a.b * b.a - a.a * b.b) / (b.a * b.a))
Base.:(/)(a :: T, b :: Dual{T}) where T =  Dual(a, zero(T)) / b
Base.:(/)(a :: Dual{T}, b :: T) where T =  a / Dual(b, zero(T))
 
function Base.show(io::IO, a :: Dual)
    f = a.a
    s = a.b
    print(io, "$f + $s ε")
end
 
println(Dual{Int}(3, -5))
