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
    @info arguments
end

# --- LOGO ---
const LOGO =
"""╔╦╗┌─┐┌┐┌┬┌─┐┬ ┬┬  ┌─┐┌┬┐┬┌─┐┌┐┌
║║║├─┤││││├─┘│ ││  ├─┤ │ ││ ││││
╩ ╩┴ ┴┘└┘┴┴  └─┘┴─┘┴ ┴ ┴ ┴└─┘┘└┘"""
# --- CLI settings and main() call ---
const ARG_SETTINGS = ArgParseSettings()
@add_arg_table ARG_SETTINGS begin
    "--file-a", "-a"
        help = "Data file A"
        arg_type = String
        required = true
    "--file-b", "-b"
        help = "Data file B"
        arg_type = String
        required = true
end

if !isinteractive()
    println(RED_FG(LOGO))
    main(ARGS)
end
# ------------------------------------
