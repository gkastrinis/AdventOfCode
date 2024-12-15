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

function get_GPS_score(m::Matrix{Char}, target::Char)
    score = 0
    for i in 1:size(m, 1)
        for j in 1:size(m, 2)
            m[i, j] == target || continue
            score += 100 * (i-1) + (j-1)
        end
    end
    return score
end

const SYMBOL_TO_COLOR = Dict(
    'O' => :yellow,
    '#' => :magenta,
    '@' => :blue,
    '.' => :black,
    '[' => :yellow,
    ']' => :yellow,
)

function AoC_Utils.pretty_print(puzzle::Puzzle)
    return nothing
    pretty_print(puzzle.matrix, false) do i, j
        ch = puzzle.matrix[i, j]
        printstyled(ch, ' '; color=SYMBOL_TO_COLOR[ch])
    end
end

############################################################################################

module Part1
    using ..AoC_Utils: Point, Direction, DIR_TO_SYMBOL
    using ..AoC_24_Day15: Puzzle, get_GPS_score, pretty_print

    function solve(puzzle::Puzzle)
        pretty_print(puzzle)
        for direction in puzzle.moves
            move(puzzle, direction)
            pretty_print(puzzle)
        end
        return get_GPS_score(puzzle.matrix, 'O')
    end

    function move(puzzle::Puzzle, direction::Direction)
        m = puzzle.matrix
        robot = puzzle.robot
        next = robot + direction
        m[next...] == '#' && return nothing
        if m[next...] == 'O'
            move_boxes(m, next, direction) || return robot
        end
        m[robot...], m[next...] = m[next...], m[robot...]
        puzzle.robot = next
        return nothing
    end

    function move_boxes(m::Matrix{Char}, pos::Point, direction::Direction)
        origin = pos
        while m[pos...] != '#'
            next = pos + direction
            if m[next...] == '.'
                m[next...], m[origin...] = m[origin...], m[next...]
                return true
            end
            pos = next
        end
        return false
    end
end

############################################################################################

module Part2
    using ..AoC_Utils: Point, Direction, N, E, S, W, DIR_TO_SYMBOL
    using ..AoC_24_Day15: Puzzle, get_GPS_score, pretty_print

    function solve(puzzle::Puzzle)
        widen_map!(puzzle)
        pretty_print(puzzle)
        for direction in puzzle.moves
            move(puzzle, direction)
            pretty_print(puzzle)
        end
        return get_GPS_score(puzzle.matrix, '[')
    end

    function move(puzzle::Puzzle, direction::Direction)
        m = puzzle.matrix
        robot = puzzle.robot
        next = robot + direction
        if m[next...] in ('[', ']', '.')
            points_to_move = if direction == E || direction == W
                horizontal_points_to_move(m, robot, direction)
            else
                vertical_points_to_move(m, [robot], direction)
            end
            isempty(points_to_move) && return nothing
            puzzle.robot = next

            for i in length(points_to_move):-1:1
                point = points_to_move[i]
                next = point + direction
                m[point...], m[next...] = m[next...], m[point...]
            end
        end
        return nothing
    end

    const EMPTY_POINTS = Point[]

    function horizontal_points_to_move(m::Matrix{Char}, point::Point, direction::Direction)
        all_points = [point]
        while true
            next_point = point + direction
            # Look straight ahead of the current position
            ch = m[next_point...]
            ch == '#' && return EMPTY_POINTS
            # Next point is empty to move into
            ch == '.' && return all_points
            push!(all_points, next_point)
            if ch == '['
                next_point += E
            else # ch == ']'
                next_point += W
            end
            push!(all_points, next_point)
            point = next_point
        end
    end

    function vertical_points_to_move(m::Matrix{Char}, points::Vector{Point}, direction::Direction)
        all_points = points
        while true
            new_points = Vector{Point}()
            for point in points
                next = point + direction
                # Look straight ahead of the current position
                ch = m[next...]
                ch == '#' && return EMPTY_POINTS
                ch == '.' && continue
                push!(new_points, next)
                if ch == '['
                    push!(new_points, next + E)
                else # ch == ']'
                    push!(new_points, next + W)
                end
            end
            # All next points are empty to move into
            isempty(new_points) && return all_points
            unique!(new_points)
            points = new_points
            append!(all_points, new_points)
        end
    end

    function widen_map!(puzzle::Puzzle)
        m = puzzle.matrix
        tile_mapping = Dict(
            '#' => ('#', '#'),
            'O' => ('[', ']'),
            '.' => ('.', '.'),
            '@' => ('@', '.'),
        )
        new_map = Matrix{Char}(undef, size(m, 1), size(m, 2) * 2)
        for i in 1:size(m, 1)
            for j in 1:size(m, 2)
                ch = m[i, j]
                new_tile1, new_tile2 = tile_mapping[ch]
                new_map[i, 2*j-1] = new_tile1
                new_map[i, 2*j] = new_tile2
            end
        end
        puzzle.matrix = new_map
        puzzle.robot = (puzzle.robot[1], 2 * puzzle.robot[2] - 1)
        return nothing
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (10092, 9021)),
        ("example2.txt" => (2028, 1751)),
        ("example3.txt" => (908, 618)),
        ("example4.txt" => (1717, 1734)),
        ("example5.txt" => (2913, 2530)),
        ("example6.txt" => (3922, 3251)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
