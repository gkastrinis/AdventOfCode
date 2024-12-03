module AoC_24_Day3

function run_actual(path::String)
    input = read(path, String)
    return solve(input)
end

function run_example()
    input = """
..
"""
    return solve(input)
end

function solve(input::String)
    return (solve_part1(input), solve_part2(input))
end

function solve_part1(input::String)
    return nothing
end

function solve_part2(input::String)
    return nothing
end

end
