using ArgParse
using Crayons.Box
using DataStructures
using NumericalDataManipulation.Data.Manipulation
using NumericalDataManipulation.Data.Manager

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
            #@error "$error_type ⭃ $(error)\n$(BOLD("𝐓race")):\n$(stacktrace(catch_backtrace()))"
            rethrow(error)
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
        file_a = options["file-a"]; file_a_skip_title = options["file-a-skip-title"]
        file_b = options["file-b"]; file_b_skip_title = options["file-b-skip-title"]
        master = options["master-file"]
        columns = options["columns"]
        intervals = options["intervals"]
        merge_function_strategy = options["function-merge-strategy"]
        @info """Data table selective merge:
                 ✔ File A: '$file_a';
                 ✔ File B: '$file_b';
                 ✔ Columns: $columns;
                 ✔ Intervals: {$(join(map(ivl -> "[$(ivl[1]), $(ivl[2])]:$(ivl[3])", intervals), ", "))};
                 ✔ Function merge strategy: $merge_function_strategy."""
        master_interval, slave_intervals = normalize_intervals(intervals, master)
        @info "Result: master - $master_interval; slaves - $slave_intervals"
        taks = MergeTwoTablesTask(file_a, file_b,
            master, columns, master_interval, slave_intervals,
            merge_function_strategy,
            file_a_skip_title, file_b_skip_title)
        Manager.merge_two_tables(taks)
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

# --------------
function ArgParse.parse_item(::Type{MergeFunctionStrategyName}, some_strategy::AbstractString)
    if !isempty(some_strategy) && some_strategy ∈ ["naive-join", "sigmoid-join"]
        throw(ArgParseError("Wrong merge function strategy name '$some_strategy'; Supportred values are 'naive-join' and 'sigmoid-join'."))
    end
    if "naive-join" == some_strategy
        return NAIVE_JOIN::MergeFunctionStrategyName
    elseif "sigmoid-join" == some_strategy
        return SIGMOID_JOIN::MergeFunctionStrategyName
    else
        throw(ArgParseError("Unexpected merge function strategy name '$some_strategy'"))
    end
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

# ---- CLI CONFIGURATION ----
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
# ---- @add_arg_table ARG_SETTINGS["merge-tables"]
@add_arg_table ARG_SETTINGS["merge-tables"] begin
    "--file-a", "-a"
        help = "Data file A. Supported file extension: '.csv'"
        arg_type = String
        required = true
    "--file-b", "-b"
        help = "Data file B. Supported file extension: '.csv'"
        arg_type = String
        required = true
    "--file-a-skip-title"
        help = "Skip the first line (usually a title) in the file A."
        arg_type = Bool
        default = true
        required = false
    "--file-b-skip-title"
        help = "Skip the first line (usually a title) in the file B."
        arg_type = Bool
        default = true
        required = false
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
                  from the second column.
                  TODO: Support tables with different columns numbers."""
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
    "--function-merge-strategy", "-f"
        help = """The function merge strategy name denotes a way of joining
                  the pieces of two similar functions from different tables.
                  Supported strategies:
                  $(UNDERLINE("✔ naive-join")):
                  Simple interval join of the table functions;
                  $(UNDERLINE("✔ sigmoid-join")):
                  The intervals are joined
                  with the sigmoid function with a rule
                  $(ITALICS("'f(x) = (1 - σ(x; x₀, α))⋅f⁽¹⁾(x) + σ(x; x₀, α)⋅f⁽²⁾(x)'")),
                  where σ is the sigmoid function,
                  parameter x₀ defines a boundary point between
                  interval 'a' and interval 'b',
                  parameter α defines the sigmoid function area width,
                  the functions f⁽¹⁾ and f⁽²⁾ originate from
                  $(BOLD("file-a")) and $(BOLD("file-b"))."""
        arg_type = MergeFunctionStrategyName
        default = SIGMOID_JOIN::MergeFunctionStrategyName
        required = false
end
@add_arg_table ARG_SETTINGS["dummy-command"] begin
    "--dummy-option"
        help = "Data file A"
        arg_type = String
        required = false
end

# ------------------------------------
if !isinteractive()
    println(RED_FG(LOGO))
    main(ARGS)
end
# ------------------------------------
