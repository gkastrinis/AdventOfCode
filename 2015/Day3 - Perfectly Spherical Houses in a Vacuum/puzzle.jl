module AoC_15_Day3

include("../../AoC_Utils.jl")
using .AoC_Utils: Point

struct Puzzle
    input::String
end

function move(current::Point, char::Char)
    char == '^' && return current + (0, 1)
    char == 'v' && return current + (0, -1)
    char == '>' && return current + (1, 0)
    char == '<' && return current + (-1, 0)
    return current
end

############################################################################################

module Part1
    using ..AoC_Utils: Point
    using ..AoC_15_Day3: Puzzle, move

    function solve(puzzle::Puzzle)
        visited = Dict{Point,Int}()
        santa = (0, 0)
        visited[santa] = 1
        for ch in puzzle.input
            ch in ('^', 'v', '<', '>') || continue
            santa = move(santa, ch)
            visited[santa] = get(visited, santa, 0) + 1
        end
        return length(keys(visited))
    end
end

############################################################################################

module Part2
    using ..AoC_Utils: Point
    using ..AoC_15_Day3: Puzzle, move

    function solve(puzzle::Puzzle)
        visited = Dict{Point,Int}()
        santa = (0, 0)
        robo = (0, 0)
        visited[santa] = 2
        for (i, ch) in enumerate(puzzle.input)
            ch in ('^', 'v', '<', '>') || continue
            if i % 2 == 1
                santa = move(santa, ch)
                visited[santa] = get(visited, santa, 0) + 1
            else
                robo = move(robo, ch)
                visited[robo] = get(visited, robo, 0) + 1
            end
        end
        return length(keys(visited))
    end
end

end
