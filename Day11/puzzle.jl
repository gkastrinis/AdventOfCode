module AoC_24_Day11

include("../puzzle.jl")

struct State
    pebbles::Vector{Int}
end

function State(input::String)
    pebbles = [parse(Int, n) for n in split(input)]
    return State(pebbles)
end

function count_digits(n::Int)
    digits = 1
    while n >= 10
        n = n ÷ 10
        digits += 1
    end
    return digits
end

############################################################################################

module Part1
    using ..AoC_24_Day11: State, count_digits

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
    using ..AoC_24_Day11: State

    function solve(state::State, times::Int)
        return nothing
    end
end

############################################################################################
############################################################################################

Puzzle.solve_part1(data::String) = Part1.solve(State(data), 6)
Puzzle.solve_part2(data::String) = Part2.solve(State(data), 4)

solve_file(path::String) = Puzzle.solve_file(path)

function test()
    return test_harness([
        ("example1.txt" => ((6, 53), (nothing, nothing))),
        ("example2.txt" => ((6, 22), (nothing, nothing))),
        ("input.txt" => ((25, 172484), (nothing, nothing))),
    ])
end

function test_harness(facts)
    function assert_result(tag, expected, actual)
        if isnothing(expected)
            printstyled(tag, " ❔: nothing == $(actual)\n"; color=:magenta)
        elseif !isnothing(actual) && actual == expected
            printstyled(tag, " ✅: "; color=:green)
            printstyled(expected; color=:green)
            printstyled(" = "; color=:black)
            printstyled(actual, "\n"; color=:green)
        else
            printstyled(tag, " ❌: "; color=:red)
            printstyled(expected; color=:green)
            printstyled(" ≠ "; color=:black)
            printstyled(actual, "\n"; color=:red)
        end
        return nothing
    end

    for (file, params) in facts
        params1, params2 = params
        times1, expected1 = params1
        times2, expected2 = params2
        printstyled("--- testing: ", file, " ---\n"; color=:yellow)
        !isnothing(times1) && assert_result("Part 1 ($times1 times)", expected1, Part1.solve(State(read(file, String)), times1))
        !isnothing(times2) && assert_result("Part 2 ($times2 times)", expected2, Part1.solve(State(read(file, String)), times2))
    end
    return nothing
end

end
