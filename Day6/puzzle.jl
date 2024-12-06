module AoC_24_Day6

mutable struct Info
    rows::Int
    columns::Int
    matrix::Matrix{Char}
    guard::Tuple{Int, Int} # (x, y)
    moveVector::Tuple{Int, Int} # (dx, dy)
end

const N = (-1, 0)
const E = (0, 1)
const S = (1, 0)
const W = (0, -1)

run(path::String) = solve(read(path, String))

function solve(input::String)
    info = preprocess(input)
    printstyled("Part 1: ", part1(info), "\n"; color=:yellow)
    printstyled("Part 2: ", part2(info), "\n"; color=:blue)
    return nothing
end

function part1(info::Info)
    score = 1
    while true
        (new_tiles, went_out) = move_guard(info)
        score += new_tiles
        went_out && break
        turn_guard(info)
    end
    return score
end

function part2(info::Info)
    return nothing
end

function move_guard(info::Info)
    new_tiles = 0
    while true
        x, y = add(info.guard, info.moveVector)
        if x < 1 || x > info.columns || y < 1 || y > info.rows
            return (new_tiles, true)
        elseif info.matrix[x, y] == '#'
            return (new_tiles, false)
        elseif info.matrix[x, y] == 'X'
            info.guard = (x, y)
        elseif info.matrix[x, y] == '.'
            info.guard = (x, y)
            new_tiles += 1
            info.matrix[x, y] = 'X'
        end
    end
end

function turn_guard(info::Info)
    info.moveVector == N && (info.moveVector = E; return)
    info.moveVector == E && (info.moveVector = S; return)
    info.moveVector == S && (info.moveVector = W; return)
    info.moveVector == W && (info.moveVector = N; return)
    return nothing
end

add(p1, p2) = (p1[1] + p2[1], p1[2] + p2[2])

function preprocess(input::String)
    rows = count(==('\n'), input)
    columns = findnext('\n', input, 1) - 1
    matrix = Matrix{Char}(undef, rows, columns)
    i = j = 1
    guard = moveVector = (0, 0)
    io = IOBuffer(input)
    while !eof(io)
        ch = read(io, Char)
        if ch == '\n'
            i += 1
            j = 1
        else
            matrix[i, j] = ch
            if ch in ('^', 'v', '>', '<')
                guard = (i, j)
                if     ch == '^' moveVector = N
                elseif ch == 'v' moveVector = S
                elseif ch == '>' moveVector = E
                elseif ch == '<' moveVector = W
                end
                matrix[i, j] = 'X'
            end
            j += 1
        end
    end
    return Info(rows, columns, matrix, guard, moveVector)
end

end
