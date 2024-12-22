module AoC_24_Day19

include("../../AoC_Utils.jl")

struct Puzzle
    patterns::Dict{Char,Vector{String}}
    designs::Vector{String}
end

function Puzzle(input::String)
    patterns_part, designs_part = split(input, "\n\n")
    designs = split(designs_part, "\n"; keepempty=false)
    patterns = Dict{Char,Vector{String}}()
    pattern_elements = split(patterns_part, ", ")
    for pattern in pattern_elements
        ch = pattern[1]
        v = get!(patterns, ch, Vector{String}())
        push!(v, pattern)
    end
    for (k, v) in patterns
        sort!(v; rev=true)
    end
    return Puzzle(patterns, designs)
end

############################################################################################

module Part1
    using ..AoC_24_Day19: Puzzle

    function solve(puzzle::Puzzle)
        return sum(is_design_possible(design, puzzle.patterns) ? 1 : 0 for design in puzzle.designs)
    end

    function is_design_possible(design::AbstractString, patterns::Dict{Char,Vector{String}})
        isempty(design) && return true
        valid_patterns = get(patterns, design[1], nothing)
        isnothing(valid_patterns) && return false
        for pattern in valid_patterns
            startswith(design, pattern) || continue
            is_design_possible(design[length(pattern)+1:end], patterns) && return true
        end
        return false
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day19: Puzzle

    function solve(puzzle::Puzzle)
        for (k, v) in puzzle.patterns
            sort!(v; lt=lt)
        end
        # Memoize the amount of solutions for a given design substring
        cache = Dict{String,Int}()
        return sum(count_alternatives(design, puzzle.patterns, cache) for design in puzzle.designs)
    end

    function count_alternatives(design::AbstractString, patterns::Dict{Char,Vector{String}}, cache::Dict{String,Int})
        isempty(design) && return 1
        valid_patterns = get(patterns, design[1], nothing)
        isnothing(valid_patterns) && return 0
        haskey(cache, design) && return cache[design]

        len = length(design)
        score = 0
        for pattern in valid_patterns
            length(pattern) > len && break
            startswith(design, pattern) || continue
            score += count_alternatives(design[length(pattern)+1:end], patterns, cache)
        end
        cache[design] = score
        return score
    end

    function lt(s1::String, s2::String)
        len1 = length(s1)
        len2 = length(s2)
        len1 < len2 && return true
        len1 == len2 && return s1 < s2
        return false
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (6, 16)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
