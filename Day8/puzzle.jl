module AoC_24_Day8

struct Input
    rows::Int
    columns::Int
    matrix::Matrix{Char}
    # From frequency to antenna coordinates
    antennas::Dict{Char,Vector{Tuple{Int, Int}}}
    # Coordinates of the antinodes
    antinodes::Set{Tuple{Int, Int}}
end

function Input(input::String)
    rows = count(==('\n'), input)
    columns = findnext('\n', input, 1) - 1
    matrix = Matrix{Char}(undef, rows, columns)
    antennas = Dict{Char,Vector{Tuple{Int, Int}}}()
    i = j = 1
    io = IOBuffer(input)
    while !eof(io)
        ch = read(io, Char)
        if ch == '\n'
            i += 1
            j = 1
            continue
        end
        matrix[i, j] = ch
        if ch != '.'
            !haskey(antennas, ch) && (antennas[ch] = [])
            push!(antennas[ch], (i, j))
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

# Manhattan distance between two antennas.
function transpose_vector(antenna1::Tuple{Int, Int}, antenna2::Tuple{Int, Int})
    row1, col1 = antenna1
    row2, col2 = antenna2
    return (row2-row1, col2-col1)
end

function add_antinode!(input::Input, antinode::Tuple{Int, Int})
    push!(input.antinodes, antinode)
    if input.matrix[antinode...] == '.'
        input.matrix[antinode...] = '#'
    end
    return nothing
end

# green for antennas
# red for "normal" antinodes
# yellow for antennas that are also antinodes
function pretty_print(input::Input)
    for i in 1:size(input.matrix, 1)
        for j in 1:size(input.matrix, 2)
            ch = input.matrix[i, j]
            print(' ')
            if ch == '.'
                printstyled(ch; color=:black)
            elseif ch == '#'
                printstyled(ch; color=:red)
            else
                original = input.matrix[i, j]
                if (i, j) in input.antinodes
                    printstyled(original; color=:yellow)
                else
                    printstyled(original; color=:green)
                end
            end
            print(' ')
        end
        println('\n')
    end
    return nothing
end

############################################################################################

module Part1
    using ..AoC_24_Day8: Input, is_in_bounds, transpose_vector, add_antinode!, pretty_print

    function solve(input::Input)
        for (_, antennas) in input.antennas
            len = length(antennas)
            len < 2 && continue
            for i in 1:len-1
                for j in i+1:len
                    a1 = antennas[i]
                    a2 = antennas[j]
                    tp_vec = transpose_vector(a1, a2)
                    # Try (a1 - 1*tp) and (a1 + 2*tp)
                    for tp in (-1 .* tp_vec, tp_vec .+ tp_vec)
                        antinode = a1 .+ tp
                        !is_in_bounds(input, antinode) && continue
                        add_antinode!(input, antinode)
                    end
                end
            end
        end
        # pretty_print(input)
        return length(input.antinodes)
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day8: Input, is_in_bounds, transpose_vector, add_antinode!, pretty_print

    function solve(input::Input)
        for (_, antennas) in input.antennas
            len = length(antennas)
            len < 2 && continue
            for i in 1:len-1
                for j in i+1:len
                    a1 = antennas[i]
                    a2 = antennas[j]
                    tp_vec = transpose_vector(a1, a2)
                    push!(input.antinodes, a1)
                    # Try (a1 - N*tp) and (a1 + N*tp)
                    for tp in (-1 .* tp_vec, tp_vec)
                        current = a1
                        while true
                            antinode = current .+ tp
                            !is_in_bounds(input, antinode) && break
                            add_antinode!(input, antinode)
                            current = antinode
                        end
                    end
                end
            end
        end
        # pretty_print(input)
        return length(input.antinodes)
    end
end

end
