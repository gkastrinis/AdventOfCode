module AoC_24_DayX

struct Input
end

function Input(input::String)
    return Input()
end

solve_file(path::String) = solve(read(path, String))

function solve(inputStr::String)
    input = Input(inputStr)
    input_clone = deepcopy(input)
    printstyled("Part 1: ", Part1.solve(input), "\n"; color=:blue)
    printstyled("Part 2: ", Part2.solve(input_clone), "\n"; color=:yellow)
    return nothing
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

end
