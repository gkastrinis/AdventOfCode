module AoC_24_Day3

function run_actual(path::String)
    input = read(path, String)
    return solve(input)
end

function run_example()
    input = """
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
"""
    return solve(input)
end

function run_example2()
    input = """
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
"""
    return solve(input)
end

function solve(input::String)
    return (part1(input), part2(input))
end

function part1_alt(input::String)
    score = 0
    regex = r"mul\(([0-9]+),([0-9]+)\)"
    for m in eachmatch(regex, input)
        score += parse(Int, m.captures[1]) * parse(Int, m.captures[2])
    end
    return score
end

# 173419328
function part1(input::String)
    score = 0
    for i in firstindex(input):lastindex(input)
        i, val = parse_mul(input, i)
        score += val
        i = nextind(input, i)
    end
    return score
end

function parse_mul(input::String, i::Int)
    startswith((@view input[i:end]), "mul(") || return (i, 0)
    i = nextind(input, i, 4)
    (i, X) = parse_possitive_int_until(input, i, ',')
    X == -1 && return (i, 0)
    (i, Y) = parse_possitive_int_until(input, i, ')')
    Y == -1 && return (i, 0)
    return (i, X * Y)
end

function parse_possitive_int_until(input::String, i::Int, until::Char)
    V = 0
    while input[i] != until
        ch = input[i]
        (ch >= '0' && ch <= '9') || return (i, -1)
        V = (10*V) + (ch - '0')
        i = nextind(input, i)
    end
    return (nextind(input, i), V)
end

# 90669332
function part2(input::String)
    score = 0
    enabled = 1
    for i in firstindex(input):lastindex(input)
        if startswith((@view input[i:end]), "do()")
            enabled = 1
            i = nextind(input, i, 4)
        elseif startswith((@view input[i:end]), "don't()")
            enabled = 0
            i = nextind(input, i, 6)
        else
            i, val = parse_mul(input, i)
            score += val * enabled
            i = nextind(input, i)
        end
    end
    return score
end

end
