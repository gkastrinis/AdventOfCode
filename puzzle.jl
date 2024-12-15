module AoC_YY_DayX

include("../../AoC_Utils.jl")

struct Puzzle
end

function Puzzle(input::String)
    return Puzzle()
end

############################################################################################

module Part1
    using ..AoC_YY_DayX: Puzzle

    function solve(puzzle::Puzzle)
        return nothing
    end
end

############################################################################################

module Part2
    using ..AoC_YY_DayX: Puzzle

    function solve(puzzle::Puzzle)
        return nothing
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (nothing, nothing)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
