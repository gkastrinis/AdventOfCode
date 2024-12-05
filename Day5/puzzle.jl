module AoC_24_Day5

run(path::String) = solve(read(path, String))

Base.@kwdef struct Manual
    IsBefore::Dict{Int, Set{Int}} = Dict{Int, Set{Int}}()
    IsAfter::Dict{Int, Set{Int}} = Dict{Int, Set{Int}}()
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
        manual.IsAfter[y] = get!(manual.IsAfter, y, Set{Int}()) ∪ Set([x])
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

function is_before_the_rest(manual::Manual, page::Int, rest::AbstractVector{Int})
    return all(
        after -> haskey(manual.IsBefore, page) && after in manual.IsBefore[page],
        rest
    )
end

# 4959
function part1(manual::Manual)
    score = 0
    for update in manual.Updates
        is_ok = true
        for (i, page) in enumerate(update)
            is_ok = is_ok && is_before_the_rest(manual, page, @view update[i+1:end])
        end
        is_ok && (score += update[length(update)÷2 + 1])
    end
    return score
end

#
function part2(manual::Manual)
    return nothing
end

end
