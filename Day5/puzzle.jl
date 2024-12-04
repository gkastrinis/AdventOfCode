module AoC_24_Day5

run_actual(path::String) = solve(read(path, String))

function run_example()
    input = """
..
"""
    return solve(input)
end

function prepare_input(input::String)
    return nothing
end

function solve(input::String)
    x = prepare_input(input)
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

end
