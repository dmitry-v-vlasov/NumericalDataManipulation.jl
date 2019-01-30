using ArgParse
using Crayons
using Crayons.Box
using NumericalDataManipulation.Data.Manipulation
function main(args::Vector{String})
    arguments = parse_commandline(args)
    work(arguments)
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
        columns = options["columns"]
        intervals = options["intervals"]
        @info """Data table selective merge:
                 - File A: '$file_a';
                 - File B: '$file_b';
                 - Columns: $columns;
                 - Intervals: {$(join(map(ivl -> "[$(ivl[1]), $(ivl[2])]:$(ivl[3])", intervals), ", "))}."""
    elseif "dummy-command" == command
        @info "Dummy command with options: $options"
    end
end

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

const REGEX_COLUMNS = r"^([1-9][0-9]*\s*,\s*)*([1-9][0-9]*)$"
const REGEX_SPLIT_COLUMNS = r"\s*,\s*"
function ArgParse.parse_item(::Type{Vector{Int}}, columns_string::AbstractString)
    columns = strip(columns_string)
    if !occursin(REGEX_COLUMNS, columns)
        throw(ArgParseError("The column list is not a comma separated list of integers."))
    end
    column_numbers = map(c -> parse(Int, c), split(columns, REGEX_SPLIT_COLUMNS))
    return column_numbers
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
