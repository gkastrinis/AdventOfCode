module AoC_24_Day8

struct Input
    rows::Int
    columns::Int
    matrix::Matrix{Int8}
    antennas::Dict{Int8,Vector{Tuple{Int, Int}}}
end

const EMPTY_FREQ = Int8('.')

function Input(input::String)
    rows = count(==('\n'), input)
    columns = findnext('\n', input, 1) - 1
    matrix = Matrix{Int8}(undef, rows, columns)
    antennas = Dict{Int8,Vector{Tuple{Int, Int}}}()
    i = j = 1
    io = IOBuffer(input)
    while !eof(io)
        ch = read(io, Char)
        if ch == '\n'
            i += 1
            j = 1
            continue
        else
            freq = Int8(ch)
            matrix[i, j] = freq
            if freq != EMPTY_FREQ
                !haskey(antennas, freq) && (antennas[freq] = [])
                push!(antennas[freq], (i, j))
            end
        end
        j += 1
    end
    return Input(rows, columns, matrix, antennas)
end

# function clone(input::Input)
#     return Input()
# end

function in_bounds(input::Input, cell::Tuple{Int,Int})
    row, col = cell
    return 1 <= row <= input.rows && 1 <= col <= input.columns
end

function map_to_color(e::Int8)
    e == EMPTY_FREQ && return :grey
    e < 0 && return :red
    return :green
end

function pretty_print(m::Matrix{Int8})
    for i in 1:size(m, 1)
        for e in m[i,:]
            printstyled(' ', Char(abs(e)), ' '; color=map_to_color(e))
        end
        println('\n')
    end
    return nothing
end

function solve_file(path::String)
    return solve_data(read(path, String))
end

function solve_data(data::String)
    input = Input(data)
    # input_clone = clone(input)
    printstyled("Part 1: ", Part1.solve(input), "\n"; color=:yellow)
    # printstyled("Part 2: ", Part2.solve(input_clone), "\n"; color=:blue)
    return nothing
end

############################################################################################

module Part1
    using ..AoC_24_Day8: Input, EMPTY_FREQ, in_bounds, pretty_print

    function solve(input::Input)
        antinodes = Set{Tuple{Int, Int}}()
        for (freq, antennas) in input.antennas
            length(antennas) < 2 && continue
            for i in 1:length(antennas)-1
                for j in i+1:length(antennas)
                    a1 = antennas[i]
                    a2 = antennas[j]
                    tp_vec = transpose_vector(a1, a2)
                    for node in (a1 .- tp_vec, a2 .+ tp_vec)
                        if is_valid_antinode(input, freq, node)
                            push!(antinodes, node)
                            prev_val = input.matrix[node...]
                            if prev_val == EMPTY_FREQ
                                input.matrix[node...] = -freq
                            elseif prev_val > 0
                                input.matrix[node...] = -prev_val
                            end
                        end
                    end
                end
            end
        end
        # pretty_print(input.matrix)
        return length(antinodes)
    end

    function transpose_vector(antenna1::Tuple{Int, Int}, antenna2::Tuple{Int, Int})
        row1, col1 = antenna1
        row2, col2 = antenna2
        return (row2-row1, col2-col1)
    end

    function is_valid_antinode(input::Input, freq::Int8, node::Tuple{Int,Int})
        in_bounds(input, node) || return false
        same_freq_antennas = input.antennas[freq]
        return !(node in same_freq_antennas)
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day8: Input

    function solve(input::Input)
        return nothing
    end
end

end
