module AoC_24_Day14

include("../AoC_Utils.jl")

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
        quadrants = Int[0, 0, 0, 0]
        for robot in state.robots
            new_point = move_robot(state, robot, seconds)
            quadrant = to_quadrant(state, new_point)
            quadrant == 0 && continue
            quadrants[quadrant] += 1
        end
        return prod(quadrants)
    end

    function move_robot(state::State, robot::Robot, times::Int)
        unwrapped_destination = robot.origin + (robot.velocity * times)
        wrapped_destination = (unwrapped_destination[1] % state.cols, unwrapped_destination[2] % state.rows)
        # Change to positive coordinates
        # (2, -3) on a 11x7 grid is (2, 4)
        col, row = wrapped_destination
        return (col < 0 ? col + state.cols : col, row < 0 ? row + state.rows : row)
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
    using ..AoC_24_Day14: State

    function solve(state::State)
        return nothing
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
