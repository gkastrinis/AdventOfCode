module AoC_24_Day5

run(path::String) = solve(read(path, String))

Base.@kwdef struct Manual
    PagePrecedsPages::Dict{Int, Set{Int}} = Dict{Int, Set{Int}}()
    Updates::Vector{Vector{Int}} = Vector{Vector{Int}}()
end

function solve(input::String)
    manual = preprocess(input)
    printstyled("Part 1: ", part1(manual), "\n"; color=:yellow)
    printstyled("Part 2: ", part2(manual), "\n"; color=:blue)
    return nothing
end

function part1(manual::Manual)
    return sum(middle_page(update) for update in manual.Updates if in_correct_order(manual, update))
end

function part2(manual::Manual)
    return sum(middle_page(fix!(update, manual)) for update in manual.Updates if !in_correct_order(manual, update))
end

function fix!(update::AbstractVector{Int}, manual::Manual)
    for i in 1:length(update)
        for j in i+1:length(update)
            is_before(manual, update[i], update[j]) && continue
            update[i], update[j] = update[j], update[i]
        end
    end
    return update
end

function preprocess(input::String)
    manual = Manual()
    io = IOBuffer(input)
    while !eof(io)
        line = readline(io)
        # We are in the second part of the input. Stop this loop.
        isempty(line) && break

        delim = findfirst(==('|'), line)
        x = parse(Int, @view line[1:delim-1])
        y = parse(Int, @view line[delim+1:end])
        manual.PagePrecedsPages[x] = get!(manual.PagePrecedsPages, x, Set{Int}()) ∪ Set([y])
    end
    while !eof(io)
        line = readline(io)
        isempty(line) && break
        pages = split(line, ",")
        push!(manual.Updates, parse.(Int, pages))
    end
    return manual
end

function is_before(manual::Manual, page::Int, other::Int)
    return haskey(manual.PagePrecedsPages, page) && other in manual.PagePrecedsPages[page]
end

function middle_page(update::AbstractVector{Int})
    return update[length(update)÷2 + 1]
end

function in_correct_order(manual::Manual, update::AbstractVector{Int})
    f((i, page)) = all(other -> is_before(manual, page, other), @view update[i+1:end])
    return all(f, enumerate(update))
end

end
