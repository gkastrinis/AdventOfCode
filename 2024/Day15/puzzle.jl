module AoC_24_Day15
include("../../AoC_Utils.jl")

import .AoC_Utils: pretty_print
using .AoC_Utils: AoC_Utils, Point, Direction, N, E, S, W

const SYMBOL_TO_DIR = Dict('^' => N, 'v' => S, '>' => E, '<' => W)

mutable struct Puzzle
    matrix::Matrix{Char}
    robot::Point
    moves::Vector{Direction}
end

function Puzzle(input::String)
    columns = findnext('\n', input, 1) - 1
    i, _ = findfirst("\n\n", input)
    rows = count(==('\n'), (@view input[1:i]))
    matrix = Matrix{Char}(undef, rows, columns)
    robot = (0, 0)
    moves = Vector{Direction}()
    i = j = 1
    io = IOBuffer(input)
    while !eof(io)
        ch = read(io, Char)
        ch == '@' && (robot = (i, j))

        if ch == '\n'
            i += 1
            j = 1
        else
            matrix[i, j] = ch
            j += 1
        end
        i > rows && break
    end
    while !eof(io)
        ch = read(io, Char)
        ch == '\n' && continue
        push!(moves, SYMBOL_TO_DIR[ch])
    end
    return Puzzle(matrix, robot, moves)
end

const SYMBOL_TO_COLOR = Dict('O' => :yellow, '#' => :magenta, '@' => :blue, '.' => :black)

function AoC_Utils.pretty_print(puzzle::Puzzle)
    return nothing
    pretty_print(puzzle.matrix, true) do i, j
        ch = puzzle.matrix[i, j]
        printstyled(ch, ' '; color=SYMBOL_TO_COLOR[ch])
    end
end

############################################################################################

module Part1
    using ..AoC_Utils: Point, Direction, DIR_TO_SYMBOL
    using ..AoC_24_Day15: Puzzle, pretty_print

    function solve(puzzle::Puzzle)
        pretty_print(puzzle)
        for direction in puzzle.moves
            move(puzzle, direction)
            pretty_print(puzzle)
        end
        return get_GPS_score(puzzle.matrix)
    end

    function move(puzzle::Puzzle, direction::Direction)
        m = puzzle.matrix
        robot = puzzle.robot
        next = robot + direction
        m[next...] == '#' && return nothing
        if m[next...] == 'O'
            next_empty_space = move_boxes(m, next, direction)
            if isnothing(next_empty_space)
                return robot
            end
            m[next_empty_space...], m[next...] = m[next...], m[next_empty_space...]
        end
        m[robot...], m[next...] = m[next...], m[robot...]
        puzzle.robot = next
        return next
    end

    function move_boxes(m::Matrix{Char}, pos::Point, direction::Direction)
        while m[pos...] != '#'
            next = pos + direction
            m[next...] == '.' && return next
            pos = next
        end
        return nothing
    end

    function get_GPS_score(m::Matrix{Char})
        score = 0
        for i in 1:size(m, 1)
            for j in 1:size(m, 2)
                m[i, j] == 'O' || continue
                score += 100 * (i-1) + (j-1)
            end
        end
        return score
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day15: Puzzle

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
        ("example1.txt" => (10092, nothing)),
        ("example2.txt" => (2028, nothing)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
