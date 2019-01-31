using ArgParse
using Crayons
using Crayons.Box
using DataStructures
using NumericalDataManipulation.Data.Manipulation

# ---- system ----
Base.eval(:(have_color = true))
function Base.show(io::IO, intervals::Vector{Tuple{Float64, Float64, Symbol}})
    print(io, "{$(join(map(ivl -> "$ivl", intervals), ", "))}")
end
function Base.show(io::IO, ::MIME"text/plain", intervals::Vector{Tuple{Float64, Float64, Symbol}})
    show(io, intervals)
end
# ----------------

function main(args::Vector{String})
    try
        arguments = parse_commandline(args)
        work(arguments)
    catch error
        error_type = BOLD(UNDERLINE(string(typeof(error))))
        if isa(error, ArgParseError) || isa(error, ArgumentError)
            @error "$error_type ⭃ $(error.msg)"
        else
            @error "$error_type ⭃ $(error.msg)\n$(BOLD("𝐓race")):\n$(stacktrace(catch_backtrace()))"
        end
    end
end
function parse_commandline(args::Vector{String})
    return arguments = parse_args(args, ARG_SETTINGS)
end
function work(arguments::Dict{String, Any})
    @assert haskey(arguments, "%COMMAND%")
    command = arguments["%COMMAND%"]
    options = arguments[command]
    if "merge-tables" == command
        file_a = options["file-a"]
        file_b = options["file-b"]
        master = options["master-file"]
        columns = options["columns"]
        intervals = options["intervals"]
        @info """Data table selective merge:
                 - File A: '$file_a';
                 - File B: '$file_b';
                 - Columns: $columns;
                 - Intervals: {$(join(map(ivl -> "[$(ivl[1]), $(ivl[2])]:$(ivl[3])", intervals), ", "))}."""
        master_interval, slave_intervals = normalize_intervals(intervals, master)
        @info "Result: master - $master_interval; slaves - $slave_intervals"
    elseif "dummy-command" == command
        @info "Dummy command with options: $options"
    end
end

# --- utilities ---
function normalize_intervals(intervals::Vector{Tuple{Float64, Float64, Symbol}}, master::Symbol)
    # TODO: maybe a smarter approach is possible
    @assert !isempty(intervals)
    check_conflicts(intervals, master)
    normalized_intervals = Vector{Tuple{Float64, Float64, Symbol}}()

    master_interval = ifempty(filter(ivl -> master == ivl[3], intervals), [(-Inf, Inf, :a)])[1]
    slave = master == :a ? :b : :a
    slave_intervals = sort(filter(ivl -> slave == ivl[3], intervals); by = ivl -> ivl[1])

    return (master_interval, slave_intervals)
end
function check_conflicts(intervals::Vector{Tuple{Float64, Float64, Symbol}}, master::Symbol)
    # ---- duplicates
    conflicts = find_interval_file_duplicates(intervals)
    if !isempty(conflicts)
        sb = IOBuffer()
        println(sb, "Conflicting intervals are found:")
        for conflict ∈ conflicts
            civl = conflict.first
            file_ivls = conflict.second
            println(sb, "  - Conflict interval $civl: $file_ivls")
        end
        throw(ArgumentError(String(take!(sb))))
    end

    # ---- conflicts of master and slave intervals
    slave = master == :a ? :b : :a
    master_intervals = filter(ivl -> master == ivl[3], intervals)
    slave_intervals = filter(ivl -> slave == ivl[3], intervals)
    if length(master_intervals) > 1
        throw(ArgumentError("Only one master file \"$master\" interval can be specified. Given: $master_intervals"))
    end
    if isempty(slave_intervals)
        throw(ArgumentError("No intervals for the slave file \"$slave\" are specified."))
    end
    if length(master_intervals) == 1
        m_interval = master_intervals[1]
        conflicting_slaves = filter(s_ivl -> s_ivl[1] < m_interval[1] || s_ivl[2] > m_interval[2], slave_intervals)
        if !isempty(conflicting_slaves)
            throw(ArgumentError("There are \"$slave\" file intervals which are out of the master interval $m_interval: $conflicting_slaves"))
        end
    end

    # ---- overlap conflicts between slave intervals
    conflicts = find_overlapping_conflicts(slave_intervals)
    if !isempty(conflicts)
        sb = IOBuffer()
        println(sb, "Conflicting slave intervals are found:")
        for conflict ∈ conflicts
            civl = conflict.first
            file_ivls = conflict.second
            println(sb, "  - Conflict for the slave interval $civl: $file_ivls")
        end
        throw(ArgumentError(String(take!(sb))))
    end
