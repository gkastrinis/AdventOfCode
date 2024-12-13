module AoC_24_Day13

include("../AoC_Utils.jl")

using .AoC_Utils: Point, @n_times, next_int

struct Configuration
    button_a::Tuple{Int, Int}
    button_b::Tuple{Int, Int}
    prize::Point
end

struct State
    configurations::Vector{Configuration}
end

function State(input::String)
    configurations = Configuration[]
    io = IOBuffer(input)
    while !eof(io)
        # Button A: X+
        @n_times 12 read(io, Char)
        a_x = next_int(io)
        # , Y+
        @n_times 4 read(io, Char)
        a_y = next_int(io)
        # \n
        read(io, Char)
        # Button B: X+
        @n_times 12 read(io, Char)
        b_x = next_int(io)
        # , Y+
        @n_times 4 read(io, Char)
        b_y = next_int(io)
        # \n
        read(io, Char)
        # Prize: X=
        @n_times 9 read(io, Char)
        prize_x = next_int(io)
        # , Y=
        @n_times 4 read(io, Char)
        prize_y = next_int(io)
        # \n
        read(io, Char)

        push!(configurations, Configuration((a_x, a_y), (b_x, b_y), (prize_x, prize_y)))

        eof(io) && break
        # \n
        read(io, Char)
    end
    return State(configurations)
end

cost(a_times::Int, b_times::Int) = a_times * 3 + b_times * 1

function pretty_print(configuration::Configuration)
    printstyled("Button A: X+"; color=:black)
    printstyled(configuration.button_a[1]; color=:green)
    printstyled(", Y+"; color=:black)
    printstyled(configuration.button_a[2]; color=:green)
    printstyled("\n"; color=:black)
    printstyled("Button B: X+"; color=:black)
    printstyled(configuration.button_b[1]; color=:green)
    printstyled(", Y+"; color=:black)
    printstyled(configuration.button_b[2]; color=:green)
    printstyled("\n"; color=:black)
    printstyled("Prize: X="; color=:black)
    printstyled(configuration.prize[1]; color=:green)
    printstyled(", Y="; color=:black)
    printstyled(configuration.prize[2]; color=:green)
    printstyled("\n"; color=:black)
    return nothing
end

############################################################################################

module Part1
    using ..AoC_24_Day13: Configuration, State, cost

    function solve(state::State)
        total_cost = 0
        for configuration in state.configurations
            cost = solve_configuration_brute_force(configuration)
            cost > 0 && (total_cost += cost)
        end
        return total_cost
    end

    const MAX_COST = cost(201, 0)

    function solve_configuration_brute_force(configuration::Configuration)
        best_cost = MAX_COST
        for a in 1:100
            for b in 1:100
                current = configuration.button_a * a + configuration.button_b * b
                current == configuration.prize || continue
                current_cost = cost(a, b)
                current_cost < best_cost && (best_cost = current_cost)
            end
        end
        return best_cost == MAX_COST ? 0 : best_cost
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day13: State

    function solve(state::State)
        return nothing
    end
end

############################################################################################
############################################################################################

using .AoC_Utils: @filedata, test_assert

solve_part1(path::String) = Part1.solve(State(@filedata path))
solve_part2(path::String) = Part2.solve(State(@filedata path))

function test()
    for (path, args) in [
        ("example1.txt" => (480, nothing)),
    ]
        expected1, expected2 = args
        printstyled("--- testing: ", path, " ---\n"; color=:yellow)
        test_assert("Part 1", expected1, solve_part1(path))
        test_assert("Part 2", expected2, solve_part2(path))
    end
    return nothing
end

end
