module AoC_24_Day9

mutable struct DiskEntry
    size::UInt
    id::Int
end

mutable struct Disk
    entries::Vector{DiskEntry}
    # Indexes of the gaps in the disk entries
    gap_indexes::Vector{UInt}
    # Offset applied to gap indexes (due to the insertion/deletion ofentries)
    gap_index_offset::Int
    total_file_size::UInt
end

function Disk(input::String)
    entries = Vector{DiskEntry}()
    gap_indexes = Vector{Int}()
    is_file = true
    id = 0
    total_file_size = 0
    for ch in input
        ch == '\n' && continue
        digit = ch - '0'
        if is_file
            push!(entries, DiskEntry(digit, id))
            id += 1
            total_file_size += digit
        elseif digit != 0
            push!(entries, DiskEntry(digit, -1))
            push!(gap_indexes, length(entries))
        end
        is_file = !is_file
    end
    return Disk(entries, gap_indexes, 0, total_file_size)
end

function solve_file(path::String)
    return solve_data(read(path, String))
end

function solve_data(data::String)
    printstyled("Part 1: ", solve_part1(data), "\n"; color=:blue)
    printstyled("Part 2: ", solve_part2(data), "\n"; color=:yellow)
    return nothing
end

function solve_part1(data::String)
    disk = Disk(data)
    score = Part1.solve(disk)
    pretty_print(disk)
    return score
end

function solve_part2(data::String)
    disk = Disk(data)
    return Part2.solve(disk)
end

############################################################################################

function test()
    facts = Dict("example1.txt" => 1928, "example2.txt" => 60)
    for (file, expected) in facts
        printstyled("--- testing: ", file, " ---\n"; color=:yellow)
        actual = solve_part1(read(file, String))
        printstyled(expected; color=:green)
        printstyled(" == "; color=:black)
        if actual == expected
            printstyled(actual, " ✅\n"; color=:green)
        else
            printstyled(actual, " ❌\n"; color=:red)
        end
    end
end

function pretty_print(disk::Disk)
    for entry in disk.entries
        txt, color = if entry.id == -1
            (".", :black)
        else
            id = entry.id
            (id > 9 ? "_$(id)_" : string(id), :yellow)
        end
        for _ in 1:entry.size
            printstyled(txt; color=color)
        end
    end
    gaps = isempty(disk.gap_indexes) ? "∅" : join(disk.gap_indexes, ", ")
    printstyled(" | gaps: "; color=:black)
    printstyled(gaps; color=:magenta)
    printstyled(" (+"; color=:black)
    printstyled(disk.gap_index_offset; color=:magenta)
    printstyled(") | $(disk.total_file_size)\n"; color=:black)
    return nothing
end

############################################################################################

module Part1
    using ..AoC_24_Day9: DiskEntry, Disk, pretty_print

    function solve(disk::Disk)
        while !isempty(disk.gap_indexes)
            # pretty_print(disk)

            last_entry = disk.entries[end]
            # Ignore gaps at the end of the disk
            if last_entry.id == -1
                pop!(disk.entries)
                pop!(disk.gap_indexes)
                continue
            end

            first_gap_index = disk.gap_indexes[1] + disk.gap_index_offset
            first_gap_entry = disk.entries[first_gap_index]
            prev_entry = disk.entries[first_gap_index - 1]
            # @info "..." Int(first_gap_index) Int(prev_entry.id) Int(last_entry.id)

            if prev_entry.id == last_entry.id
                # Just append to the previous entry
                prev_entry.size += 1
            else
                # Insert a new entry at the first gap, of size 1
                new_entry = DiskEntry(1, last_entry.id)
                insert!(disk.entries, first_gap_index, new_entry)
                disk.gap_index_offset += 1
                # println("--")
                # pretty_print(disk)
                # println("--")
                first_gap_index += 1
            end
            # Decrease sizes of the first gap and the last entry
            last_entry.size -= 1
            if last_entry.size == 0
                pop!(disk.entries)
            end
            first_gap_entry.size -= 1
            if first_gap_entry.size == 0
                deleteat!(disk.entries, first_gap_index)
                popfirst!(disk.gap_indexes)
                disk.gap_index_offset -= 1
            end
        end
        # pretty_print(disk)
        return checksum(disk)
    end

    # Sum of I from I=K to N, for positive integers K and N ==>
    # 1/2 * (-K^2 + K + N^2 + N)
    function checksum(disk::Disk)
        score = 0
        offset = UInt(0)
        for entry in disk.entries
            offset >= disk.total_file_size && break
            entry.id == -1 && continue
            K, N = offset, offset + entry.size - 1
            score += entry.id * ((-K^2 + K + N^2 + N) ÷ 2)
            offset += entry.size
        end
        return score
    end
end

############################################################################################

module Part2
    using ..AoC_24_Day9: Disk

    function solve(disk::Disk)
        return nothing
    end
end

end