end
function find_overlapping_conflicts(slave_intervals::Vector{Tuple{Float64, Float64, Symbol}})
    dictionary = OrderedDict{Tuple{Float64, Float64}, Vector{Tuple{Float64, Float64, Symbol}}}()
    for (i, ivl_i) ∈ enumerate(slave_intervals)
        ivl_i_conflicts =
            filter(it -> begin j, ivl_j = it
                    i ≠ j && (ivl_i[1] ≤ ivl_j[1] ≤ ivl_i[2] || ivl_i[1] ≤ ivl_j[2] ≤ ivl_i[2])
                end,
                collect(enumerate(slave_intervals)))
        if !isempty(ivl_i_conflicts)
            dictionary[(ivl_i[1], ivl_i[2])] = map(it -> it[2], ivl_i_conflicts)
        end
    end
    return dictionary
end
function find_interval_file_duplicates(intervals::Vector{Tuple{Float64, Float64, Symbol}})
    dictionary = OrderedDict{Tuple{Float64, Float64}, Vector{Tuple{Float64, Float64, Symbol}}}()
    for ivl ∈ intervals
        if !haskey(dictionary, (ivl[1], ivl[2]))
            dictionary[(ivl[1], ivl[2])] = [ivl]
        else
            push!(dictionary[(ivl[1], ivl[2])], ivl)
        end
    end
    duplicates = OrderedDict{Tuple{Float64, Float64}, Vector{Tuple{Float64, Float64, Symbol}}}()
    for entry ∈ dictionary
        if length(entry.second) > 1
            duplicates[entry.first] = entry.second
        end
    end
    return duplicates
end
function get_sorted_intervals(intervals::Vector{Tuple{Float64, Float64, Symbol}}, by::Symbol)
    @assert by ∈ [:left, :right]
    left_sorted = sort(intervals; by = ivl -> ivl[1])
    dictionary = OrderedDict{Float64, Vector{Tuple{Float64, Float64, Symbol}}}()
    keyfunction = by == :left ? ivl -> ivl[1] : ivl -> ivl[2]
    for ivl ∈ intervals
        if !haskey(dictionary, keyfunction(ivl))
            dictionary[keyfunction(ivl)] = [ivl]
        else
            push!(dictionary[keyfunction(ivl)], ivl)
        end
    end
    return dictionary
end
# -----------------
# --- common ---
function ifempty(object::Vector, default::Vector)
    return isempty(object) ? default : object
end
# --------------
# --- LOGO ---
const LOGO = strip(
"""
╔╦╗┌─┐┌┐┌┬┌─┐┬ ┬┬  ┌─┐┌┬┐┬┌─┐┌┐┌
║║║├─┤││││├─┘│ ││  ├─┤ │ ││ ││││
╩ ╩┴ ┴┘└┘┴┴  └─┘┴─┘┴ ┴ ┴ ┴└─┘┘└┘
""")
# --- CLI settings and main() call ---
const ARG_SETTINGS = ArgParseSettings(;prog = "manipulation")
@add_arg_table ARG_SETTINGS begin
    "merge-tables"
        help = "Merge two tables from two given files."
        action = :command
    "dummy-command"
        help = "Dummy command"
        action = :command
