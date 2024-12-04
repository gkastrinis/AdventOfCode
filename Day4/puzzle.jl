module AoC_24_Day4

function run_actual(path::String)
    input = read(path, String)
    return solve(input)
end

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
    return (input1D, rows, columns)
end

function solve(input::String)
    input1D, rows, columns = prepare_input(input)
    return (part1(input1D, rows, columns), part2(input1D, rows, columns))
end

is_mas(input, i1, i2, i3) = (input[i1] == 'M' && input[i2] == 'A' && input[i3] == 'S')

# 2493
function part1(input1D::String, rows::Int, columns::Int)
    len = length(input1D)
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
        # Diagonal 1 ↘
        if curr_row + 3 <= rows && curr_col + 3 <= columns && is_mas(input1D, x+columns+1, x+2*columns+2, x+3*columns+3)
            score += 1
        end
        # Diagonal 2 ↖
        if curr_row >= 4 && curr_col >= 4 && is_mas(input1D, x-columns-1, x-2*columns-2, x-3*columns-3)
            score += 1
        end
        # Diagonal 3 ↙
        if curr_row + 3 <= rows && curr_col >= 4 && is_mas(input1D, x+columns-1, x+2*columns-2, x+3*columns-3)
            score += 1
        end
        # Diagonal 4 ↗
        if curr_row >= 4 && curr_col + 3 <= columns && is_mas(input1D, x-columns+1, x-2*columns+2, x-3*columns+3)
            score += 1
        end
    end
    return score
end

function part2(input1D::String, rows::Int, columns::Int)
    return nothing
end

end
