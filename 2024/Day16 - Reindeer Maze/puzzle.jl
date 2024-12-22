module AoC_24_Day16

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

const SYMBOL_TO_COLOR = Dict(
    '#' => :magenta,
    'S' => :blue,
    'E' => :green,
    '.' => :black,
    '*' => :red,
)

function AoC_Utils.pretty_print(puzzle::Puzzle)
    pretty_print(puzzle.grid, false) do i, j
        ch = puzzle.grid[i, j]
        printstyled(ch, ' '; color=SYMBOL_TO_COLOR[ch])
    end
end

############################################################################################

using .AoC_Utils: Direction, Point, N, S, E, W

function has_to_turn(tag::Char, direction::Direction)
    return (tag == 'H' && direction in (N, S)) || (tag == 'V' && direction in (E, W))
end

function dir_to_tag(direction::Direction)
    return direction in (N, S) ? 'V' : 'H'
end

const TaggedPoint = Tuple{Point,Char}

function initialize_distances(puzzle::Puzzle)
    distances = Dict{TaggedPoint,Int}()
    rows, columns = size(puzzle.grid)
    # Inialize scores in each node to a large number (simulating infinity)
    max_score = rows * columns * 1000 * 1000
    # Ignore the outer walls
    for i in 2:rows-1
        for j in 2:columns-1
            # Ignore inner walls
            puzzle.grid[i, j] == '#' && continue

            pos = (i, j)
            distances[pos, 'V'] = max_score
            # The source node has a score of 0, for horizontal traversals
            distances[pos, 'H'] = (pos == puzzle.start ? 0 : max_score)
        end
    end
    return distances
end

function shortest_path!(puzzle::Puzzle, distances::Dict{TaggedPoint,Int})
    visited = Set{Point}()
    prev = Dict{TaggedPoint,TaggedPoint}()
    while true
        candidates = filter(tagged_point -> !(tagged_point[1] in visited), collect(keys(distances)))
        isempty(candidates) && break
        # (position x tag x distance)
        unvisited = map(k -> (k[1], k[2], distances[k]), candidates)
        # Sort by increasing distance
        sort!(unvisited; by = node -> node[3], rev = true)

        pos, tag, distance = pop!(unvisited)
        pos == puzzle.stop && break
        push!(visited, pos)

        for dir in (N, S, E, W)
            neighbor = pos + dir
            neighbor in visited && continue
            tagged_neighbor = (neighbor, dir_to_tag(dir))
            neighbor_distance = get(distances, tagged_neighbor, nothing)
            isnothing(neighbor_distance) && continue
            new_distance = distance + (has_to_turn(tag, dir) ? 1001 : 1)
            if new_distance < neighbor_distance
                distances[tagged_neighbor] = new_distance
                prev[tagged_neighbor] = (pos, tag)
            end
        end
    end
    return prev
end

############################################################################################

module Part1
    using ..AoC_24_Day16: Puzzle, initialize_distances, shortest_path!, pretty_print

    function solve(puzzle::Puzzle)
        distances = initialize_distances(puzzle)
        shortest_path!(puzzle, distances)
        return min(distances[puzzle.stop, 'H'], distances[puzzle.stop, 'V'])
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day16: Puzzle, TaggedPoint, initialize_distances, shortest_path!

    function solve(puzzle::Puzzle)
        distances = initialize_distances(puzzle)
        prev = shortest_path!(puzzle, distances)

        # Use prev from Dijkstra's algorithm to find the shortest path
        # Extend with alternative turns to discover all shortest paths

        stop_distance_h = distances[puzzle.stop, 'H']
        stop_distance_v = distances[puzzle.stop, 'V']
        min_score = min(stop_distance_h, stop_distance_v)

        working_set = Set{TaggedPoint}()
        if stop_distance_h == min_score
            push!(working_set, (puzzle.stop, 'H'))
        end
        if stop_distance_v == min_score
            push!(working_set, (puzzle.stop, 'V'))
        end
        while !isempty(working_set)
            curr_pos, curr_tag = pop!(working_set)
            puzzle.grid[curr_pos...] = '*'

            prev_info = get(prev, (curr_pos, curr_tag), nothing)
            isnothing(prev_info) && continue
            prev_pos, prev_tag = prev_info
            push!(working_set, (prev_pos, prev_tag))

            # If the previous node is on a turn, check if the node straight ahead of current
            # is also valid based on the score.
            if curr_tag != prev_tag
                diff = prev_pos - curr_pos
                alt_pos = curr_pos + diff + diff
                alt_distance = get(distances, (alt_pos, curr_tag), nothing)
                alt_distance != distances[curr_pos, curr_tag] - 2 && continue
                push!(working_set, (alt_pos, curr_tag))
            end
        end
        return count(==('*'), puzzle.grid)
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (7036, 45)),
        ("example2.txt" => (11048, 64)),
        ("example3.txt" => (7019, 35)),
        ("example4.txt" => (3015, 16)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
