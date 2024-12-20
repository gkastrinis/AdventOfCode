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
    '*' => :blue,
    'X' => :red,
    '?' => :yellow
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

############################################################################################

module Part1
    using ..AoC_Utils: Point, N, S, E, W
    using ..AoC_24_Day20: Puzzle, pretty_print, collect_path, in_racetrack, debug_cheats

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
end

############################################################################################

module Part2
    using ..AoC_Utils: Point, N, S, E, W, manhattan_distance
    using ..AoC_24_Day20: Puzzle, pretty_print, collect_path, in_racetrack, debug_cheats

    function solve(puzzle::Puzzle, n_cheats::Int, threshold::Int)
        path, path_indexes = collect_path(puzzle.grid, puzzle.start, puzzle.stop)
        cheats = Set{Tuple{Point,Point}}()
        for p in path
            search_box(puzzle, path_indexes, p, n_cheats, threshold, cheats)
        end
        # debug_cheats(puzzle, ci.cheats)
        return length(cheats)
    end

    function search_box(puzzle::Puzzle, path_indexes::Dict{Point,Int}, path_pos::Point, n_cheats::Int, threshold::Int, cheats::Set{Tuple{Point,Point}})
        top = path_pos + N * n_cheats
        bottom = path_pos + S * n_cheats
        left = path_pos + W * n_cheats
        right = path_pos + E * n_cheats

        path_spaces = Set{Point}()
        for i in top[1]:bottom[1], j in left[2]:right[2]
            dist = manhattan_distance((i, j), path_pos)
            (in_racetrack(puzzle.grid, (i, j)) && dist <= n_cheats) || continue
            puzzle.grid[i, j] != '#' && push!(path_spaces, (i, j))
        end

        for dir in (N, S, E, W)
            cheat_start = path_pos + dir
            in_racetrack(puzzle.grid, cheat_start) || continue
            for path_stop in path_spaces
                for dir in (N, S, E, W)
                    cheat_stop = path_stop + dir
                    in_racetrack(puzzle.grid, cheat_stop) || continue
                    saves = time_saves(path_pos, path_stop, cheat_start, cheat_stop, path_indexes, threshold)
                    saves <= 0 && continue
                    if path_pos > path_stop
                        push!(cheats, (path_stop, path_pos))
                    else
                        push!(cheats, (path_pos, path_stop))
                    end
                end
            end
        end
        return nothing
    end

    function time_saves(path_pos::Point, path_stop::Point, cheat_start::Point, cheat_stop::Point, path_indexes::Dict{Point,Int}, threshold::Int)
        saves = path_indexes[path_stop] - path_indexes[path_pos]
        saves -= manhattan_distance(cheat_start, cheat_stop) + 2
        return threshold <= saves ? saves : 0
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String, n_cheats::Int, threshold::Int) =
    Part1.solve(Puzzle(@filedata path), n_cheats, threshold)
solve_part2(path::String, n_cheats::Int, threshold::Int) =
    Part2.solve(Puzzle(@filedata path), n_cheats, threshold)

function test()
    for (path, args) in [
        ("example1.txt" => ((2, 2, 44), (20, 72, 29))),
        ("example1.txt" => ((2, 40, 2), (20, 74, 7))),
        ("example1.txt" => ((2, 64, 1), (20, 76, 3))),
        ("example1.txt" => ((2, 65, 0), (20, 77, 0))),
    ]
        args1, args2 = args
        n_cheats1, threshold1, expected1 = args1
        n_cheats2, threshold2, expected2 = args2
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path, n_cheats1, threshold1))
        test_assert("Part 2", expected2, solve_part2(path, n_cheats2, threshold2))
    end
    return nothing
end

end
