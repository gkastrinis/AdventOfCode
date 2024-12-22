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
        score = 0
        for seed in puzzle.seeds
            secret = seed
            for _ in 1:loops
                secret = monkey_rand(secret)
            end
            score += secret
        end
        return score
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day22: Puzzle, monkey_rand

    const Changes4 = Tuple{Int, Int, Int, Int}

    function solve(puzzle::Puzzle, num_changes::Int)
        all_changes = Dict{Changes4, Int}()
        for seed in puzzle.seeds
            changes = banana_changes(seed, num_changes+3)
            for (key, value) in changes
                prev_value = get(all_changes, key, 0)
                all_changes[key] = prev_value + value
            end
        end
        banana_gains = sort!(collect(values(all_changes)); rev=true)
        return banana_gains[1]
    end

    function banana_changes(secret::Int, loops::Int)
        all_changes = Dict{Changes4, Int}()
        bananas0 = secret % 10
        secret, bananas1 = monkey_rand_bananas(secret)
        secret, bananas2 = monkey_rand_bananas(secret)
        secret, bananas3 = monkey_rand_bananas(secret)
        for _ in 1:loops-4
            secret, bananas4 = monkey_rand_bananas(secret)
            changes = (bananas1 - bananas0, bananas2 - bananas1, bananas3 - bananas2, bananas4 - bananas3)
            if !haskey(all_changes, changes)
                all_changes[changes] = bananas4
            end
            bananas0 = bananas1
            bananas1 = bananas2
            bananas2 = bananas3
            bananas3 = bananas4
        end
        return all_changes
    end

    function monkey_rand_bananas(secret::Int)
        secret = monkey_rand(secret)
        return (secret, secret % 10)
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String, loops::Int) = Part1.solve(Puzzle(@filedata path), loops)
solve_part2(path::String, num_changes::Int) = Part2.solve(Puzzle(@filedata path), num_changes)

function test()
    for (path, args) in [
        ("example1.txt" => ((2000, 37327623), (2000, 24))),
        ("example2.txt" => ((2000, 37990510), (2000, 23))),
    ]
        args1, args2 = args
        loops1, expected1 = args1
        num_changes2, expected2 = args2
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path, loops1))
        test_assert("Part 2", expected2, solve_part2(path, num_changes2))
    end
    return nothing
end

end
