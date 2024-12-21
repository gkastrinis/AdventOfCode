module AoC_24_Day21

include("../../AoC_Utils.jl")
using .AoC_Utils: @n_times, Point

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

function press_button(io::IO, from::Point, to::Point, buttons::Dict{Char, Point}, empty_btn::Point)
    h = to[2] - from[2]
    v = to[1] - from[1]
    h_ch = h < 0 ? '<' : '>'
    v_ch = v < 0 ? '^' : 'v'

    if (h_ch == '<' && from + (0, h) != empty_btn) || from + (v, 0) == empty_btn
        @n_times abs(h) print(io, h_ch)
        @n_times abs(v) print(io, v_ch)
    else
        @n_times abs(v) print(io, v_ch)
        @n_times abs(h) print(io, h_ch)
    end
    print(io, 'A')
    return nothing
end

############################################################################################

module Part1
    using ..AoC_Utils: Point
    using ..AoC_24_Day21: Puzzle, DOOR_BUTTONS, ROBOT_BUTTONS, press_button

    function solve(puzzle::Puzzle)
        return sum(press_code(code) for code in puzzle.codes)
    end

    function press_code(code::String)
        seq1 = press_buttons(code, DOOR_BUTTONS, (4, 1))
        seq2 = press_buttons(seq1, ROBOT_BUTTONS, (1, 1))
        seq3 = press_buttons(seq2, ROBOT_BUTTONS, (1, 1))
        return parse(Int, (@view code[1:end-1])) * length(seq3)
    end

    function press_buttons(code::String, buttons::Dict{Char, Point}, empty_btn::Point)
        io = IOBuffer()
        from = buttons['A']
        for button in code
            to = buttons[button]
            press_button(io, from, to, buttons, empty_btn)
            from = to
        end
        return String(take!(io))
    end
end

############################################################################################

module Part2
    using ..AoC_Utils: Point
    using ..AoC_24_Day21: Puzzle, DOOR_BUTTONS, ROBOT_BUTTONS, press_button

    const ROBOT_BUTTONS_KEYS = ('A', '^', '<', 'v', '>')
    const DOOR_BUTTONS_KEYS = ('7', '8', '9', '4', '5', '6', '1', '2', '3', '0', 'A')

    # A human is pressing buttons on the keypad of the first robot. KeyPad0.
    # Any action here has a cost of 1.
    # Assume that KeyPad1 is the first robot-controlled keypad.
    # If the robot on KeyPad1, is on "A" and we want to move it to "v", one of the shortest
    # sequences is "v<A". The cost is 3.
    # We compute every possible combination of start/stop buttons on KeyPad1.
    # The costs are stored in "costs1", and the sequences needed in "basic_sequences".
    #
    # If we are now on KeyPad2 (the second robot-controlled keypad), and want to move from
    # "A" to "v", we have to press "v<A" on KeyPad1. The corresponding cost is that of
    # "A to v" + "v to <" + "< to A" (since we always start and end at "A").
    # We compute every possible combination of start/stop buttons on KeyPad2.
    # The costs are stored in "costs2".
    #
    # We only need the to actually keep the costs being computed, and those of the previous level.
    # After doing that for 25 robots, we apply the same logic on the keypad on the door to find the
    # final cost. For instance, in order to press "1A" on the door, we need to compute the costs of
    # "A to 1" + "1 to A" using the costs of the last level.
    function solve(puzzle::Puzzle)
        basic_sequences, costs1 = initial_costs(ROBOT_BUTTONS)
        current = costs1
        for _ in 1:24
            current = next_costs(basic_sequences, current, ROBOT_BUTTONS)
        end
        last_costs = current

        total_score = 0
        for code in puzzle.codes
            cost = 0
            ch1 = 'A'
            numpad_seq = get_numpad_sequence(code)
            for ch2 in numpad_seq
                cost += get(last_costs, (ch1, ch2), 1)
                ch1 = ch2
            end
            total_score += parse(Int, (@view code[1:end-1])) * cost
        end
        return total_score
    end

    function initial_costs(buttons::Dict{Char, Point})
        level = Dict{Tuple{Char, Char}, String}()
        for btn1 in ROBOT_BUTTONS_KEYS, btn2 in ROBOT_BUTTONS_KEYS
            btn1 == btn2 && continue
            path = get_button_sequence(ROBOT_BUTTONS[btn1], ROBOT_BUTTONS[btn2], ROBOT_BUTTONS, (1, 1))
            level[(btn1, btn2)] = path
        end
        costs = Dict{Tuple{Char, Char}, Int}()
        for btn1 in ROBOT_BUTTONS_KEYS, btn2 in ROBOT_BUTTONS_KEYS
            btn1 == btn2 && continue
            len = length(level[(btn1, btn2)])
            costs[(btn1, btn2)] = len
        end
        return (level, costs)
    end

    function next_costs(
        basic_sequences::Dict{Tuple{Char, Char}, String},
        prev_costs::Dict{Tuple{Char, Char}, Int},
        buttons::Dict{Char, Point}
    )
        costs = Dict{Tuple{Char, Char}, Int}()
        for btn1 in ROBOT_BUTTONS_KEYS, btn2 in ROBOT_BUTTONS_KEYS
            btn1 == btn2 && continue
            seq = basic_sequences[(btn1, btn2)]
            ch1 = 'A'
            cost = 0
            for ch2 in seq
                cost += get(prev_costs, (ch1, ch2), 1)
                ch1 = ch2
            end
            costs[(btn1, btn2)] = cost
        end
        return costs
    end

    function get_button_sequence(from::Point, to::Point, buttons::Dict{Char, Point}, empty_btn::Point)
        io = IOBuffer()
        press_button(io, from, to, buttons, empty_btn)
        return String(take!(io))
    end

    function get_numpad_sequence(code::String)
        total_seq = ""
        ch1 = 'A'
        for ch2 in code
            seq = get_button_sequence(DOOR_BUTTONS[ch1], DOOR_BUTTONS[ch2], DOOR_BUTTONS, (4, 1))
            total_seq *= seq
            ch1 = ch2
        end
        return total_seq
    end
end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (126384, 154115708116294)),
        ("input.txt" => (215374, 260586897262600)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
