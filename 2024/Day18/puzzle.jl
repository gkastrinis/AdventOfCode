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
    while true
        candidates = filter(pos -> !(pos in visited), collect(keys(distances)))
        isempty(candidates) && return (distances, previous, false)
        # (position x distance)
        unvisited = map(k -> (k, distances[k]), candidates)
        # Sort by increasing distance
        sort!(unvisited; by = node -> node[2], rev = true)


        pos, distance = pop!(unvisited)
        pos == stop && return (distances, previous, distance != max_score)
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
end

############################################################################################

module Part1
    using ..AoC_Utils: Point
    using ..AoC_24_Day18: Puzzle, prepare_grid, shortest_path!, TO_COLOR

    function solve(puzzle::Puzzle, size::Int, num_corruptions::Int)
        grid = prepare_grid(puzzle, size, num_corruptions)
        start, stop = (1, 1), (size, size)
        distances, _, _ = shortest_path!(grid, start, stop)
        return distances[(size, size)]
    end
end

############################################################################################

module Part2
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String, size::Int, num_corruptions::Int) =
    Part1.solve(Puzzle(@filedata path), size, num_corruptions)
solve_part2(path::String, size::Int, num_corruptions::Int) =
    Part2.solve(Puzzle(@filedata path), size, num_corruptions)

function test()
    for (path, args) in [
        ("example1.txt", ((7, 12, 22), nothing)),
    ]
        args1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        size, num_corruptions, expected1 = args1
        test_assert("Part 1", expected1, solve_part1(path, size, num_corruptions))
        test_assert("Part 2", expected2, solve_part2(path, size, num_corruptions))
    end
    return nothing
end

end
