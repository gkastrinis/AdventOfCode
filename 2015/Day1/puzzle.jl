module AoC_15_Day1

include("../../AoC_Utils.jl")

struct State
    input::String
end

############################################################################################

module Part1
    using ..AoC_15_Day1: State

    function solve(state::State)
        counter = 0
        for char in state.input
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
    using ..AoC_15_Day1: State

    function solve(state::State)
        counter = 0
        for i in 1:length(state.input)
            if state.input[i] == '('
                counter += 1
            elseif state.input[i] == ')'
                counter -= 1
            end
            counter == -1 && return i
        end
        return 0
    end
end

############################################################################################
############################################################################################

using .AoC_Utils: @filedata

solve_part1(path::String) = Part1.solve(State(@filedata path))
solve_part2(path::String) = Part2.solve(State(@filedata path))

end
