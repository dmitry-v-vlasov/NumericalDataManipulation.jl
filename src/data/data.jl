module Data

include("types.jl")
export NumericalTable

include("storage/storage.jl")
export FileResource
export exists
export load_numerical_table

include("manipulation/manipulation.jl")
export DataGrid
export unique_knots_golden

end  # module
