module AoC_24_Day25

include("../../AoC_Utils.jl")

const Pins = Tuple{Int, Int, Int, Int, Int}

struct Puzzle
    height::Int
    locks::Vector{Pins}
    keys::Vector{Pins}
end

function Puzzle(input::String)
    height = -1
    locks = Vector{Pins}()
    keys = Vector{Pins}()
    parts = split(input, "\n\n"; keepempty=false)
    for part in parts
        is_lock = startswith(part, "#####")
        pins = (-1, -1, -1, -1, -1)
        h = -1
        for line in split(part, "\n"; keepempty=false)
            pins += (f(line[1]), f(line[2]), f(line[3]), f(line[4]), f(line[5]))
            h += 1
        end
        height == -1 && (height = h)
        @assert height == h
        push!(is_lock ? locks : keys, pins)
    end
    return Puzzle(height, locks, keys)
end

f(c::Char) = c == '#' ? 1 : 0
Base.:+(a::Pins, b::Pins) = (a[1] + b[1], a[2] + b[2], a[3] + b[3], a[4] + b[4], a[5] + b[5])
Base.:<(a::Pins, b::Pins) = (a[1] < b[1]) && (a[2] < b[2]) && (a[3] < b[3]) && (a[4] < b[4]) && (a[5] < b[5])

############################################################################################

module Part1
    using ..AoC_24_Day25: Pins,Puzzle

    function solve(puzzle::Puzzle)
        max = (puzzle.height, puzzle.height, puzzle.height, puzzle.height, puzzle.height)
        matches = Set{Tuple{Pins, Pins}}()
        for lock in puzzle.locks
            for key in puzzle.keys
                comb = lock + key
                comb < max && push!(matches, (lock, key))
            end
        end
        return length(matches)
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day25: Puzzle

    function solve(puzzle::Puzzle)
        return missing
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (3, missing)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
