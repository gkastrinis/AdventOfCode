module AoC_24_Day10

struct State
    rows::Int
    columns::Int
    matrix::Matrix{UInt8}
    zeros::Vector{Tuple{Int, Int}}
end

function State(input::String)
    rows = count(==('\n'), input)
    columns = findnext('\n', input, 1) - 1
    matrix = Matrix{UInt8}(undef, rows, columns)
    zeros = Tuple{Int, Int}[]
    i = j = 1
    io = IOBuffer(input)
    while !eof(io)
        ch = read(io, Char)
        if ch == '\n'
            i += 1
            j = 1
        else
            x = ch == '.' ? UInt8(10) : UInt8(ch - '0')
            matrix[i, j] = x
            x == 0 && push!(zeros, (i, j))
            j += 1
        end
    end
    return State(rows, columns, matrix, zeros)
end

function in_bounds(state::State, row::Int, column::Int)
    return 1 <= row <= state.rows && 1 <= column <= state.columns
end

############################################################################################

module Part1
    using ..AoC_24_Day10: State, in_bounds

    function solve(state::State)
        leads_to_peaks_memoized = Dict{Tuple{Int, Int}, Set{Tuple{Int, Int}}}()
        return sum(
            length(leads_to_peaks!(state, leads_to_peaks_memoized, zero))
            for zero in state.zeros
        )
    end

    const EMPTY_NEIGHBORS = Tuple{Int, Int}[]

    function find_valid_neighbors(state::State, position::Tuple{Int,Int})
        row, column = position
        value = state.matrix[row, column]
        value == 9 && return EMPTY_NEIGHBORS

        neighbors = Tuple{Int, Int}[]
        sizehint!(neighbors, 4)
        r, c = row-1, column
        in_bounds(state, r, c) && state.matrix[r, c] == value + 1 && push!(neighbors, (r, c))
        r, c = row+1, column
        in_bounds(state, r, c) && state.matrix[r, c] == value + 1 && push!(neighbors, (r, c))
        r, c = row, column-1
        in_bounds(state, r, c) && state.matrix[r, c] == value + 1 && push!(neighbors, (r, c))
        r, c = row, column+1
        in_bounds(state, r, c) && state.matrix[r, c] == value + 1 && push!(neighbors, (r, c))
        return neighbors
    end

    function leads_to_peaks!(
        state::State,
        leads_to_peaks_memoized::Dict{Tuple{Int, Int}, Set{Tuple{Int, Int}}},
        position::Tuple{Int,Int}
    )
        # Short circuit if we already know the answer
        if haskey(leads_to_peaks_memoized, position)
            return leads_to_peaks_memoized[position]
        end

        peaks = Set{Tuple{Int, Int}}()
        value = state.matrix[position...]
        if value == 9
            push!(peaks, position)
        else
            neighbors = find_valid_neighbors(state, position)
            for neighbor in neighbors
                union!(peaks, leads_to_peaks!(state, leads_to_peaks_memoized, neighbor))
            end
        end
        leads_to_peaks_memoized[position] = peaks
        return peaks
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day10: State

    function solve(state::State)
        return nothing
    end
end

############################################################################################
############################################################################################

solve_part1(data::String) = Part1.solve(State(data))

solve_part2(data::String) = Part2.solve(State(data))

with_file_input(path::String, f::Function) = f(read(path, String))

solve_file(path::String) = with_file_input(path, solve_all)

function solve_all(data::String)
    printstyled("Part 1: "; color=:black)
    printstyled(solve_part1(data), "\n"; color=:blue)
    printstyled("Part 2: "; color=:black)
    printstyled(solve_part2(data), "\n"; color=:green)
    return nothing
end

function test()
    function assert_result(tag, expected, actual)
        printstyled(tag, ": "; color=:black)
        printstyled(expected; color=:green)
        printstyled(" == "; color=:black)
        if !isnothing(actual) && actual == expected
            printstyled(actual, " ✅\n"; color=:green)
        else
            printstyled(actual, " ❌\n"; color=:red)
        end
    end

    for (file, expected) in [
        ("example1.txt" => (1, nothing)),
        ("example2.txt" => (2, nothing)),
        ("example3.txt" => (4, nothing)),
        ("example4.txt" => (3, nothing)),
        ("example5.txt" => (36, nothing)),
        ("example6.txt" => (1, nothing)),
    ]
        expected1, expected2 = expected
        printstyled("--- testing: ", file, " ---\n"; color=:yellow)
        assert_result("Part 1", expected1, with_file_input(file, solve_part1))
        assert_result("Part 2", expected2, with_file_input(file, solve_part2))
    end
end

end
