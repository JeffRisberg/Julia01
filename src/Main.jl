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
