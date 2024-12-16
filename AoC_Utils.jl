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
    sign = if !eof(io) && peek(io, Char) == '-'
        read(io, Char)
        -1
    else
        1
    end
    while !eof(io)
        ch = peek(io, Char)
        '0' <= ch <= '9' || break
        read(io, Char)
        digit = ch - '0'
        res = isnothing(res) ? digit : res * 10 + digit
    end
    isnothing(res) && return nothing
    return sign * res
end

############################################################################################

const Point = Tuple{Int, Int}

const Direction = Tuple{Int, Int}
const N = (-1, 0)
const E = (0, 1)
const S = (1, 0)
const W = (0, -1)
const NE = (-1, 1)
const SE = (1, 1)
const SW = (1, -1)
const NW = (-1, -1)
const DIR_TO_SYMBOL = Dict(N => "N", S => "S", E => "E", W => "W", NE => "NE", SE => "SE", SW => "SW", NW => "NW")
const LEFT_TURN = Dict(N => W, W => S, S => E, E => N)
const RIGHT_TURN = Dict(N => E, E => S, S => W, W => N)

Base.:+(p::Point, dir::Direction) = (p[1] + dir[1], p[2] + dir[2])
Base.:-(p::Point, dir::Direction) = (p[1] - dir[1], p[2] - dir[2])
Base.:*(p::Point, times::Int) = (p[1] * times, p[2] * times)

function pretty_print(f::Function, m::Matrix{T}, interactive::Bool=true) where T
    interactive && (sleep(0.1); Base.run(`clear`))
    println("\n")
    for i in 1:size(m, 1)
        for j in 1:size(m, 2)
            f(i, j)
        end
        println()
    end
    return nothing
end

function in_bounds(grid::Matrix{T}, point::Point) where T
    return in_bounds(grid, point[1], point[2])
end

function in_bounds(grid::Matrix{T}, row::Int, column::Int) where T
    return 1 <= row <= size(grid, 1) && 1 <= column <= size(grid, 2)
end

function read_grid(f::Function, io::IO, rows::Int, columns::Int)
    grid = Matrix{Char}(undef, rows, columns)
    i = j = 1
    while !eof(io)
        ch = read(io, Char)
        if ch == '\n'
            i += 1
            j = 1
        else
            grid[i, j] = ch
            f(i, j, ch)
            j += 1
        end
    end
    return grid
end

end
