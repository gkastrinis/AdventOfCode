module AoC_24_Day18

include("../../AoC_Utils.jl")
using .AoC_Utils: Point, N, S, E, W

struct Puzzle
    corruptions::Vector{Point}
end

function Puzzle(input::String)
    corruptions = Vector{Point}()
    io = IOBuffer(input)
    while !eof(io)
        x, y = split(readline(io), ',')
        push!(corruptions, (parse(Int, y), parse(Int, x)))
    end
    return Puzzle(corruptions)
end

function prepare_grid(puzzle::Puzzle, size::Int, num_corruptions::Int)
    subcorruptions = @view puzzle.corruptions[1:num_corruptions]
    grid = Matrix{Char}(undef, size, size)
    for i in 1:size, j in 1:size
        grid[i, j] = '.'
    end
    for corruption in subcorruptions
        i, j = corruption
        grid[i+1, j+1] = '█'
    end
    return grid
end

const TO_COLOR = Dict('█' => :magenta, '#' => :magenta, '.' => :black, '*' => :yellow)

############################################################################################

function shortest_path!(grid::Matrix{Char}, start::Point, stop::Point)
    distances = Dict{Point,Int}()
    rows, columns = size(grid)
    # Inialize scores in each node to a large number (simulating infinity)
    max_score = rows * columns * 1000
    for i in 1:rows, j in 1:columns
        grid[i, j] == '█' && continue
        distances[i, j] = ((i, j) == start ? 0 : max_score)
    end

    visited = Set{Point}()
    previous = Dict{Point,Point}()
    found = false
    while true
        candidates = filter(pos -> !(pos in visited), collect(keys(distances)))
        isempty(candidates) && break
        # (position x distance)
        unvisited = map(k -> (k, distances[k]), candidates)
        # Sort by increasing distance
        sort!(unvisited; by = node -> node[2], rev = true)


        pos, distance = pop!(unvisited)
        if pos == stop
            found = distance != max_score
            break
        end
        push!(visited, pos)

        for dir in (N, S, E, W)
            neighbor = pos + dir
            neighbor in visited && continue
            neighbor_distance = get(distances, neighbor, nothing)
            isnothing(neighbor_distance) && continue
            new_distance = distance + 1
            if new_distance < neighbor_distance
                distances[neighbor] = new_distance
                previous[neighbor] = pos
            end
        end
    end

    path = get_path(previous, stop)
    return found, path, distances, previous
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

############################################################################################

module Part1
    using ..AoC_24_Day18: Puzzle, prepare_grid, shortest_path!

    function solve(puzzle::Puzzle, size::Int, num_corruptions::Int)
        grid = prepare_grid(puzzle, size, num_corruptions)
        start, stop = (1, 1), (size, size)
        _, _, distances, _ = shortest_path!(grid, start, stop)
        return distances[(size, size)]
    end
end

############################################################################################

module Part2
    using ..AoC_Utils: Point,pretty_print
    using ..AoC_24_Day18: Puzzle, prepare_grid, shortest_path!, TO_COLOR

    function show(grid::Matrix{Char})
        return nothing
        pretty_print(grid, true) do i, j
            ch = grid[i, j]
            color = (ch == '𝕏' ? :red : TO_COLOR[ch])
            printstyled(ch, ' '; color=color)
        end
    end

    function solve(puzzle::Puzzle, rows::Int, num_corruptions::Int)
        grid = prepare_grid(puzzle, rows, num_corruptions)
        start, stop = (1, 1), (rows, rows)
        _, path, _, _ = shortest_path!(grid, start, stop)

        fill_path!(grid, path)
        show(grid)

        i = j = 0
        next_index = num_corruptions + 1
        last_index = length(puzzle.corruptions)
        new_paths_counter = 0
        while next_index <= last_index
            i, j = puzzle.corruptions[next_index]
            next = (i+1, j+1)
            grid[next...] = '𝕏'
            show(grid)
            grid[next...] = '█'

            if next in path
                new_paths_counter += 1
                found, path, _, _ = shortest_path!(grid, start, stop)
                !found && break
                fill_path!(grid, path)
            end
            next_index += 1
        end
        return "$j,$i"
    end

    function fill_path!(grid::Matrix{Char}, path::Vector{Point})
        rows, columns = size(grid)
        for i in 1:rows, j in 1:columns
            grid[i, j] == '*' || continue
            grid[i, j] = '.'
        end
        for point in path
            grid[point...] = '*'
        end
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String, size::Int, num_corruptions::Int) =
    Part1.solve(Puzzle(@filedata path), size, num_corruptions)
solve_part2(path::String, size::Int, num_corruptions::Int) =
    Part2.solve(Puzzle(@filedata path), size, num_corruptions)

function test()
    for (path, args) in [
        ("example1.txt", ((7, 12, 22), (7, 12, "6,1"))),
    ]
        args1, arg2 = args
        size, num_corruptions, expected1 = args1
        size, num_corruptions, expected2 = arg2
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        size, num_corruptions, expected1 = args1
        test_assert("Part 1", expected1, solve_part1(path, size, num_corruptions))
        test_assert("Part 2", expected2, solve_part2(path, size, num_corruptions))
    end
    return nothing
end

end
