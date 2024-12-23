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
    return nothing
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
    using ..AoC_24_Day23: Node, Puzzle

    function solve(puzzle::Puzzle)
        t_nodes = filter(n -> n[1] == 't', puzzle.nodes)
        max_clique_size, max_clique_str = -1, ""
        # The nodes with the most neighbors are the most likely to be in a clique.
        nodes_by_edge_counts = sort!(collect(t_nodes); by = n -> length(puzzle.graph[n]), rev = true)
        for t_node in nodes_by_edge_counts
            clique_size, clique_str = find_max_clique(puzzle, t_node)
            clique_size == -1 && continue
            if max_clique_size == -1 || clique_size > max_clique_size
                max_clique_size = clique_size
                max_clique_str = clique_str
            end
        end
        return max_clique_str
    end

    function find_max_clique(puzzle::Puzzle, t_node::Node)
        neighbors = puzzle.graph[t_node]
        # +2 for the t_node and the neighbor itself
        neighbor_sizes = [((count_edges(puzzle, n, neighbors) + 2), n) for n in neighbors]
        sort!(neighbor_sizes, by = x -> x[1]; rev = true)

        # The max potential clique size is the number of neighbors + 1 (for the t_node itself)
        max_clique_size = length(neighbors) + 1
        for current_size in max_clique_size:-1:2
            potential_clique = @view neighbor_sizes[1:current_size-1]
            all(n -> n[1] == current_size, potential_clique) || continue
            # Add the t_node to the clique
            clique_nodes = sort!(vcat([n[2] for n in potential_clique], t_node))
            return (current_size, join(clique_nodes, ','))
        end
        return (-1, "")
    end

    function count_edges(puzzle::Puzzle, node::Node, nodes::AbstractVector{Node})
        neighbors = puzzle.graph[node]
        return count(n -> n in neighbors, nodes)
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (7, "co,de,ka,ta")),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
