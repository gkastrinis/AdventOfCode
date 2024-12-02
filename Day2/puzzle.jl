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
    reports = Vector{Vector{Int}}(undef, length(lines))
    for (i, line) in enumerate(lines)
        parts = split(line; keepempty=false)
        reports[i] = map(part -> parse(Int, part), parts)
    end
    return reports
end

function solve(input::String)
    reports = prepare_input(input)
    return (solve_part1(reports), solve_part2(reports))
end

function solve_part1(reports::Vector{Vector{Int}})
    safe_count = 0
    for report in reports
        sign = (report[2] - report[1]) > 0 ? 1 : -1
        prev = report[1]
        is_safe = true
        for num in (@view report[2:end])
            diff = num - prev
            if diff * sign <= 0 || abs(diff) > 3
                is_safe = false
                break
            end
            prev = num
        end
        safe_count += is_safe ? 1 : 0
    end
    return safe_count
end

function solve_part2(reports::Vector{Vector{Int}})
    return nothing
end

end
