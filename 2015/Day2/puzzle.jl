module AoC_15_Day2

include("../../AoC_Utils.jl")

using .AoC_Utils: next_int

struct Box
    length::Int
    width::Int
    height::Int
end

struct Puzzle
    boxes::Vector{Box}
end

function Puzzle(input::String)
    boxes = Box[]
    io = IOBuffer(input)
    while !eof(io)
        length = next_int(io)
        eof(io) && break
        # x
        read(io, Char)
        width = next_int(io)
        # x
        read(io, Char)
        height = next_int(io)

        push!(boxes, Box(length, width, height))
    end
    return Puzzle(boxes)
end

############################################################################################

module Part1
    using ..AoC_15_Day2: Puzzle

    function solve(puzzle::Puzzle)
        total = 0
        for box in puzzle.boxes
            total += 2 * (box.length * box.width + box.length * box.height + box.width * box.height)
        end
        return total
    end
end

############################################################################################

module Part2
    using ..AoC_15_Day2: Puzzle

    function solve(puzzle::Puzzle)
        total = 0
        for box in puzzle.boxes
            total += 2 * (box.length + box.width + box.height - max(box.length, box.width, box.height))
            total += box.length * box.width * box.height
        end
        return total
    end
end

############################################################################################

using .AoC_Utils: @filedata

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

end
