module AoC_Utils

file_data(path) = read(path, String)

function test_assert(tag, expected, actual)
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

function count_digits(n::Int)
    digits = 1
    while n >= 10
        n = n ÷ 10
        digits += 1
    end
    return digits
end

end
