module AoC_24_Day8

struct Input
    rows::Int
    columns::Int
    matrix::Matrix{Int8}
    antennas::Dict{Int8,Vector{Tuple{Int, Int}}}
    antinodes::Set{Tuple{Int, Int}}
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
    return Input(rows, columns, matrix, antennas, Set{Tuple{Int, Int}}())
end

function solve_file(path::String)
    return solve_data(read(path, String))
end

function solve_data(data::String)
    input = Input(data)
    input_clone = deepcopy(input)
    printstyled("Part 1: ", Part1.solve(input), "\n"; color=:blue)
    printstyled("Part 2: ", Part2.solve(input_clone), "\n"; color=:yellow)
    return nothing
end

############################################################################################

function is_in_bounds(input::Input, cell::Tuple{Int,Int})
    row, col = cell
    return 1 <= row <= input.rows && 1 <= col <= input.columns
end

function transpose_vector(antenna1::Tuple{Int, Int}, antenna2::Tuple{Int, Int})
    row1, col1 = antenna1
    row2, col2 = antenna2
    return (row2-row1, col2-col1)
end

function add_antinode!(input::Input, antinode::Tuple{Int, Int}, freq::Int8)
    push!(input.antinodes, antinode)
    prev_val = input.matrix[antinode...]
    if prev_val == EMPTY_FREQ
        input.matrix[antinode...] = -freq
    elseif prev_val > 0
        input.matrix[antinode...] = -prev_val
    end
    return nothing
end

function pretty_print(m::Matrix{Int8})
    for i in 1:size(m, 1)
        for e in m[i,:]
            color = if e == EMPTY_FREQ
                :black
            elseif e < 0
                :red
            else
                :green
            end
            printstyled(' ', Char(abs(e)), ' '; color)
        end
        println('\n')
    end
    return nothing
end

############################################################################################

module Part1
    using ..AoC_24_Day8: Input, EMPTY_FREQ, is_in_bounds, transpose_vector, add_antinode!, pretty_print

    function solve(input::Input)
        for (freq, antennas) in input.antennas
            len = length(antennas)
            len < 2 && continue
            for i in 1:len-1
                for j in i+1:len
                    a1 = antennas[i]
                    a2 = antennas[j]
                    tp_vec = transpose_vector(a1, a2)
                    for tp in (-1 .* tp_vec, tp_vec .+ tp_vec)
                        antinode = a1 .+ tp
                        !is_in_bounds(input, antinode) && continue
                        add_antinode!(input, antinode, freq)
                    end
                end
            end
        end
        # pretty_print(input.matrix)
        return length(input.antinodes)
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day8: Input, EMPTY_FREQ, is_in_bounds, transpose_vector, add_antinode!, pretty_print

    function solve(input::Input)
        for (freq, antennas) in input.antennas
            len = length(antennas)
            len < 2 && continue
            for i in 1:len-1
                for j in i+1:len
                    a1 = antennas[i]
                    a2 = antennas[j]
                    tp_vec = transpose_vector(a1, a2)
                    push!(input.antinodes, a1)
                    for tp in (-1 .* tp_vec, tp_vec)
                        current = a1
                        while true
                            antinode = current .+ tp
                            !is_in_bounds(input, antinode) && break
                            add_antinode!(input, antinode, freq)
                            current = antinode
                        end
                    end
                end
            end
        end
        pretty_print(input.matrix)
        return length(input.antinodes)
    end
end

end
