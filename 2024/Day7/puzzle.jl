module AoC_24_Day7

struct Equation
    target::Int
    operands::Vector{Int}
end

function Input(input::String)
    equations = Equation[]
    io = IOBuffer(input)
    for line in eachline(io)
        colon = findnext(':', line, 1)
        eq = Equation(
            parse(Int, @view line[1:colon-1]),
            collect(parse(Int, op) for op in split(@view line[colon+1:end]))
        )
        push!(equations, eq)
    end
    return equations
end

solve_file(path::String) = solve(read(path, String))

function solve(input::String)
    equations = Input(input)
    printstyled("Part 1: ", part1_solve(equations), "\n"; color=:yellow)
    printstyled("Part 2: ", part2_solve(equations), "\n"; color=:blue)
    return nothing
end

function part1_solve(equations::Vector{Equation})
    return solve(equations, part1_validator)
end

function part2_solve(equations::Vector{Equation})
    return solve(equations, part2_validator)
end

function solve(equations::Vector{Equation}, validator::Function)
    return sum(eq.target for eq in equations if is_valid(eq, validator))
end

function is_valid(eq::Equation, validator::Function)
    head = eq.operands[1]
    tail = @view eq.operands[2:end]
    return validator(eq.target, tail, head)
end

############################################################################################

function part1_validator(target::Int, operands::AbstractVector{Int}, current::Int)
    isempty(operands) && return target == current
    head = operands[1]
    tail = @view operands[2:end]
    return part1_validator(target, tail, current + head) ||
        part1_validator(target, tail, current * head)
end

############################################################################################

function part2_validator(target::Int, operands::AbstractVector{Int}, current::Int)
    isempty(operands) && return target == current
    head = operands[1]
    tail = @view operands[2:end]
    return part2_validator(target, tail, current + head) ||
        part2_validator(target, tail, current * head) ||
        part2_validator(target, tail, concat(current, head))
end

function count_digits(n::Int)
    digits = 1
    while n >= 10
        n = n ÷ 10
        digits += 1
    end
    return digits
end

concat(op1::Int, op2::Int) = op1 * 10^count_digits(op2) + op2

end
