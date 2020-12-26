#=
Main:
- Julia version: 1.5.3
- Author: jeff
- Date: 2020-12-25
=#

using Printf

for x = 1 : 1 : 10
    @printf("x %i\n", x)
    for y = 1 : 2 : 10
        @printf("y %i\n", y)
    end
end

x = Dict("a" => "A", "b" => "B", "c" => "C")

for (key, value) in x
    print(key); println(value)
end

v = Vector{Float64}()
append!(v, 0.5)
append!(v, rand(10))

for x in v
    println(x)
end

println("Bruce Wayne"[1:5])

v = ["one", "two", "three"]
append!(v, ["four"])

for x in v
    println(x)
end


