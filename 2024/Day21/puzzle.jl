module AoC_24_Day21

include("../../AoC_Utils.jl")

struct Puzzle
    codes::Vector{String}
end

function Puzzle(input::String)
    return Puzzle(split(input, '\n'; keepempty=false))
end

const DOOR_BUTTONS = Dict(
    '7' => (1, 1),
    '8' => (1, 2),
    '9' => (1, 3),
    '4' => (2, 1),
    '5' => (2, 2),
    '6' => (2, 3),
    '1' => (3, 1),
    '2' => (3, 2),
    '3' => (3, 3),
    '0' => (4, 2),
    'A' => (4, 3),
)

const ROBOT_BUTTONS = Dict(
    '^' => (1, 2),
    'A' => (1, 3),
    '<' => (2, 1),
    'v' => (2, 2),
    '>' => (2, 3),
)

############################################################################################

module Part1
    using ..AoC_Utils: @n_times, Point, manhattan_distance
    using ..AoC_24_Day21: Puzzle, DOOR_BUTTONS, ROBOT_BUTTONS

    function solve(puzzle::Puzzle)
        return sum(press_code(code) for code in puzzle.codes)
    end

    function press_code(code::String)
        seq1 = press_buttons(code, DOOR_BUTTONS)
        seq2 = press_buttons(seq1, ROBOT_BUTTONS)
        seq3 = press_buttons(seq2, ROBOT_BUTTONS)
        return parse(Int, (@view code[1:end-1])) * length(seq3)
    end

    function press_buttons(code::String, buttons::Dict{Char, Point})
        io = IOBuffer()
        from = buttons['A']
        for button in code
            to = buttons[button]
            press_button(io, from, to, buttons)
            from = to
        end
        return String(take!(io))
    end

    function press_button(io::IO, from::Point, to::Point, buttons::Dict{Char, Point})
        h = to[2] - from[2]
        v = to[1] - from[1]
        h_ch = h < 0 ? '<' : '>'
        v_ch = v < 0 ? '^' : 'v'

        if (h_ch == '<' && from + (0, h) != (4, 1)) || from + (v, 0) == (4, 1)
            @n_times abs(h) print(io, h_ch)
            @n_times abs(v) print(io, v_ch)
        else
            @n_times abs(v) print(io, v_ch)
            @n_times abs(h) print(io, h_ch)
        end
        print(io, 'A')
        return nothing
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day21: Puzzle

    function solve(puzzle::Puzzle)
        return nothing
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (126384, nothing)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
