module AoC_24_Day23

include("../../AoC_Utils.jl")

const Node = SubString{String}

struct Puzzle
    graph::Dict{Node, Vector{Node}}
    nodes::Set{Node}
end

function Puzzle(input::String)
    graph = Dict{Node, Vector{Node}}()
    nodes = Set{Node}()
    connections = split.(split(input, '\n'; keepempty=false), '-')
    for conn in connections
        @assert length(conn) == 2
        n1 = conn[1]
        n2 = conn[2]
        connect(graph, n1, n2)
        connect(graph, n2, n1)
        push!(nodes, n1)
        push!(nodes, n2)
    end
    for v in values(graph)
        sort!(v)
    end
    return Puzzle(graph, nodes)
end

function connect(graph::Dict{Node, Vector{Node}}, n1::Node, n2::Node)
    neighbors = get(graph, n1, [])
    push!(neighbors, n2)
    graph[n1] = neighbors
end

############################################################################################

module Part1
    using ..AoC_24_Day23: Node, Puzzle

    function solve(puzzle::Puzzle)
        t_nodes = filter(n -> n[1] == 't', puzzle.nodes)
        three_cliques = Set{Tuple{Node, Node, Node}}()
        for t_node in t_nodes
            neighbors = puzzle.graph[t_node]
            for i in 1:length(neighbors), j in (i + 1):length(neighbors)
                n1 = neighbors[i]
                n2 = neighbors[j]
                (n1 in puzzle.graph[n2]) || continue
                a, b, c = t_node, n1, n2
                a > b && ((a, b) = (b, a))
                b > c && ((b, c) = (c, b))
                a > b && ((a, b) = (b, a))
                push!(three_cliques, (a, b, c))
            end
        end
        return length(three_cliques)
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day23: Puzzle

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
        ("example1.txt" => (7, nothing)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
