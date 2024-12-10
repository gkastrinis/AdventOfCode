module AoC_24_DayX

include("../puzzle.jl")

struct State
end

function State(input::String)
    return State()
end

############################################################################################

module Part1
    using ..AoC_24_DayX: State

    function solve(state::State)
        return nothing
    end
end

############################################################################################

module Part2
    using ..AoC_24_DayX: State

    function solve(state::State)
        return nothing
    end
end

############################################################################################
############################################################################################

Puzzle.solve_part1(data::String) = Part1.solve(State(data))
Puzzle.solve_part2(data::String) = Part2.solve(State(data))

solve_file(path::String) = Puzzle.solve_file(path)

function test()
    return Puzzle.test_harness([
        ("example1.txt" => (nothing, nothing)),
    ])
end

end
