module AoC_24_DayX

struct Input
end

function Input(input::String)
    return Input()
end

############################################################################################

module Part1
    using ..AoC_24_DayX: Input

    function solve(input::Input)
        return nothing
    end
end

############################################################################################

module Part2
    using ..AoC_24_DayX: Input

    function solve(input::Input)
        return nothing
    end
end

############################################################################################
############################################################################################

solve_part1(data::String) = Part1.solve(Disk(data))

solve_part2(data::String) = Part2.solve(Disk(data))

with_file_input(path::String, f::Function) = f(read(path, String))

solve_file(path::String) = with_file_input(path, solve_all)

function solve_all(path::String)
    printstyled("Part 1: "; color=:black)
    printstyled(with_file_input(path, solve_part1), "\n"; color=:blue)
    printstyled("Part 2: "; color=:black)
    printstyled(with_file_input(path, solve_part1), "\n"; color=:green)
    return nothing
end

function test()
    function assert_result(tag, expected, actual)
        printstyled(tag, ": "; color=:black)
        printstyled(expected; color=:green)
        printstyled(" == "; color=:black)
        if !isnothing(actual) && actual == expected
            printstyled(actual, " ✅\n"; color=:green)
        else
            printstyled(actual, " ❌\n"; color=:red)
        end
    end

    for (file, expected) in [
        ("example1.txt" => (nothing, nothing)),
    ]
        expected1, expected2 = expected
        printstyled("--- testing: ", file, " ---\n"; color=:yellow)
        assert_result("Part 1", expected1, with_file_input(file, solve_part1))
        assert_result("Part 2", expected2, with_file_input(file, solve_part2))
    end
end

end
