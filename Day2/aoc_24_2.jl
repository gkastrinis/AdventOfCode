module AoC_24_Day2

function run_actual(path::String)
    input = read(path, String)
    return solve(input)
end

function run_example1()
    input = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
    """
    return solve(input)
end

function prepare_input(input::String)
    lines = filter(line -> !isempty(lstrip(line)), split(input, "\n"))
    return lines
end

function solve(input::String)
    lines = prepare_input(input)
    return (solve_part1(lines), solve_part2(lines))
end

function solve_part1(lines::Vector{String})
    return nothing
end

function solve_part2(lines::Vector{String})
    return nothing
end

end
