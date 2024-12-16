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

mutable struct GridNode
    score::Int
    out1::Union{GridNode,Nothing}
    out2::Union{GridNode,Nothing}
    turn::Union{GridNode,Nothing}
end

function has_to_turn(tag::Char, direction::Direction)
    return (tag == 'H' && direction in (N, S)) || (tag == 'V' && direction in (E, W))
end

function dir_to_tag(direction::Direction)
    return direction in (N, S) ? 'V' : 'H'
end

const TaggedPoint = Tuple{Point,Char}

# Two nodes corresponding to the horizontal and vertical traversal of the grid cell.
# Given a grid like this:
# . X .
# A G B
# . Y .
# The following represents cell G
#  +------|----|----+
#  |      |    |    |
#  |      |  +---+  |
#  |   +--+  | V |  |
#  |   |     +---+  |
#  | +-|-+     |    |
# ---| H |-------------
#  | +---+     |    |
#  |           |    |
#  +-----------|----+
#              |
#
# A is connected to B via H, and X is connected to Y via V.
# A is connected to X via the turn edge in H, and B is connected to Y via the turn edge in V.
# Thus given a node, the out edges have score 1, the turn edges have score 1001.
function create_graph(puzzle::Puzzle)
    nodes = Dict{TaggedPoint, GridNode}()
    rows, columns = size(puzzle.grid)
    # Inialize scores in each node to a large number (simulating infinity)
    max_score = rows * columns * 1000 * 1000
    # Ignore the outer walls
    for i in 2:rows-1
        for j in 2:columns-1
            pos = (i, j)
            # Ignore inner walls
            puzzle.grid[i, j] == '#' && continue

            # For the current position, create one node for horizontal and one for vertical
            # traversal. Also, link the nodes with their appropriate "previous" nodes
            # Horizontal traversal:
            left = pos + W
            prev = get(nodes, (left, 'H'), nothing)
            nodeH = GridNode(max_score, prev, nothing, nothing)
            isnothing(prev) || (prev.out2 = nodeH)
            # Vertical traversal:
            top = pos + N
            prev = get(nodes, (top, 'V'), nothing)
            nodeV = GridNode(max_score, prev, nothing, nothing)
            isnothing(prev) || (prev.out2 = nodeV)
            # Link the nodes with their appropriate "turn" nodes
            nodeH.turn = nodeV
            nodeV.turn = nodeH

            nodes[pos, 'H'] = nodeH
            nodes[pos, 'V'] = nodeV

            # The source node has a score of 0
            pos == puzzle.start && (nodeH.score = 0)
        end
    end
    return nodes
end

function shortest_path!(puzzle::Puzzle, nodes::Dict{TaggedPoint,GridNode})
    visited = Set{Point}()
    unvisited = map(k -> (k[1], k[2], nodes[k]), collect(keys(nodes)))
    prev = Dict{TaggedPoint,TaggedPoint}()
    while true
        isempty(unvisited) && break
        sort!(unvisited; by = node -> node[3].score, rev = true)

        pos, tag, node = pop!(unvisited)
        pos == puzzle.stop && break
        push!(visited, pos)

        for dir in (N, S, E, W)
            neighbor = pos + dir
            neighbor in visited && continue
            neighbor_tag = dir_to_tag(dir)
            neighbor_node = get(nodes, (neighbor, neighbor_tag), nothing)
            isnothing(neighbor_node) && continue

            new_score = node.score + (has_to_turn(tag, dir) ? 1001 : 1)
            if new_score < neighbor_node.score
                neighbor_node.score = new_score
                prev[neighbor, neighbor_tag] = (pos, tag)
            end
        end
    end
    return prev
end

############################################################################################

module Part1
    using ..AoC_24_Day16: Puzzle, create_graph, shortest_path!

    function solve(puzzle::Puzzle)
        nodes = create_graph(puzzle)
        shortest_path!(puzzle, nodes)
        return min(nodes[puzzle.stop, 'H'].score, nodes[puzzle.stop, 'V'].score)
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day16: Puzzle, TaggedPoint, create_graph, shortest_path!

    function solve(puzzle::Puzzle)
        nodes = create_graph(puzzle)
        prev = shortest_path!(puzzle, nodes)

        stopH = nodes[puzzle.stop, 'H']
        stopV = nodes[puzzle.stop, 'V']
        min_score = min(stopH.score, stopV.score)
        min_tag = stopH.score == min_score ? 'H' : 'V'

        working_set = Set{TaggedPoint}()
        if stopH.score == min_score
            push!(working_set, (puzzle.stop, 'H'))
        end
        if stopV.score == min_score
            push!(working_set, (puzzle.stop, 'V'))
        end

        # Use prev from Dijkstra's algorithm to find the shortest path
        # Extend with alternative turns to discover all shortest paths
        while !isempty(working_set)
            curr_pos, curr_tag = pop!(working_set)
            puzzle.grid[curr_pos...] = '*'

            haskey(prev, (curr_pos, curr_tag)) || continue
            p, tag = prev[curr_pos, curr_tag]
            puzzle.grid[p...] = '*'
            push!(working_set, (p, tag))

            # If the previous node is on a turn, check if the node straight ahead of current
            # is also valid based on the score.
            if curr_tag != tag
                diff = p - curr_pos
                alt = curr_pos + diff + diff
                alt_node = get(nodes, (alt, curr_tag), nothing)
                isnothing(alt_node) && continue
                alt_node.score != nodes[curr_pos, curr_tag].score - 2 && continue
                push!(working_set, (alt, curr_tag))
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
