module Storage

include("types.jl")
include("table.jl")

export FileResource
export exists, stats, fsize, fbasename, fsizediff

export load_numerical_table, save_numerical_table

end  # module Storage
