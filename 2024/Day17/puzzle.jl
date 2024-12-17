module AoC_24_Day17

include("../../AoC_Utils.jl")
using .AoC_Utils: Point, @n_times, next_int

mutable struct Puzzle
    regA::Int
    regB::Int
    regC::Int
    ip::Int
    program::Vector{UInt8}
    output::IOBuffer
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
    return Puzzle(regA, regB, regC, 1, program, IOBuffer())
end

function run_instruction!(puzzle::Puzzle)
    code = puzzle.program[puzzle.ip]
    operand = puzzle.program[puzzle.ip + 1]
    puzzle.ip = INSTRUCTIONS[code + 1](puzzle, puzzle.ip, operand)
    return
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
    puzzle.regA = puzzle.regA ÷ (2^operand)
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
    print(puzzle.output, (operand % 8), ',')
    return ip + 2
end

function bdv(puzzle::Puzzle, ip::Int, operand::UInt8)
    operand = combo_operand(puzzle, operand)
    puzzle.regB = puzzle.regA ÷ (2^operand)
    return ip + 2
end

function cdv(puzzle::Puzzle, ip::Int, operand::UInt8)
    operand = combo_operand(puzzle, operand)
    puzzle.regC = puzzle.regA ÷ (2^operand)
    return ip + 2
end

const INSTRUCTIONS = [adv, bxl, bst, jnz, bxc, out, bdv, cdv]

############################################################################################

module Part1
    using ..AoC_24_Day17: Puzzle, run_instruction!

    function solve(puzzle::Puzzle)
        program_len = length(puzzle.program)
        while puzzle.ip <= program_len
            run_instruction!(puzzle)
        end
        res = String(take!(puzzle.output))
        return res[end] == ',' ? res[1:end-1] : res
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day17: Puzzle

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
        ("example1.txt" => ("4,6,3,5,6,3,5,2,1,0", nothing)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
