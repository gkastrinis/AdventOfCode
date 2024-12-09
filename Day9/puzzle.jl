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

function solve_all(data::String)
    printstyled("Part 1: "; color=:black)
    printstyled(solve_part1(data), "\n"; color=:blue)
    printstyled("Part 2: "; color=:black)
    printstyled(solve_part2(data), "\n"; color=:green)
    return nothing
end

solve_part1(data::String) = Part1.solve(Disk(data))
solve_part2(data::String) = Part2.solve(Disk(data))

############################################################################################

function pretty_print(disk::Disk, print_extra::Bool=false)
    for entry in disk.entries
        txt, color = if entry.id == -1
            (".", :black)
        else
            id = entry.id
            (id > 9 ? "_$(id)_" : string(id), :yellow)
        end
        printstyled('('; color=:black)
        for _ in 1:entry.size
            printstyled(txt; color=color)
        end
        printstyled(") "; color=:black)
    end
    if print_extra
        gaps = isempty(disk.gap_indexes) ? "∅" : join(disk.gap_indexes, ", ")
        printstyled(" | gaps: "; color=:black)
        printstyled(gaps; color=:magenta)
        printstyled(" (+"; color=:black)
        printstyled(disk.gap_index_offset; color=:magenta)
        printstyled(") | $(disk.total_file_size)"; color=:black)
    end
    println()
    return nothing
end

function find_next_rightmost_file(disk::Disk, processed_file_ids::Set{Int}, file_index::Int)
    for i in file_index-1:-1:1
        id = disk.entries[i].id
        id != -1 && !(id in processed_file_ids) && return i
    end
    return 0
end

# Sum of I from I=K to N, for positive integers K and N ==>
# 1/2 * (-K^2 + K + N^2 + N)
function checksum(disk::Disk)
    score = 0
    offset = UInt(0)
    for entry in disk.entries
        if entry.id != -1
            K, N = offset, offset + entry.size - 1
            term = (-K^2 + K + N^2 + N) ÷ 2
            score += entry.id * term
        end
        offset += entry.size
    end
    return score
end

############################################################################################

module Part1
    using ..AoC_24_Day9: DiskEntry, Disk, pretty_print, find_next_rightmost_file, checksum

    function solve(disk::Disk)
        while !isempty(disk.gap_indexes)
            # pretty_print(disk)

            file_index = findlast(x -> x.id != -1, disk.entries)
            file_index == 0 && break
            file_entry = disk.entries[file_index]
            file_size, file_id = file_entry.size, file_entry.id

            first_gap_index = disk.gap_indexes[1] + disk.gap_index_offset
            first_gap_entry = disk.entries[first_gap_index]

            prev_entry = disk.entries[first_gap_index - 1]
            if prev_entry.id == file_id
                # Just append to the previous entry
                prev_entry.size += 1
            else
                # Insert a new entry at the first gap, of size 1
                new_entry = DiskEntry(1, file_id)
                insert!(disk.entries, first_gap_index, new_entry)
                disk.gap_index_offset += 1
                first_gap_index += 1
            end

            # Decrease sizes of the file entry
            file_entry.size -= 1
            if file_entry.size == 0
                file_entry.id = -1
            end
            # ... and the first gap entry
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
end

############################################################################################

module Part2
    using ..AoC_24_Day9: DiskEntry, Disk, pretty_print, find_next_rightmost_file, checksum

    function solve(disk::Disk)
        processed_file_ids = Set{Int}()
        # The rightmost file index that is valid for movement
        file_index = length(disk.entries) + 1
        while true
            # pretty_print(disk)

            file_index = find_next_rightmost_file(disk, processed_file_ids, file_index)
            file_index == 1 && break
            file_size, file_id = disk.entries[file_index].size, disk.entries[file_index].id
            push!(processed_file_ids, file_id)
            leftmost_gap = find_leftmost_valid_gap(disk, file_index, file_size)
            if leftmost_gap != 0
                disk.entries[file_index].id = -1
                coalese_offset = coalesce_gaps!(disk, file_index)
                file_index += coalese_offset

                new_entry = DiskEntry(file_size, file_id)
                insert!(disk.entries, leftmost_gap, new_entry)
                leftmost_gap += 1
                file_index += 1

                gap_entry = disk.entries[leftmost_gap]
                gap_entry.size -= file_size
                gap_entry.size == 0 && deleteat!(disk.entries, leftmost_gap)
            end
        end
        # pretty_print(disk)
        return checksum(disk)
    end

    function find_leftmost_valid_gap(disk::Disk, least_index::Int, size::UInt)
        for i in 1:least_index
            entry = disk.entries[i]
            entry.id == -1 || continue
            entry.size >= size && return i
        end
        return 0
    end

    # Attempt to coalesce gaps at the given index +- 1.
    # Returns the offset for the given index after the coalesce (-1, 0)
    function coalesce_gaps!(disk::Disk, index::Int)
        disk.entries[index].id == -1 || return 0
        total = length(disk.entries)

        if index < total && disk.entries[index+1].id == -1
            disk.entries[index].size += disk.entries[index+1].size
            deleteat!(disk.entries, index+1)
        end

        if index > 1 && disk.entries[index-1].id == -1
            disk.entries[index-1].size += disk.entries[index].size
            deleteat!(disk.entries, index)
            return -1
        end
        return 0
    end
end

############################################################################################
############################################################################################

with_file_input(path::String, f::Function) = f(read(path, String))

solve_file(path::String) = with_file_input(path, solve_all)

function test()
    function assert_result(tag, expected, actual)
        printstyled(tag, ": "; color=:black)
        printstyled(expected; color=:green)
        printstyled(" == "; color=:black)
        if !isnothing(actual) && actual == expected
            printstyled(actual, " ✅\n"; color=:green)
        else
            printstyled(actual, " ❌\n"; color=:red)
        end
    end

    for (file, expected) in [
        ("example1.txt" => (1928, 2858)),
        ("example2.txt" => (60, 132)),
    ]
        expected1, expected2 = expected
        printstyled("--- testing: ", file, " ---\n"; color=:yellow)
        assert_result("Part 1", expected1, with_file_input(file, solve_part1))
        assert_result("Part 2", expected2, with_file_input(file, solve_part2))
    end
end

end
