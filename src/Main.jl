#=
Main:
- Julia version: 1.5.3
- Author: jeff
- Date: 2020-12-25
=#

# Numbers
count = 5
println(typeof(count))

value = 5.5
println(typeof(value))

value = 4 / 3
println(typeof(value))
println(value)

# Primitive functions on numbers
println(floor(value))

println(13 % 4)
println(mod(13,4))

println(pi)
println(sin(pi))
println(cos(pi))
println(tan(pi / 4))

# Strings
name = "Bruce Wayne"
println(typeof(name))

println(length(name))
println(name[1:5])

# Arrays

v = ["one", "two", "three"]
println(typeof(v))
append!(v, ["four"])

for x in v
    println(x)
end

v = ["one", false, 23]
println(typeof(v))
append!(v, ["four"])

for x in v
    println(x)
end

# Dictionaries
x = Dict("a" => "A", "b" => "B", "c" => "C")
println(typeof(x))

for (key, value) in x
    print(key); println(value)
end

# Vectors
v = Vector{Float64}()
println(typeof(v))

append!(v, 0.5)
append!(v, rand(4))

for x in v
    println(x)
end

# Formatted output
using Printf

value = 5.5
@printf("value %f\n", value)

# Control Structures

x= 5
if (x == 5)
    println("x is 5")
else
    println("x is not 5")
end

for x = 1 : 1 : 10
    @printf("x %i\n", x)
end


