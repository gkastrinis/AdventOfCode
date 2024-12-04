module AoC_24_Day1

function run_actual(path::String)
    input = read(path, String)
    return solve(input)
end

function run_example()
    input = """
3   4
4   3
2   5
1   3
3   9
3   3
    """
    return solve(input)
end

function prepare_input(input::String)
    lines = filter(line -> !isempty(lstrip(line)), split(input, "\n"))
    list1 = Vector{Int}(undef, length(lines))
    list2 = Vector{Int}(undef, length(lines))
    for (i, line) in enumerate(lines)
        parts = split(line; keepempty=false)
        list1[i] = parse(Int, parts[1])
        list2[i] = parse(Int, parts[2])
    end
    sort!(list1)
    sort!(list2)
    return (list1, list2)
end

function solve(input::String)
    list1, list2 = prepare_input(input)
    printstyled("Part 1: ", part1(list1, list2), "\n"; color=:yellow)
    printstyled("Part 2: ", part2(list1, list2), "\n"; color=:blue)
    return nothing
end

# 1651298
function part1(list1::Vector{Int}, list2::Vector{Int})
    diffs = Vector{Int}(undef, length(list1))
    for i in 1:length(list1)
        diffs[i] = abs(list1[i] - list2[i])
    end
    return sum(diffs)
end

# 21306195
function part2(list1::Vector{Int}, list2::Vector{Int})
    score = 0
    for num in list1
        score += num * count(==(num), list2)
    end
    return score
end

end
