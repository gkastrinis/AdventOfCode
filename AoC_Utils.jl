module AoC_Utils

macro filedata(path)
    return quote
        read($(esc(path)), String)
    end
end

macro n_times(n, body)
    return quote
        for _ in 1:$(esc(n))
            $(esc(body))
        end
    end
end

############################################################################################

const Point = Tuple{Int, Int}

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

function next_int(io::IO)
    res = nothing
    while !eof(io)
        ch = peek(io, Char)
        isspace(ch) || break
        read(io, Char)
    end
    while !eof(io)
        ch = peek(io, Char)
        '0' <= ch <= '9' || break
        read(io, Char)
        digit = ch - '0'
        res = isnothing(res) ? digit : res * 10 + digit
    end
    return res
end

function pretty_print(f::Function, m::Matrix{T}, interactive::Bool=true) where T
    interactive && (sleep(0.1); Base.run(`clear`))
    println("\n")
    for i in 1:size(m, 1)
        for j in 1:size(m, 2)
            f(i, j)
        end
        println('\n')
    end
    return nothing
end

function in_bounds(matrix::Matrix{T}, row::Int, column::Int) where T
    return 1 <= row <= size(matrix, 1) && 1 <= column <= size(matrix, 2)
end

end
