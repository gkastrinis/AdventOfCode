module AoC_24_Day20

include("../../AoC_Utils.jl")
import .AoC_Utils: pretty_print
using .AoC_Utils: Point, read_grid

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

############################################################################################

using .AoC_Utils: N, S, E, W
using DataStructures: MutableBinaryMinHeap, update!

function Base.isless(p1::Tuple{Point, Int}, p2::Tuple{Point, Int})
    return p1[2] < p2[2] || (p1[2] == p2[2] && p1[1] < p2[1])
end

function shortest_path!(grid::Matrix{Char}, start::Point, stop::Point)
    rows, columns = size(grid)
    # Inialize scores in each node to a large number (simulating infinity)
    max_score = rows * columns * 1000

    # Use a heap to store nodes and distances, to retrieve the min node each time
    # Use a dict from node to heap handle to update the heap
    # Use a dict from node to current min distance
    unvisited = MutableBinaryMinHeap{Tuple{Point, Int}}()
    handles = Dict{Point,Int}()

    for i in 1:rows, j in 1:columns
        grid[i, j] == '#' && continue
        pos = (i, j)
        dist = (pos == start ? 0 : max_score)
        h = push!(unvisited, (pos, dist))
        handles[pos] = h
    end

    visited = Set{Point}()
    previous = Dict{Point,Point}()
    path_score = max_score
    while true
        pos, distance = pop!(unvisited)
        if pos == stop
            path_score = distance
            break
        end
        push!(visited, pos)

        for dir in (N, S, E, W)
            neighbor = pos + dir
            neighbor in visited && continue
            neighbor_handle = get(handles, neighbor, nothing)
            isnothing(neighbor_handle) && continue
            new_distance = distance + 1
            if new_distance < unvisited[neighbor_handle][2]
                update!(unvisited, neighbor_handle, (neighbor, new_distance))
                previous[neighbor] = pos
            end
        end
    end

    path = get_path(previous, stop)
    return (path_score != max_score, path, path_score, previous)
end

function get_path(previous::Dict{Point,Point}, stop::Point)
    path = Vector{Point}()
    working_set = Set{Point}([stop])
    while !isempty(working_set)
        current = pop!(working_set)
        push!(path, current)
        prev = get(previous, current, nothing)
        isnothing(prev) && continue
        push!(working_set, prev)
    end
    return path
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

############################################################################################

module Part1
    using ..AoC_Utils: Point, N, S, E, W, in_bounds
    using ..AoC_24_Day20: Puzzle, pretty_print, shortest_path!

    function solve(puzzle::Puzzle, threshold::Int)
        # pretty_print(puzzle)
        _, path, path_score, _ = shortest_path!(puzzle.grid, puzzle.start, puzzle.stop)

        path_set = Set(path)
        cheat_pairs = Set{Tuple{Point,Point}}()
        for p in path
            for dir1 in (N, S, E, W)
                neighbor1 = p + dir1
                in_bounds(puzzle.grid, neighbor1) || continue
                puzzle.grid[neighbor1...] == '#' || continue

                for dir2 in (N, S, E, W)
                    neighbor2 = neighbor1 + dir2
                    in_bounds(puzzle.grid, neighbor2) || continue
                    puzzle.grid[neighbor2...] != '#' || continue
                    neighbor2 != p || continue
                    neighbor2 in path_set || continue

                    k = findfirst(==(p), path)
                    l = findfirst(==(neighbor2), path)

                    saves = k - l - 2
                    saves > 0 || continue
                    saves >= threshold || continue


                    # l > k && continue
                    # k - l <= 2 && continue
                    # k - l >= threshold || continue

                    # println("checking cheating $p with $neighbor1 to $neighbor2 -- $saves")

                    pair = (neighbor1 > neighbor2 ? (neighbor1, neighbor2) : (neighbor2, neighbor1))
                    push!(cheat_pairs, pair)
                end
            end
        end
        i = 0
        # for pair in cheat_pairs
        #     i += 1
        #     a, b = puzzle.grid[pair[1]...], puzzle.grid[pair[2]...]
        #     puzzle.grid[pair[1]...] = 'X'
        #     puzzle.grid[pair[2]...] = 'X'
        #     pretty_print(puzzle)
        #     puzzle.grid[pair[1]...] = a
        #     puzzle.grid[pair[2]...] = b
        #     i > 10 && break
        # end
        # println(length(cheat_pairs))
        # println(cheat_pairs)
        # pretty_print(puzzle)
        # println(path_score)
        # println(length(path))
        # println(path)
        return length(cheat_pairs)
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

solve_part1(path::String, threshold::Int) = Part1.solve(Puzzle(@filedata path), threshold)
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => ((44, 2), nothing)),
        ("example1.txt" => ((2, 40), nothing)),
        ("example1.txt" => ((1, 64), nothing)),
        ("example1.txt" => ((0, 65), nothing)),
    ]
        args1, args2 = args
        expected1, threshold = args1
        expected2 = args2
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path, threshold))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