end
@add_arg_table ARG_SETTINGS["merge-tables"] begin
    "--file-a", "-a"
        help = "Data file A. Supported file extension: '.csv'"
        arg_type = String
        required = true
    "--file-b", "-b"
        help = "Data file B. Supported file extension: '.csv'"
        arg_type = String
        required = true
    "--master-file", "-m"
        help = "Choose file \"a\" or \"b\" as a \"master\" data file to merge all data to."
        arg_type = Symbol
        default = :a
        required = false
    "--columns", "-c"
        help = """Select the column numbers to merge.
                  A comma separated list of integers.
                  The first column in files is always an argument grid (X).
                  $(BOLD("Always")) start your column numbering (1, 2, ...)
                  from the second column."""
        arg_type = Vector{Int}
        required = true
    "--intervals", "-i"
        help = """Comma separated list of intervals in square brackets in quotes.
                  Example: \"[1.0, 2.0]:a, [29.6, 29.7]:b\".
                  It it allowed to use symbols Inf and -Inf in the interval values.
                  The intervals will be simplified automatically if possible.
                  The strings :a and :b denote which file must be used to
                  import data in the given interval."""
        arg_type = Vector{Tuple{Float64, Float64, Symbol}}
        required = true
end
@add_arg_table ARG_SETTINGS["dummy-command"] begin
    "--dummy-option"
        help = "Data file A"
        arg_type = String
        required = false
end

function ArgParse.parse_item(::Type{Symbol}, str::AbstractString)
    master_file = Symbol(str)
    if master_file ∉ [:a, :b]
        throw(ArgParseError("Choose the value \"a\" or \"b\" to specify the master file. Given value: $master_file"))
    end
    return master_file
end

const REGEX_COLUMNS = r"^([1-9][0-9]*\s*,\s*)*([1-9][0-9]*)$"
const REGEX_SPLIT_COLUMNS = r"\s*,\s*"
function ArgParse.parse_item(::Type{Vector{Int}}, columns_string::AbstractString)
    columns = strip(columns_string)
    if !occursin(REGEX_COLUMNS, columns)
        throw(ArgParseError("The column list is not a comma separated list of integers."))
    end
    column_numbers = map(c -> parse(Int, c), split(columns, REGEX_SPLIT_COLUMNS))
    if !allunique(column_numbers)
        throw(ArgParseError("The column list $column_numbers contains duplicates."))
    end
    return sort(column_numbers)
end

const REGEX_INTERVALS = r"^(\[([0-9]+(.[0-9]+)?|Inf|-Inf)\s*,\s*([0-9]+(.[0-9]+)?|Inf|-Inf)\](:a|:b)\s*,\s*)*\[([0-9]+(.[0-9]+)?|Inf|-Inf)\s*,\s*([0-9]+(.[0-9]+)?|Inf|-Inf)\](:a|:b)$"
const REGEX_SPLIT_INTERVALS = r"(?<=\](:a|:b))\s*,\s*(?=\[)"
const REGEX_INTERVAL_LEFT = r"(?<=\[)([0-9]+(.[0-9]+)?|Inf|-Inf)(?=\s*,)"
const REGEX_INTERVAL_RIGHT = r"([0-9]+(.[0-9]+)?|Inf|-Inf)(?=\])"
const REGEX_INTERVAL_ORIGIN = r"(?<=\]:)(a|b)"
function ArgParse.parse_item(::Type{Vector{Tuple{Float64, Float64, Symbol}}}, intervals_string::AbstractString)
    intervals = strip(intervals_string)
    if !occursin(REGEX_INTERVALS, intervals)
        throw(ArgParseError("The given interval list is not a comma separated list of intervals. Example: \"[1.0, 2.0]:a, [29.6, 29.7]:b\"."))
    end
    interval_list = map(interval -> begin
            left = parse(Float64, match(REGEX_INTERVAL_LEFT, interval).match)
            right = parse(Float64, match(REGEX_INTERVAL_RIGHT, interval).match)
            origin = Symbol(match(REGEX_INTERVAL_ORIGIN, interval).match)
            if left == Inf
                throw(ArgParseError("The left border of the interval [$left, $right]:$origin cannot be Inf."))
            end
            if right == Inf
                throw(ArgParseError("The right border of the interval [$left, $right]:$origin cannot be Inf."))
            end
            return (left, right, origin)
        end,
        split(intervals, REGEX_SPLIT_INTERVALS))
    return interval_list
end

if !isinteractive()
    println(RED_FG(LOGO))
    main(ARGS)
end
# ------------------------------------
