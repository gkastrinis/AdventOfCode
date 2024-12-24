module AoC_24_Day24

include("../../AoC_Utils.jl")

struct Gate
    kind::Char
    op::Function
    in1::AbstractString
    in2::AbstractString
    out::AbstractString
    out_value::Ref{UInt8}
end

function Gate(out::AbstractString, out_value::UInt8)
    return Gate('.', ==, "", "", out, Ref{UInt8}(out_value))
end

struct Puzzle
    out_wire_to_gate::Dict{AbstractString,Gate}
    xs::Vector{AbstractString}
    ys::Vector{AbstractString}
    zs::Vector{AbstractString}
end

function Puzzle(input::String)
    out_wire_to_gate = Dict{AbstractString,Gate}()
    xs = Vector{AbstractString}()
    ys = Vector{AbstractString}()
    zs = Vector{AbstractString}()

    part1, part2 = split(input, "\n\n")
    for line in split(part1, '\n')
        wire, value = split(line, ": ")
        gate = Gate(wire, parse(UInt8, value))
        out_wire_to_gate[wire] = gate
        wire[1] == 'x' && push!(xs, wire)
        wire[1] == 'y' && push!(ys, wire)
    end
    for line in split(part2, '\n'; keepempty=false)
        kind = line[5]
        idx = (kind == 'A' || kind == 'X') ? 9 : 8
        kind == 'A' && (op = (x, y) -> (x == y == 1) ? 1 : 0)
        kind == 'X' && (op = (x, y) -> (x != y) ? 1 : 0)
        kind == 'O' && (op = (x, y) -> (x == 1 || y == 1) ? 1 : 0)
        gate = Gate(
            kind,
            op,
            (@view line[1:3]),
            (@view line[idx:idx+2]),
            (@view line[idx+7:end]),
            Ref{UInt8}(2)
        )
        out_wire_to_gate[gate.out] = gate
        gate.out[1] == 'z' && push!(zs, gate.out)
    end
    return Puzzle(out_wire_to_gate, sort!(xs), sort!(ys), sort!(zs))
end

############################################################################################

