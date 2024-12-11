module AoC_24_Day11

include("../aoc_utils.jl")

struct State
    pebbles::Vector{Int}
end

function State(input::String)
    pebbles = [parse(Int, n) for n in split(input)]
    return State(pebbles)
end

############################################################################################

module Part1
    using ..AoC_Utils: count_digits
    using ..AoC_24_Day11: State

    function solve(state::State, times)
        for _ in 1:times
            blink(state)
        end
        return length(state.pebbles)
    end

    function blink(state::State)
        i = 1
        len = length(state.pebbles)
        while true
            i > len && break
            pebble = state.pebbles[i]
            num_digits = count_digits(pebble)
            if pebble == 0
                state.pebbles[i] = 1
            elseif num_digits % 2 == 0
                ten_power = 10^(num_digits ÷ 2)
                left = pebble ÷ ten_power
                right = pebble - left * ten_power
                state.pebbles[i] = left
                insert!(state.pebbles, i + 1, right)
                len += 1
                i += 2
                continue
            else
                state.pebbles[i] = pebble * 2024
            end
            i += 1
        end
        return nothing
    end
end

############################################################################################

module Part2
    using ..AoC_Utils: count_digits
    using ..AoC_24_Day11: State

    function solve(state::State, times::Int)
        memoized = Dict{Tuple{Int, Int}, Int}()
        score = sum(blink_pebble(p, times, memoized) for p in state.pebbles)
        printstyled("memoized hits: ", hits, "\n"; color=:blue)
        return score
    end

    hits::Int = 0

    function blink_pebble(pebble::Int, times::Int, memoized::Dict{Tuple{Int, Int}, Int})
        score = 0
        num_digits = count_digits(pebble)

        if times == 0
            score = 1
        elseif haskey(memoized, (pebble, times))
            global hits
            hits += 1
            score = memoized[(pebble, times)]
        elseif pebble == 0
            score = blink_pebble(1, times - 1, memoized)
        elseif num_digits % 2 == 0
            ten_power = 10^(num_digits ÷ 2)
            left = pebble ÷ ten_power
            right = pebble - left * ten_power
            score = blink_pebble(left, times - 1, memoized) +
                    blink_pebble(right, times - 1, memoized)
        else
            score = blink_pebble(pebble * 2024, times - 1, memoized)
        end

        memoized[(pebble, times)] = score
        return score
    end
end

############################################################################################
############################################################################################

using .AoC_Utils: file_data, test_assert

solve_part1(path::String, times::Int) = Part1.solve(State(file_data(path)), times)
solve_part2(path::String, times::Int) = Part2.solve(State(file_data(path)), times)
function solve_all(path::String, times::Int)
    printstyled("Part 1: "; color=:black)
    printstyled(Part1.solve(State(file_data(path)), times), "\n"; color=:blue)
    printstyled("Part 2: "; color=:black)
    printstyled(Part2.solve(State(file_data(path)), times), "\n"; color=:green)
    return nothing
end

function test()
    for (path, params) in [
        ("example1.txt" => ((6, 53), (75, 149161030616311))),
        ("example2.txt" => ((6, 22), (75, 65601038650482))),
        ("example3.txt" => ((6, 7), (75, 22840618691206))),
    ]
        params1, params2 = params
        t1, expected1 = params1
        t2, expected2 = params2
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        !isnothing(t1) && test_assert("Part 1 ($t1 times)", expected1, solve_part1(path, t1))
        !isnothing(t2) && test_assert("Part 2 ($t2 times)", expected2, solve_part2(path, t2))
    end
    return nothing
end

end
