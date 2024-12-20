module AoC_24_Day20

include("../../AoC_Utils.jl")
import .AoC_Utils: pretty_print
using .AoC_Utils: Point, N, S, E, W, read_grid

struct Puzzle
    grid::Matrix{Char}
    start::Point
    stop::Point
end

function Puzzle(input::String)
    rows = count(==('\n'), input)
    columns = findnext('\n', input, 1) - 1
    grid = Matrix{Char}(undef, rows, columns)
    start = stop = nothing
    grid = read_grid(IOBuffer(input), rows, columns) do i, j, ch
        if ch == 'S' start = (i, j)
        elseif ch == 'E' stop = (i, j)
        end
    end
    return Puzzle(grid, start, stop)
end

const TO_COLOR = Dict(
    'S' => :blue,
    'E' => :green,
    '█' => :magenta,
    '.' => :black,
    '*' => :yellow,
    'X' => :red
)

function AoC_Utils.pretty_print(puzzle::Puzzle)
    pretty_print(puzzle.grid, false) do i, j
        ch = puzzle.grid[i, j]
        ch == '#' && (ch = '█')
        printstyled(ch, ' '; color=TO_COLOR[ch])
    end
end

function collect_path(grid::Matrix{Char}, start::Point, stop::Point)
    path = Vector{Point}()
    path_indexes = Dict{Point,Int}()
    current, i = start, 0
    while current != stop
        push!(path, current)
        path_indexes[current] = i
        i += 1
        for dir in (N, S, E, W)
            next = current + dir
            in_racetrack(grid, next) || continue
            grid[next...] != '#' || continue
            !haskey(path_indexes, next) || continue
            current = next
            break
        end
    end
    push!(path, stop)
    path_indexes[stop] = i
    return path, path_indexes
end

function in_racetrack(grid::Matrix{Char}, point::Point)
    row, col = point
    return 1 < row < size(grid, 1) && 1 < col < size(grid, 2)
end

############################################################################################

module Part1
    using ..AoC_Utils: Point, N, S, E, W
    using ..AoC_24_Day20: Puzzle, pretty_print, collect_path, in_racetrack

    mutable struct CheatInfo
        grid::Matrix{Char}
        path::Vector{Point}
        path_indexes::Dict{Point,Int}
        threshold::Int
        cheats::Set{Tuple{Point,Point}}
    end

    function solve(puzzle::Puzzle, n_cheats::Int, threshold::Int)
        path, path_indexes = collect_path(puzzle.grid, puzzle.start, puzzle.stop)
        ci = CheatInfo(puzzle.grid, path, path_indexes, threshold, Set{Tuple{Point,Point}}())
        for p in path
            attempt_to_cheat(ci, p, n_cheats)
        end
        # debug_cheats(puzzle, ci.cheats)
        return length(ci.cheats)
    end

    function attempt_to_cheat(ci::CheatInfo, origin::Point, n_cheats::Int)
        for dir in (N, S, E, W)
            neighbor = origin + dir
            in_racetrack(ci.grid, neighbor) || continue
            ci.grid[neighbor...] == '#' || continue
            # Only start cheating if at a wall
            cheat(ci, origin, neighbor, n_cheats - 1)
        end
    end

    function cheat(ci::CheatInfo, origin::Point, position::Point, n_cheats::Int)
        if n_cheats == 0
            # Shouldn't end on a wall
            ci.grid[position...] == '#' && return
            # Shouldn't end on the origin
            position == origin && return
            # Should end at a point already in the path
            haskey(ci.path_indexes, position) || return
            # Cheating should only improve the path
            saves = ci.path_indexes[origin] - ci.path_indexes[position] - 2
            saves >= ci.threshold || return
            # Avoid duplicates
            pair = (origin > position ? (origin, position) : (position, origin))
            push!(ci.cheats, pair)
            return
        end

        for dir1 in (N, S, E, W)
            neighbor = position + dir1
            in_racetrack(ci.grid, neighbor) || continue
            cheat(ci, origin, neighbor, n_cheats - 1)
        end
    end

    function debug_cheats(puzzle::Puzzle, cheats::Set{Tuple{Point,Point}})
        for pair in cheats
            a, b = puzzle.grid[pair[1]...], puzzle.grid[pair[2]...]
            puzzle.grid[pair[1]...] = 'X'
            puzzle.grid[pair[2]...] = 'X'
            pretty_print(puzzle)
            puzzle.grid[pair[1]...] = a
            puzzle.grid[pair[2]...] = b
        end
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day20: Puzzle

    function solve(puzzle::Puzzle)
        return nothing
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String, n_cheats::Int, threshold::Int) =
    Part1.solve(Puzzle(@filedata path), n_cheats, threshold)
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => ((2, 2, 44), nothing)),
        ("example1.txt" => ((2, 40, 2), nothing)),
        ("example1.txt" => ((2, 64, 1), nothing)),
        ("example1.txt" => ((2, 65, 0), nothing)),
    ]
        args1, args2 = args
        n_cheats, threshold, expected1= args1
        expected2 = args2
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path, n_cheats, threshold))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
