module AoC_24_Day12

include("../AoC_Utils.jl")

import .AoC_Utils: pretty_print

using .AoC_Utils: AoC_Utils, Point, in_bounds

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

function AoC_Utils.pretty_print(state::State)
    return nothing
    pretty_print(state.matrix, false) do i, j
        ch = (i, j) in state.visited ? '.' : state.matrix[i, j]
        color = (i, j) in state.visited ? :blue : :yellow
        printstyled(ch, ' '; color=color)
    end
end

function is_same_value(state::State, point1::Point, point2::Point)
    return in_bounds(state.matrix, point1) && in_bounds(state.matrix, point2) &&
        state.matrix[point1...] == state.matrix[point2...]
end

function is_same_value(state::State, point::Point, value::Char)
    return in_bounds(state.matrix, point) && state.matrix[point...] == value
end

############################################################################################

module Part1
    using ..AoC_Utils: Point, N, E, S, W
    using ..AoC_24_Day12: State, pretty_print, is_same_value

    function solve(state::State)
        score = 0
        while !isempty(state.to_visit)
            point = pop!(state.to_visit)
            area, perimeter = flood(state, point)
            score += area * perimeter
        end
        pretty_print(state)
        return score
    end

    function flood(state::State, point::Point)
        return flood(state, point, state.matrix[point...])
    end

    function flood(state::State, point::Point, value::Char)
        pretty_print(state)
        point in state.visited && return (0, 0)
        push!(state.visited, point)

        total_area = 1
        total_perimeter = 0
        local_perimeter = 4
        row, column = point
        for direction in (N, E, S, W)
            neighbor = point + direction
            is_same_value(state, neighbor, value) || continue

            local_perimeter -= 1
            neighbor in state.visited && continue
            delete!(state.to_visit, neighbor)

            area, perimeter = flood(state, neighbor, value)
            total_area += area
            total_perimeter += perimeter
        end
        return (total_area, total_perimeter + local_perimeter)
    end
end

############################################################################################

