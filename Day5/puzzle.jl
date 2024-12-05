module AoC_24_Day5

run(path::String) = solve(read(path, String))

Base.@kwdef struct Manual
    IsBefore::Dict{Int, Set{Int}} = Dict{Int, Set{Int}}()
    Updates::Vector{Vector{Int}} = Vector{Vector{Int}}()
end

function prepare_input(input::String)
    manual = Manual()
    io = IOBuffer(input)
    while !eof(io)
        line = readline(io)
        # We are in the second part of the input. Stop this loop.
        isempty(line) && break

        delim = findfirst(==('|'), line)
        x = parse(Int, @view line[1:delim-1])
        y = parse(Int, @view line[delim+1:end])
        manual.IsBefore[x] = get!(manual.IsBefore, x, Set{Int}()) ∪ Set([y])
    end
    while !eof(io)
        line = readline(io)
        isempty(line) && break
        pages = split(line, ",")
        push!(manual.Updates, parse.(Int, pages))
    end
    return manual
end

function solve(input::String)
    manual = prepare_input(input)
    printstyled("Part 1: ", part1(manual), "\n"; color=:yellow)
    printstyled("Part 2: ", part2(manual), "\n"; color=:blue)
    return nothing
end

function is_before(manual::Manual, page::Int, other::Int)
    return haskey(manual.IsBefore, page) && other in manual.IsBefore[page]
end

function middle_page(pages::AbstractVector{Int})
    return pages[length(pages)÷2 + 1]
end

function in_correct_order(manual::Manual, pages::AbstractVector{Int})
    # return all((i, page) -> all(other -> is_before(manual, page, other), @view pages[i+1:end]), enumerate(pages))
    f((i, page)) = all(other -> is_before(manual, page, other), @view pages[i+1:end])
    return all(f, enumerate(pages))
end

# 4959
function part1(manual::Manual)
    return sum(middle_page(pages) for pages in manual.Updates if in_correct_order(manual, pages))
end

# 4655
function part2(manual::Manual)
    score = 0
    for pages in manual.Updates
        page_len = length(pages)
        changed = false
        for i in 1:page_len
            for j in i+1:page_len
                other = pages[j]
                is_before(manual, pages[i], other) && continue
                pages[i], pages[j] = pages[j], pages[i]
                changed = true
            end
        end
        changed && (score += middle_page(pages))
    end
    return score
end

end
