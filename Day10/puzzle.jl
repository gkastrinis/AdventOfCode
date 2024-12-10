module AoC_24_Day10

struct State
    rows::Int
    columns::Int
    matrix::Matrix{UInt8}
    zeros::Vector{Tuple{Int, Int}}
end

const PEAK = UInt8(9)

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
            x = ch == '.' ? PEAK+1 : UInt8(ch - '0')
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

const EMPTY_NEIGHBORS = Tuple{Int, Int}[]

function find_valid_neighbors(state::State, position::Tuple{Int,Int})
    row, column = position
    value = state.matrix[row, column]
    value == PEAK && return EMPTY_NEIGHBORS

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

############################################################################################

module Part1
    using ..AoC_24_Day10: State, PEAK, find_valid_neighbors

    const TrailHead = Tuple{Int, Int}

    function solve(state::State)
        leads_to_peaks_memoized = Dict{Tuple{Int, Int}, Set{TrailHead}}()
        return sum(
            length(leads_to_peaks!(state, leads_to_peaks_memoized, zero))
            for zero in state.zeros
        )
    end

    function leads_to_peaks!(
        state::State,
        leads_to_peaks_memoized::Dict{Tuple{Int, Int}, Set{TrailHead}},
        position::Tuple{Int,Int}
    )
        # Short circuit if we already know the answer
        if haskey(leads_to_peaks_memoized, position)
            return leads_to_peaks_memoized[position]
        end

        peaks = Set{TrailHead}()
        value = state.matrix[position...]
        if value == PEAK
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
    using ..AoC_24_Day10: State, PEAK, find_valid_neighbors

    const Trail = Vector{Tuple{Int, Int}}

    function solve(state::State)
        leads_to_peak_paths_memoized = Dict{Tuple{Int, Int}, Set{Trail}}()
        return sum(
            length(leads_to_peak_paths!(state, leads_to_peak_paths_memoized, zero))
            for zero in state.zeros
        )
    end

    function leads_to_peak_paths!(
        state::State,
        leads_to_peak_paths_memoized::Dict{Tuple{Int, Int}, Set{Trail}},
        position::Tuple{Int,Int}
    )
        # Short circuit if we already know the answer
        if haskey(leads_to_peak_paths_memoized, position)
            return leads_to_peak_paths_memoized[position]
        end

        peak_paths = Set{Trail}()
        value = state.matrix[position...]
        if value == PEAK
            push!(peak_paths, [position])
        else
            neighbors = find_valid_neighbors(state, position)
            for neighbor in neighbors
                paths = leads_to_peak_paths!(state, leads_to_peak_paths_memoized, neighbor)
                for path in paths
                    push!(peak_paths, vcat(path, position))
                end
            end
        end
        leads_to_peak_paths_memoized[position] = peak_paths
        return peak_paths
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
        if isnothing(expected)
            printstyled(tag, " ❔: nothing == $(actual)\n"; color=:magenta)
        elseif !isnothing(actual) && actual == expected
            printstyled(tag, " ✅: "; color=:green)
            printstyled(expected; color=:green)
            printstyled(" = "; color=:black)
            printstyled(actual, "\n"; color=:green)
        else
            printstyled(tag, " ❌: "; color=:red)
            printstyled(expected; color=:green)
            printstyled(" ≠ "; color=:black)
            printstyled(actual, "\n"; color=:red)
        end
        return nothing
    end

    for (file, expected) in [
        ("example1.txt" => (1, 16)),
        ("example2.txt" => (2, 2)),
        ("example3.txt" => (4, 13)),
        ("example4.txt" => (3, 3)),
        ("example5.txt" => (36, 81)),
        ("example6.txt" => (1, 2)),
        ("example7.txt" => (1, 3)),
        ("example8.txt" => (4, 13)),
        ("example9.txt" => (2, 227)),
    ]
        expected1, expected2 = expected
        printstyled("--- testing: ", file, " ---\n"; color=:yellow)
        assert_result("Part 1", expected1, with_file_input(file, solve_part1))
        assert_result("Part 2", expected2, with_file_input(file, solve_part2))
    end
    return nothing
end

end
