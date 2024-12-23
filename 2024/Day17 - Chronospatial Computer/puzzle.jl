module AoC_24_Day17

include("../../AoC_Utils.jl")
using .AoC_Utils: Point, @n_times, next_int

mutable struct Puzzle
    regA::Int
    regB::Int
    regC::Int
    ip::Int
    program::Vector{UInt8}
    output::Vector{UInt8}
end

function Puzzle(input::String)
    io = IOBuffer(input)
    # Register A:
    @n_times 11 read(io, Char)
    regA = next_int(io)
    # \nRegister B:
    @n_times 12 read(io, Char)
    regB = next_int(io)
    # \nRegister C:
    @n_times 12 read(io, Char)
    regC = next_int(io)

    # \n\nProgram:_
    @n_times 11 read(io, Char)
    program = UInt8[]
    while !eof(io)
        ch = read(io, Char)
        push!(program, ch - '0')
        # ,
        read(io, Char)
    end
    return Puzzle(regA, regB, regC, 1, program, UInt8[])
end

function combo_operand(puzzle::Puzzle, operand::UInt8)
    0 <= operand <= 3 && return operand
    operand == 4 && return puzzle.regA
    operand == 5 && return puzzle.regB
    operand == 6 && return puzzle.regC
    @assert false
end

function adv(puzzle::Puzzle, ip::Int, operand::UInt8)
    operand = combo_operand(puzzle, operand)
    puzzle.regA = puzzle.regA >> operand
    return ip + 2
end

function bxl(puzzle::Puzzle, ip::Int, operand::UInt8)
    puzzle.regB = puzzle.regB ⊻ operand
    return ip + 2
end

function bst(puzzle::Puzzle, ip::Int, operand::UInt8)
    operand = combo_operand(puzzle, operand)
    puzzle.regB = operand % 8
    return ip + 2
end

function jnz(puzzle::Puzzle, ip::Int, operand::UInt8)
    puzzle.regA == 0 && return ip + 2
    return operand + 1
end

function bxc(puzzle::Puzzle, ip::Int, operand::UInt8)
    puzzle.regB = puzzle.regB ⊻ puzzle.regC
    return ip + 2
end

function out(puzzle::Puzzle, ip::Int, operand::UInt8)
    operand = combo_operand(puzzle, operand)
    push!(puzzle.output, (operand % 8))
    return ip + 2
end

function bdv(puzzle::Puzzle, ip::Int, operand::UInt8)
    operand = combo_operand(puzzle, operand)
    puzzle.regB = puzzle.regA >> operand
    return ip + 2
end

function cdv(puzzle::Puzzle, ip::Int, operand::UInt8)
    operand = combo_operand(puzzle, operand)
    puzzle.regC = puzzle.regA >> operand
    return ip + 2
end

const INSTRUCTIONS = [adv, bxl, bst, jnz, bxc, out, bdv, cdv]

function run!(puzzle::Puzzle)
    while puzzle.ip <= length(puzzle.program)
        code = puzzle.program[puzzle.ip]
        operand = puzzle.program[puzzle.ip + 1]
        puzzle.ip = INSTRUCTIONS[code + 1](puzzle, puzzle.ip, operand)
    end
    return nothing
end

############################################################################################

module Part1
    using ..AoC_24_Day17: Puzzle, run!

    function solve(puzzle::Puzzle)
        run!(puzzle)
        return join(puzzle.output, ',')
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day17: Puzzle, run!

    function reset!(puzzle::Puzzle, regA::Int, regB::Int, regC::Int)
        puzzle.regA = regA
        puzzle.regB = regB
        puzzle.regC = regC
        puzzle.ip = 1
        empty!(puzzle.output)
    end

    # Input is right-shifting the value of register A by 3 bits until it's zero.
    # Search trying to match the last output digit, trying 0-7 for values of register A.
    # For each valid value, *left-shift* the value of register A by 3 bits and add it to the working set.
    # The working set is a queue, in order to get the smallest solution first.
    function solve(puzzle::Puzzle)
        regB, regC = puzzle.regB, puzzle.regC
        target_output = puzzle.program
        max_span = length(target_output)
        # start x span
        working_set = Vector{Tuple{Int,Int}}()
        push!(working_set, (0, 1))
        while !isempty(working_set)
            (start, span) = pop!(working_set)
            subtarget = @view target_output[end-span+1:end]
            stop_candidates = next_octal_candidates!(puzzle, start, regB, regC, subtarget)

            span == max_span && !isempty(stop_candidates) && return stop_candidates[1]

            for stop in stop_candidates
                pushfirst!(working_set, (stop << 3, span + 1))
            end
        end
        printstyled("No solution found\n"; color=:red)
        return nothing
    end

    function next_octal_candidates!(puzzle::Puzzle, start::Int, B::Int, C::Int, target::AbstractVector{UInt8})
        candidates = Int[]
        for i in start:start+7
            reset!(puzzle, i, B, C)
            run!(puzzle)
            puzzle.output != target && continue
            push!(candidates, i)
        end
        return candidates
    end

end

############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(Puzzle(@filedata path))
solve_part2(path::String) = Part2.solve(Puzzle(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => ("4,6,3,5,6,3,5,2,1,0", nothing)),
        ("example2.txt" => ("5,7,3,0", 117440)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
