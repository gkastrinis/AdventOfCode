module AoC_24_Day4

run_actual(path::String) = solve(read(path, String))

function run_example()
    input = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""
    return solve(input)
end

function prepare_input(input::String)
    rows = count(==('\n'), input)
    columns = findnext('\n', input, 1) - 1
    input1D = replace(input, '\n' => "")
    len = length(input1D)
    return (input1D, rows, columns, len)
end

function solve(input::String)
    input1D, rows, columns, len = prepare_input(input)
    printstyled("Part 1: ", part1(input1D, rows, columns, len), "\n"; color=:yellow)
    printstyled("Part 2: ", part2(input1D, rows, columns, len), "\n"; color=:blue)
    return nothing
end

is_mas(str, i1, i2, i3) = (str[i1] == 'M' && str[i2] == 'A' && str[i3] == 'S')

function part1(input1D::String, rows::Int, columns::Int, len::Int)
    score = 0
    xs = findall(==('X'), input1D)
    for x in xs
        curr_row = (x - 1) ÷ columns + 1
        curr_col = (x - 1) % columns + 1
        # Horizontal →
        if curr_col + 3 <= columns && is_mas(input1D, x+1, x+2, x+3)
            score += 1
        end
        # Horizontal ←
        if curr_col >= 4 && is_mas(input1D, x-1, x-2, x-3)
            score += 1
        end
        # Vertical ↓
        if curr_row + 3 <= rows && is_mas(input1D, x+columns, x+2*columns, x+3*columns)
            score += 1
        end
        # Vertical ↑
        if curr_row >= 4 && is_mas(input1D, x-columns, x-2*columns, x-3*columns)
            score += 1
        end
        # Diagonal ↘
        if curr_row + 3 <= rows && curr_col + 3 <= columns && is_mas(input1D, x+columns+1, x+2*columns+2, x+3*columns+3)
            score += 1
        end
        # Diagonal ↖
        if curr_row >= 4 && curr_col >= 4 && is_mas(input1D, x-columns-1, x-2*columns-2, x-3*columns-3)
            score += 1
        end
        # Diagonal ↙
        if curr_row + 3 <= rows && curr_col >= 4 && is_mas(input1D, x+columns-1, x+2*columns-2, x+3*columns-3)
            score += 1
        end
        # Diagonal ↗
        if curr_row >= 4 && curr_col + 3 <= columns && is_mas(input1D, x-columns+1, x-2*columns+2, x-3*columns+3)
            score += 1
        end
    end
    return score
end

is_ms_unordered(str, i1, i2) = (str[i1] == 'M' && str[i2] == 'S') || (str[i1] == 'S' && str[i2] == 'M')

function part2(input1D::String, rows::Int, columns::Int, len::Int)
    score = 0
    xs = findall(==('A'), input1D)
    for x in xs
        curr_row = (x - 1) ÷ columns + 1
        curr_col = (x - 1) % columns + 1
        (curr_row >= 2 && curr_row + 1 <= rows && curr_col >= 2 && curr_col + 1 <= columns) || continue
        # Diagonals ↘ | ↖
        diag1 = is_ms_unordered(input1D, x-columns-1, x+columns+1)
        # Diagonals ↙ | ↗
        diag2 = is_ms_unordered(input1D, x+columns-1, x-columns+1)
        diag1 && diag2 && (score += 1)
    end
    return score
end

end
