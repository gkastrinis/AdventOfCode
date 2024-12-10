module Puzzle

function solve_part1(data::String) end

function solve_part2(data::String) end

with_file_input(path::String, f::Function) = f(read(path, String))

solve_file(path::String) = with_file_input(path, solve_all)

function solve_all(data::String)
    printstyled("Part 1: "; color=:black)
    printstyled(solve_part1(data), "\n"; color=:blue)
    printstyled("Part 2: "; color=:black)
    printstyled(solve_part2(data), "\n"; color=:green)
    return nothing
end

function test_harness(facts)
    function assert_result(tag, expected, actual)
        if isnothing(expected)
            printstyled(tag, " ❔: nothing == $(actual)\n"; color=:magenta)
        elseif !isnothing(actual) && actual == expected
            printstyled(tag, " ✅: "; color=:green)
            printstyled(expected; color=:green)
            printstyled(" = "; color=:black)
            printstyled(actual, "\n"; color=:green)
        else
            printstyled(tag, " ❌: "; color=:red)
            printstyled(expected; color=:green)
            printstyled(" ≠ "; color=:black)
            printstyled(actual, "\n"; color=:red)
        end
        return nothing
    end

    for (file, expected) in facts
        expected1, expected2 = expected
        printstyled("--- testing: ", file, " ---\n"; color=:yellow)
        assert_result("Part 1", expected1, with_file_input(file, solve_part1))
        assert_result("Part 2", expected2, with_file_input(file, solve_part2))
    end
    return nothing
end

end
