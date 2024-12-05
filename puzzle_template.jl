module AoC_24_DayX

run(path::String) = solve(read(path, String))

function solve(input::String)
    x = preprocess(input)
    printstyled("Part 1: ", part1(x), "\n"; color=:yellow)
    printstyled("Part 2: ", part2(x), "\n"; color=:blue)
    return nothing
end

#
function part1(x)
    return nothing
end

#
function part2(x)
    return nothing
end

function preprocess(input::String)
    return nothing
end





end
