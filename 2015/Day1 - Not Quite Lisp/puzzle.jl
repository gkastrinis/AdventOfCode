module AoC_15_Day1

include("../../AoC_Utils.jl")

struct Puzzle
    input::String
end

############################################################################################

module Part1
    using ..AoC_15_Day1: Puzzle

    function solve(puzzle::Puzzle)
        counter = 0
        for char in puzzle.input
            if char == '('
                counter += 1
            elseif char == ')'
                counter -= 1
            end
        end
        return counter
    end
end

############################################################################################

module Part2
    using ..AoC_15_Day1: Puzzle

    function solve(puzzle::Puzzle)
        counter = 0
        for i in 1:length(puzzle.input)
            if puzzle.input[i] == '('
                counter += 1
            elseif puzzle.input[i] == ')'
                counter -= 1
            end
            counter == -1 && return i
        end
        return 0
    end
end

############################################################################################

using .AoC_Utils: @filedata

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

end
