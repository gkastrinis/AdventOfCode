module AoC_24_Day6

struct Input
    rows::Int
    columns::Int
    matrix::Matrix{Char}
    orig_cell::Tuple{Int, Int} # (x, y)
    orig_direction::Tuple{Int, Int} # (dx, dy)
end

const N = (-1, 0)
const E = (0, 1)
const S = (1, 0)
const W = (0, -1)
const SYMBOL_TO_DIR = Dict('^' => N, 'v' => S, '>' => E, '<' => W)
const RIGHT_TURN = Dict(N => E, E => S, S => W, W => N)

function Input(input::String)
    rows = count(==('\n'), input)
    columns = findnext('\n', input, 1) - 1
    matrix = Matrix{Char}(undef, rows, columns)
    i = j = 1
    cell = direction = (0, 0)
    io = IOBuffer(input)
    while !eof(io)
        ch = read(io, Char)
        if ch == '\n'
            i += 1
            j = 1
        else
            matrix[i, j] = ch
            if ch in keys(SYMBOL_TO_DIR)
                cell = (i, j)
                direction = SYMBOL_TO_DIR[ch]
            end
            j += 1
        end
    end
    return Input(rows, columns, matrix, cell, direction)
end

function clone(input::Input)
    return Input(
        input.rows,
        input.columns,
        deepcopy(input.matrix),
        input.orig_cell,
        input.orig_direction
    )
end

function in_bounds(input::Input, cell::Tuple{Int,Int})
    x, y = cell
    return 1 <= x <= input.rows && 1 <= y <= input.columns
end

function map_to_color(symbol::Char)
    symbol == '.' && return :black
    symbol == '#' && return :magenta
    symbol in ('|', '-', '+') && return :yellow
    symbol == 'O' && return :red
    return :green
end

function pretty_print(m::Matrix{Char}, interactive::Bool=true)
    interactive && (sleep(0.1); Base.run(`clear`))
    println("\n")

    for i in 1:size(m, 1)
        for ch in m[i,:]
            printstyled(ch, ' '; color=map_to_color(ch))
        end
        println('\n')
    end
    return nothing
end

solve_file(path::String) = solve(read(path, String))

function solve(inputStr::String)
    input = Input(inputStr)
    input_clone = clone(input)
    printstyled("Part 1: ", Part1.solve(input, false), "\n"; color=:yellow)
    printstyled("Part 2: ", Part2.solve(input_clone, false), "\n"; color=:blue)
    return nothing
end

############################################################################################

module Part1
    using ..AoC_24_Day6: Input, in_bounds, N, E, S, W, RIGHT_TURN, pretty_print

    const DIR_TO_SYMBOL = Dict(N => '|', S => '|', E => '-', W => '-')

    struct VisitedEntry
        cell::Tuple{Int, Int}
        direction::Tuple{Int, Int}
    end

    solve(input::Input, should_print::Bool) = walk(input, should_print)[1]

    function walk(input::Input, should_print::Bool, new_obstacle::Union{Nothing,Tuple{Int,Int}}=nothing)
        cell = input.orig_cell
        direction = input.orig_direction
        input.matrix[cell...] = DIR_TO_SYMBOL[direction]
        score = 1
        path = Set{Tuple{Int, Int}}()
        visited = Set{VisitedEntry}()
        push!(visited, VisitedEntry(input.orig_cell, input.orig_direction))
        while true
            should_print && pretty_print(input.matrix)

            next_cell = cell .+ direction
            # Went out of the grid
            !in_bounds(input, next_cell) && return (score, path)
            # Hit an obstacle
            if input.matrix[next_cell...] == '#' || (!isnothing(new_obstacle) && next_cell == new_obstacle)
                input.matrix[cell...] = '+'
                direction = RIGHT_TURN[direction]
                continue
            elseif input.matrix[next_cell...] == '.'
                score += 1
                push!(path, next_cell)
                input.matrix[next_cell...] = DIR_TO_SYMBOL[direction]
            elseif input.matrix[next_cell...] in ('|', '-')
                input.matrix[next_cell...] = '+'
            end
            cell = next_cell
            # Check for a loop
            ve = VisitedEntry(next_cell, direction)
            ve in visited && return (-1, path)
            # Cache the visited cell
            in_bounds(input, next_cell) && push!(visited, ve)
        end
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day6: Input, clone, pretty_print
    using ..Part1: walk

    function solve(input::Input, should_print::Bool)
        score = 0
        # Get the visited path from part 1
        # Clone the input (perhaps another time) to avoid contaminating the print below.
        # If we don't print the obstacles, the cloning can be avoided.
        input_clone = should_print ? clone(input) : input
        loop_score, path = walk(input, false)
        if loop_score == -1
            printstyled("Already in loop!\n"; color=:red)
            return score
        end
        alt_obstacles = Set{Tuple{Int, Int}}()
        # Attempt to introduce a new obstacle in each cell in the path
        for new_obstacle in path
            if walk(input, false, new_obstacle)[1] == -1
                score += 1
                push!(alt_obstacles, new_obstacle)
            end
        end
        if should_print
            for obstacle in alt_obstacles
                input_clone.matrix[obstacle...] = 'O'
            end
            pretty_print(input_clone.matrix, false)
        end
        return score
    end
end

end
