module AoC_24_Day14

include("../../AoC_Utils.jl")

using .AoC_Utils: Point, @n_times, next_int

struct Robot
    origin::Point
    velocity::Point
end

struct State
    cols::Int
    rows::Int
    robots::Vector{Robot}
end

function State(input::String)
    max_x = 0
    max_y = 0
    robots = Robot[]
    io = IOBuffer(input)
    while !eof(io)
        # p=
        @n_times 2 read(io, Char)
        x = next_int(io)
        # ,
        read(io, Char)
        y = next_int(io)

        x > max_x && (max_x = x)
        y > max_y && (max_y = y)

        # _v=
        @n_times 3 read(io, Char)
        vx = next_int(io)
        # ,
        read(io, Char)
        vy = next_int(io)
        # \n
        read(io, Char)

        push!(robots, Robot((x, y), (vx, vy)))
    end
    return State(max_x + 1, max_y + 1, robots)
end

############################################################################################

module Part1
    using ..AoC_Utils: Point
    using ..AoC_24_Day14: Robot, State

    function solve(state::State, seconds::Int)
        cols, rows = state.cols, state.rows
        quadrants = Int[0, 0, 0, 0]
        for robot in state.robots
            new_point = move_robot(cols, rows, robot, seconds)
            quadrant = to_quadrant(state, new_point)
            quadrant == 0 && continue
            quadrants[quadrant] += 1
        end
        return prod(quadrants)
    end

    function move_robot(cols::Int, rows::Int, robot::Robot, times::Int)
        unwrapped_destination = robot.origin + (robot.velocity * times)
        wrapped_destination = (unwrapped_destination[1] % cols, unwrapped_destination[2] % rows)
        # Change to positive coordinates
        # (2, -3) on a 11x7 grid is (2, 4)
        col, row = wrapped_destination
        col < 0 && (col += cols)
        row < 0 && (row += rows)
        return (col, row)
    end

    # 1 2
    # 3 4
    #
    # 0 ==> center lines
    function to_quadrant(state::State, point::Point)
        middle_col = state.cols ÷ 2
        middle_row = state.rows ÷ 2
        col, row = point
        (col == middle_col || row == middle_row) && return 0
        col < middle_col && row < middle_row && return 1
        col > middle_col && row < middle_row && return 2
        col < middle_col && row > middle_row && return 3
        col > middle_col && row > middle_row && return 4
    end
end

############################################################################################

module Part2
    using ..AoC_Utils: Point, pretty_print
    using ..AoC_24_Day14: Robot, State
    using ..AoC_24_Day14.Part1: move_robot

    function solve(state::State)
        cols, rows = state.cols, state.rows
        matrix = Matrix{Char}(undef, rows, cols)
        min_second, min_clusters, min_matrix = nothing, nothing, nothing
        for second in 1:10000
            for i in 1:length(state.robots)
                robot = state.robots[i]
                new_position = move_robot(cols, rows, robot, 1)
                matrix[robot.origin[2]+1, robot.origin[1]+1] = '.'
                matrix[new_position[2]+1, new_position[1]+1] = 'R'
                state.robots[i] = Robot(new_position, robot.velocity)
            end

            clusters = find_clusters(deepcopy(matrix), rows, cols)
            if isnothing(min_clusters) || clusters < min_clusters
                min_second, min_clusters, min_matrix = second, clusters, deepcopy(matrix)
            end
        end
        pretty_print(min_matrix) do i, j
            c = min_matrix[i, j]
            printstyled(c; color=(c == 'R' ? :yellow : :magenta))
        end
        printstyled("second: $min_second, clusters: $min_clusters\n"; color=:magenta)
        return min_second
    end

    function find_clusters(matrix, rows, cols)
        clusters = 0
        for row in 1:rows
            for col in 1:cols
                matrix[row, col] == '.' && continue
                clusters += 1
                flood_fill(matrix, rows, cols, row, col)
            end
        end
        return clusters
    end

    function flood_fill(matrix, rows, cols, row, col)
        (1 <= row <= rows && 1 <= col <= cols) || return
        matrix[row, col] == 'R' || return
        matrix[row, col] = '.'
        # Only need to check the "next" neighbors. Previous neighbors are already checked.
        flood_fill(matrix, rows, cols, row, col + 1)
        flood_fill(matrix, rows, cols, row + 1, col + 1)
        flood_fill(matrix, rows, cols, row + 1, col)
    end
end

############################################################################################
############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String, seconds::Int) = Part1.solve(State(@filedata path), seconds)
solve_part2(path::String) = Part2.solve(State(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => ((100, 12), nothing)),
    ]
        args1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        seconds, expected1 = args1
        test_assert("Part 1", expected1, solve_part1(path, seconds))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
