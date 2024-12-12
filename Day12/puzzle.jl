module AoC_24_Day12

include("../AoC_Utils.jl")

using .AoC_Utils: Point

struct State
    matrix::Matrix{Char}
    to_visit::Set{Point}
    visited::Set{Point}
end

function State(input::String)
    rows = count(==('\n'), input)
    columns = findnext('\n', input, 1) - 1
    total = rows * columns
    matrix = Matrix{Char}(undef, rows, columns)
    to_visit = Set{Point}()
    sizehint!(to_visit, total)
    visited = Set{Point}()
    sizehint!(visited, total)
    i = j = 1
    io = IOBuffer(input)
    while !eof(io)
        ch = read(io, Char)
        if ch == '\n'
            i += 1
            j = 1
        else
            matrix[i, j] = ch
            push!(to_visit, (i, j))
            j += 1
        end
    end
    return State(matrix, to_visit, visited)
end

############################################################################################

module Part1
    import ..AoC_Utils: in_bounds, pretty_print

    using ..AoC_Utils: AoC_Utils
    using ..AoC_24_Day12: Point, State

    function solve(state::State)
        score = 0
        while !isempty(state.to_visit)
            point = pop!(state.to_visit)
            area, perimeter = flood(state, state.matrix[point...], point)
            score += area * perimeter
        end
        pretty_print(state)
        return score
    end

    function flood(state::State, value::Char, point::Point)
        pretty_print(state)
        point in state.visited && return (0, 0)
        push!(state.visited, point)

        area_score = 1
        perimeter_score = 0
        local_perimeter = 4
        row, column = point
        for (i, j) in [(row-1, column), (row+1, column), (row, column-1), (row, column+1)]
            in_bounds(state, i, j) || continue
            state.matrix[i, j] == value || continue

            local_perimeter -= 1
            (i, j) in state.visited && continue
            delete!(state.to_visit, (i, j))

            area, perimeter = flood(state, value, (i, j))
            area_score += area
            perimeter_score += perimeter
        end
        return (area_score, perimeter_score + local_perimeter)
    end

    function AoC_Utils.in_bounds(state::State, row::Int, column::Int)
        return in_bounds(state.matrix, row, column)
    end

    function AoC_Utils.pretty_print(state::State)
        return nothing
        pretty_print(state.matrix) do i, j
            ch = (i, j) in state.visited ? '.' : state.matrix[i, j]
            color = (i, j) in state.visited ? :blue : :yellow
            printstyled(ch, ' '; color=color)
        end
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day12: State

    function solve(state::State)
        return nothing
    end
end

############################################################################################
############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(State(@filedata path))
solve_part2(path::String) = Part2.solve(State(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (140, nothing)),
        ("example2.txt" => (772, nothing)),
        ("example3.txt" => (1930, nothing)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