module Part1
    using ..AoC_24_Day24: Gate,Puzzle

    function solve(puzzle::Puzzle)
        level_to_gates = topological_sort(puzzle)
        propagate_inputs(puzzle, level_to_gates)
        result = foldl(puzzle.zs, init=(0,1)) do acc, wire
            val, two_power = acc
            return (val + out_value(puzzle, wire) * two_power, two_power * 2)
        end
        return result[1]
    end

    function out_value(puzzle::Puzzle, wire::AbstractString)
        return puzzle.out_wire_to_gate[wire].out_value[]
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

    function topological_sort(puzzle::Puzzle)
        out_wire_to_level = Dict{AbstractString,Int}()
        for x_wire in puzzle.xs
            out_wire_to_level[x_wire] = 0
        end
        for y_wire in puzzle.ys
            out_wire_to_level[y_wire] = 0
        end
        for gate in values(puzzle.out_wire_to_gate)
            topological_sort_level(gate, puzzle.out_wire_to_gate, out_wire_to_level)
        end
        level_to_gates = Dict{Int,Set{Gate}}()
        for (w, lvl) in out_wire_to_level
            gate = puzzle.out_wire_to_gate[w]
            level_gates = get!(level_to_gates, lvl, Set{Gate}())
            push!(level_gates, gate)
        end
        return level_to_gates
    end

    function propagate_inputs(puzzle::Puzzle, level_to_gates::Dict{Int,Set{Gate}})
        max_lvl = maximum(keys(level_to_gates))
        for lvl in 1:max_lvl
            lvl_gates = level_to_gates[lvl]
            for gate in lvl_gates
                in_val1 = out_value(puzzle, gate.in1)
                in_val2 = out_value(puzzle, gate.in2)
                gate.out_value[] = gate.op(in_val1, in_val2)
            end
        end
        return nothing
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day24: Gate, Puzzle

    # If this is a normal adder, each Xi and Yi are ANDed to get Carry_i, and XORed to get Sum_i.
    # Sum_i is XORed with the previous carry to get the final Zi.
    # Sum_i is ANDed with the previous carry to get the Carry_i_2.
    # Carry_i and Carry_i_2 are ORed to get the final carry.
    #
    # Xi AND Yi = Carry_i
    # Xi XOR Yi = Sum_i
    # Sum_i XOR Prev_carry = Zi
    # Sum_i AND Prev_carry = Carry_i_2
    # Carry_i OR Carry_i_2 = Carry
    #
    # For N bits, we have
    # 2N "input" gates, 2N AND gates, and 2N XOR gates, N OR gates == 7N gates
    # The first input bit doesn't have a previous carry, so -3 gates (one OR, one AND, one XOR).
    function solve(puzzle::Puzzle)
        # Just assert that the input is a ripple-carry adder.
        xs_len = length(puzzle.xs)
        ys_len = length(puzzle.ys)
        zs_len = length(puzzle.zs)
        all_gates_len = length(puzzle.out_wire_to_gate)
        and_gates = Set{Gate}()
        xor_gates = Set{Gate}()
        or_gates = Set{Gate}()
        for gate in values(puzzle.out_wire_to_gate)
            gate.kind == 'A' && push!(and_gates, gate)
            gate.kind == 'X' && push!(xor_gates, gate)
            gate.kind == 'O' && push!(or_gates, gate)
        end
        N = xs_len
        @assert ys_len == N
        @assert zs_len == N + 1
        @assert length(and_gates) == 2*N - 1
        @assert length(xor_gates) == 2*N - 1
        @assert length(or_gates) == N - 1
        @assert all_gates_len == (xs_len + ys_len) * 3 + xs_len - 3
        ############################################################################

        wrong_wires = Set{AbstractString}()

        # AND and XOR gates should have Xs and Ys as inputs, or have one XOR and one OR input.
        and_xor_gates = union(and_gates, xor_gates)
        for gate in and_xor_gates
            # Gates with inputs from X and Y are valid.
            gate.in1[1] in ('x', 'y') && gate.in2[1] in ('x', 'y') && continue
            # Otherwise, one input should be from XOR and the other from OR.
            in_gate1 = puzzle.out_wire_to_gate[gate.in1]
            in_gate2 = puzzle.out_wire_to_gate[gate.in2]
            match_gate_kinds(in_gate1, in_gate2, 'X', 'O') && continue
            # The first bits don't have a previous carry, so an AND gate with x00 and y00 is valid.
            if match_gate_kinds(in_gate1, in_gate2, 'X', 'A')
                input_and_gate = (in_gate1.kind == 'A' ? in_gate1 : in_gate2)
                if input_and_gate.in1 == "x00" && input_and_gate.in2 == "y00" ||
                    input_and_gate.in1 == "y00" && input_and_gate.in2 == "x00"
                    continue
                end
            end

            # If both inputs are XOR, the invalid one is that not using Xs and Ys
            if match_gate_kinds(in_gate1, in_gate2, 'X', 'X')
                if in_gate1.in1[1] == 'x' && in_gate1.in2[1] == 'y' ||
                    in_gate1.in1[1] == 'y' && in_gate1.in2[1] == 'x'
                    push!(wrong_wires, in_gate2.out)
                else
                    push!(wrong_wires, in_gate1.out)
                end
                continue
            end

            invalid_gate1 = in_gate1.kind == 'X' && in_gate2.kind != 'O' ? in_gate2 : in_gate1
            invalid_gate2 = in_gate2.kind == 'X' && in_gate1.kind != 'O' ? in_gate1 : in_gate2
            invalid_gate1.kind == 'A' && push!(wrong_wires, invalid_gate1.out)
            invalid_gate2.kind == 'A' && push!(wrong_wires, invalid_gate2.out)
        end

        for gate in or_gates
            # OR gates should have inputs from AND.
            in_gate1 = puzzle.out_wire_to_gate[gate.in1]
            in_gate2 = puzzle.out_wire_to_gate[gate.in2]
            match_gate_kinds(in_gate1, in_gate2, 'A', 'A') && continue
            in_gate1.kind != 'A' && push!(wrong_wires, in_gate1.out)
            in_gate2.kind != 'A' && push!(wrong_wires, in_gate2.out)
        end

        # All but the last Z should be from XOR.
        for z_wire in @view puzzle.zs[1:end-1]
            gate = puzzle.out_wire_to_gate[z_wire]
            gate.kind == 'X' && continue
            push!(wrong_wires, gate.out)
        end

        return join(sort!(collect(wrong_wires)), ",")
    end

    function Base.show(io::IO, gate::Gate)
        op = gate.kind == 'A' ? "AND" : gate.kind == 'X' ? "XOR" : "OR"
        print(io, gate.in1, "  ", op, "  ", gate.in2, " -> ", gate.out)
    end

    function match_gate_kinds(gate1::Gate, gate2::Gate, expected1::Char, expected2::Char)
        return gate1.kind == expected1 && gate2.kind == expected2 ||
            gate1.kind == expected2 && gate2.kind == expected1
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
