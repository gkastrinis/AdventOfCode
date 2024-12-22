module AoC_24_Day22

include("../../AoC_Utils.jl")

struct Puzzle
    seeds::Vector{Int}
end

function Puzzle(input::String)
    return Puzzle(parse.(Int, split(input, "\n"; keepempty=false)))
end

function monkey_rand(secret::Int)
    secret = (secret ⊻ (secret * 64)) % 16777216
    secret = (secret ⊻ (secret ÷ 32)) % 16777216
    secret = (secret ⊻ (secret * 2048)) % 16777216
    return secret
end

############################################################################################

module Part1
    using ..AoC_24_Day22: Puzzle, monkey_rand

    function solve(puzzle::Puzzle, loops::Int)
        return sum(monkey_loop(seed, loops) for seed in puzzle.seeds)
    end

    function monkey_loop(seed::Int, loops::Int)
        for _ in 1:loops
            seed = monkey_rand(seed)
        end
        return seed
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day22: Puzzle

    function solve(puzzle::Puzzle)
        return nothing
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String, loops1::Int) = Part1.solve(Puzzle(@filedata path), loops1)
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => ((2000, 37327623), nothing)),
    ]
        args1, expected2 = args
        loops1, expected1 = args1
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path, loops1))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
