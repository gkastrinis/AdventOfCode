module AoC_24_Day24

include("../../AoC_Utils.jl")

struct Gate
    op::Function
    in1::AbstractString
    in2::AbstractString
    out::AbstractString
    out_value::Ref{UInt8}
end

function Gate(out::AbstractString, out_value::UInt8)
    return Gate(==, "", "", out, Ref{UInt8}(out_value))
end

struct Puzzle
    level_to_gates::Dict{Int,Set{Gate}}
    out_wire_to_gate::Dict{AbstractString,Gate}
    result_wires::Vector{AbstractString}
end

function Puzzle(input::String)
    all_gates = Set{Gate}()
    out_wire_to_gate = Dict{AbstractString,Gate}()
    out_wire_to_level = Dict{AbstractString,Int}()
    result_wires = Vector{AbstractString}()

    part1, part2 = split(input, "\n\n")
    for line in split(part1, '\n')
        wire, value = split(line, ": ")
        gate = Gate(wire, parse(UInt8, value))
        push!(all_gates, gate)
        out_wire_to_gate[wire] = gate
        out_wire_to_level[wire] = 0
    end
    for line in split(part2, '\n'; keepempty=false)
        kind = line[5]
        idx = (kind == 'A' || kind == 'X') ? 9 : 8
        gate = Gate(
            get_op(kind),
            (@view line[1:3]),
            (@view line[idx:idx+2]),
            (@view line[idx+7:end]),
            Ref{UInt8}(2)
        )
        push!(all_gates, gate)
        out_wire_to_gate[gate.out] = gate
        gate.out[1] == 'z' && push!(result_wires, gate.out)
    end

    for gate in all_gates
        topological_sort_level(gate, out_wire_to_gate, out_wire_to_level)
    end
    level_to_gates = Dict{Int,Set{Gate}}()
    for (w, lvl) in out_wire_to_level
        gate = out_wire_to_gate[w]
        level_gates = get!(level_to_gates, lvl, Set{Gate}())
        push!(level_gates, gate)
    end
    return Puzzle(level_to_gates, out_wire_to_gate, sort!(result_wires))
end

function topological_sort_level(
    gate::Gate,
    out_wire_to_gate::Dict{AbstractString,Gate},
    out_wire_to_level::Dict{AbstractString,Int}
)
    haskey(out_wire_to_level, gate.out) && return out_wire_to_level[gate.out]
    in_gate1 = out_wire_to_gate[gate.in1]
    in_gate2 = out_wire_to_gate[gate.in2]
    in_lvl1 = topological_sort_level(in_gate1, out_wire_to_gate, out_wire_to_level)
    in_lvl2 = topological_sort_level(in_gate2, out_wire_to_gate, out_wire_to_level)
    out_lvl = max(in_lvl1, in_lvl2) + 1
    out_wire_to_level[gate.out] = out_lvl
    return out_lvl
end

function get_op(kind::Char)
    kind == 'A' && return (x, y) -> (x == y == 1) ? 1 : 0
    kind == 'X' && return (x, y) -> (x != y) ? 1 : 0
    kind == 'O' && return (x, y) -> (x == 1 || y == 1) ? 1 : 0
    @assert(false)
end

############################################################################################

module Part1
    using ..AoC_24_Day24: Puzzle

    function solve(puzzle::Puzzle)
        max_lvl = maximum(keys(puzzle.level_to_gates))
        for lvl in 1:max_lvl
            lvl_gates = puzzle.level_to_gates[lvl]
            for gate in lvl_gates
                in_val1 = out_value(puzzle, gate.in1)
                in_val2 = out_value(puzzle, gate.in2)
                gate.out_value[] = gate.op(in_val1, in_val2)
            end
        end
        result = foldl(puzzle.result_wires, init=(0,1)) do acc, wire
            val, two_power = acc
            return (val + out_value(puzzle, wire) * two_power, two_power * 2)
        end
        return result[1]
    end

    function out_value(puzzle::Puzzle, wire::AbstractString)
        return puzzle.out_wire_to_gate[wire].out_value[]
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day24: Puzzle

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
        ("example1.txt" => (4, nothing)),
        ("example2.txt" => (2024, nothing)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