module Part2
    using ..AoC_Utils: Point, Direction, N, E, S, W, NE, SE, SW, NW, DIR_TO_SYMBOL
    using ..AoC_24_Day12: State, pretty_print, is_same_value

    const Corner = Tuple{Point, Direction}

    function solve(state::State)
        score = 0
        while !isempty(state.to_visit)
            point = pop!(state.to_visit)
            area, sides = flood(state, point)
            score += area * sides
        end
        pretty_print(state)
        return score
    end

    function flood(state::State, point::Point)
        return flood(state, point, state.matrix[point...], Set{Corner}())
    end

    function flood(state::State, point::Point, value::Char, corner_set::Set{Corner})
        pretty_print(state)
        point in state.visited && return (0, 0)
        push!(state.visited, point)

        # The current point introduces 4 corners
        # Only keep those that don't coalesce with existing corners
        for corner_dir in (NW, NE, SE, SW)
            corner = (point, corner_dir)
            coalesce_corners(state, point, corner_dir, corner_set) && continue
            push!(corner_set, corner)
        end

        total_area = 1
        corners = length(corner_set)
        for direction in (N, E, S, W)
            neighbor = point + direction
            is_same_value(state, neighbor, value) || continue

            neighbor in state.visited && continue
            delete!(state.to_visit, neighbor)

            area, corners = flood(state, neighbor, value, corner_set)
            total_area += area
        end
        return (total_area, corners)
    end

    # Check if the given corner coalesces with existing corners
    function coalesce_corners(state::State, point::Point, corner_dir::Direction, corner_set::Set{Corner})
        # Check the corners on the grid cells that are adjacent to the current point
        # and in the diagonal direction of the current corner
        (n1, c1, n2, c2, n3, c3) = if corner_dir == NW
            (N, SW, W, NE, NW, SE)
        elseif corner_dir == NE
            (N, SE, E, NW, NE, SW)
        elseif corner_dir == SE
            (S, NE, E, SW, SE, NW)
        elseif corner_dir == SW
            (S, NW, W, SE, SW, NE)
        end
        neighbor1 = point + n1
        neighbor1_corner = (neighbor1, c1)
        neighbor2 = point + n2
        neighbor2_corner = (neighbor2, c2)
        neighbor3 = point + n3
        neighbor3_corner = (neighbor3, c3)

        # Check if the current point shares an edge with the neighbor
        common_edge1 = is_same_value(state, neighbor1, point) && (neighbor1 in state.visited)
        common_edge2 = is_same_value(state, neighbor2, point) && (neighbor2 in state.visited)
        # Check if the adjacent neighbor has a corner towards this side
        neighbor1_has_corner = common_edge1 && (neighbor1_corner in corner_set)
        neighbor2_has_corner = common_edge2 && (neighbor2_corner in corner_set)

        # Check if the current point shares a corner with the neighbor in the diagonal direction
        # They only share a corner if the diagonal has a corner, and the other two neighbors
        # are adjacent.
        #
        #  + - - + + - -       + - - - - - -
        #  | . . | | . .       | . . . . . .
        #  | . X | | . .       | . . . . . .
        #  + - - + | . .  ==>  | . . . . . .
        #  + - - - X . .       | . . . . . .
        #  | . . . . . .       | . . . . . .
        #  | . . . . . .       | . . . . . .
        #
        # "X" is a corner
        # The corners are shared and can coalesce
        if common_edge1 && common_edge2 &&
            is_same_value(state, neighbor3, point) &&
            (neighbor3 in state.visited) &&
            (neighbor3_corner in corner_set)

            delete!(corner_set, neighbor3_corner)
            return true
        end

        # If only one side is common, those corners can coalesce
        #
        #  + - - + + - -        + - - - - - -
        #  | . . | | . .   ==>  | . . . . . .
        #  | . X | | X .        | . . . . . .
        #  + - - + + - -        + - - - - - -
        #
        #  OR
        #
        #  + - - +              + - - - +
        #  | . . |              | . . . |
        #  | . X |              | . . . |
        #  + - - +         ==>  | . . . |
        #  + - - +              | . . . |
        #  | . X |              | . . . |
        #  | . . |              | . . . |
        #
        if neighbor1_has_corner && !neighbor2_has_corner
            delete!(corner_set, neighbor1_corner)
            return true
        end
        if neighbor2_has_corner && !neighbor1_has_corner
            delete!(corner_set, neighbor2_corner)
            return true
        end

        # If both sides are common, (and the diagonal has no sharing corner),
        # the current corner overrides the other two (but remains!)
        #
        #  + - - + + - -       + - - - - - -
        #  | . . | | . .       | . . . . . .
        #  | . X | | X .       | . X + - - -
        #  + - - + + - -  ==>  | . . |
        #  + - - +             | . . |
        #  | . X |             | . . |
        #  | . . |             | . . |
        #
        if neighbor1_has_corner && neighbor2_has_corner
            delete!(corner_set, neighbor1_corner)
            delete!(corner_set, neighbor2_corner)
        end

        return false
    end

    function print_corner_set(corner_set::Set{Corner})
        printstyled("CS ($(length(corner_set))): "; color=:black)
        for (point, dir) in corner_set
            printstyled("[$point $(DIR_TO_SYMBOL[dir])]", ' '; color=:magenta)
        end
        println()
    end
end

############################################################################################
############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(State(@filedata path))
solve_part2(path::String) = Part2.solve(State(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (140, 80)),
        ("example2.txt" => (772, 436)),
        ("example3.txt" => (1930, 1206)),
        ("example4.txt" => (692, 236)),
        ("example5.txt" => (1184, 368)),
        ("example6.txt" => (296, 156)),
        ("example7.txt" => (1146, 616)),
        ("example8.txt" => (320, 112)),
        ("example9.txt" => (468, 192)),
        ("example10.txt" => (684, 300)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
