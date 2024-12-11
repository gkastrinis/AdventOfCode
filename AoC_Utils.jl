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

end
